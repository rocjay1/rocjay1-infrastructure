# Miniflux Raspberry Pi to Google Cloud Migration

This runbook migrates the existing Raspberry Pi Miniflux deployment to the Google Cloud VM managed by `miniflux/terraform`.

The migration keeps the existing architecture:

- Terraform manages infrastructure.
- Ansible deploys Docker Compose.
- PostgreSQL remains a container with a Docker volume.
- Cloudflare Tunnel remains the only HTTP ingress path.

## Preconditions

- Run Terraform from `miniflux/terraform`.
- Run Ansible from `miniflux/ansible`.
- `CLOUDFLARE_API_TOKEN` is available when Terraform touches Cloudflare resources.
- Google Cloud auth can read/write the GCS backend bucket `daily-tech-brief-tfstate` and manage the Miniflux compute resources.
- `ansible/vars/vault.yml` contains:
  - `vault_tunnel_token`
  - `vault_db_password`
  - `vault_admin_password`
- The GCP inventory host `miniflux` is reachable over SSH. The recommended path is IAP.

Recommended SSH config for IAP:

```sshconfig
Host miniflux
  HostName miniflux
  User rocjay
  ProxyCommand gcloud compute start-iap-tunnel miniflux 22 --zone us-west1-b --listen-on-stdin
```

## Phase A: Provision Infrastructure

```bash
cd miniflux/terraform
terraform fmt -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

Review the plan, then apply:

```bash
terraform apply -input=false
```

Capture outputs:

```bash
terraform output miniflux_instance_name
terraform output miniflux_instance_zone
terraform output miniflux_internal_ip
terraform output -raw miniflux_tunnel_token
```

Expected outcome:

- One Debian 12 `e2-micro` VM named `miniflux` exists in `us-west1-b`.
- One attached `pd-standard` disk named `miniflux-docker-data` exists.
- The existing Cloudflare Tunnel and DNS record remain unchanged.
- No external IPv4 is assigned unless `assign_public_ip=true`.
- If no Cloud NAT or other egress path exists, set `assign_public_ip=true` so apt, Docker pulls, feed fetching, and Cloudflare Tunnel outbound connections can reach the internet.

Failure handling:

- If `terraform init` fails, fix GCS backend credentials or network access.
- If Cloudflare resources fail, verify `CLOUDFLARE_API_TOKEN`.
- If Compute Engine resources fail, verify the Compute Engine API and Terraform service account roles.

## Phase B: Parallel Deployment

Store the tunnel token and app secrets in Ansible Vault:

```bash
cd miniflux/ansible
ansible-vault edit vars/vault.yml --vault-password-file .vault_pass
```

Required vault shape:

```yaml
vault_tunnel_token: "<terraform output -raw miniflux_tunnel_token>"
vault_db_password: "<existing database password>"
vault_admin_password: "<existing admin password>"
```

Deploy only to the GCP VM:

```bash
ansible-playbook -i hosts.ini deploy_miniflux.yml --limit miniflux_gcp
```

Expected outcome:

- Docker is installed on the GCP VM.
- `/var/lib/docker` is mounted from `/dev/disk/by-id/google-docker-data`.
- `miniflux-db`, `miniflux`, and `miniflux-tunnel` containers are created.

Check the deployment:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'docker ps'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'df -h /var/lib/docker'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose logs --tail=100'
```

Failure handling:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose down'
```

Leave the Raspberry Pi stack running until the final migration backup begins.

## Phase C: Database Migration

Stop the Raspberry Pi app container so the database stops receiving writes while PostgreSQL remains online:

```bash
cd miniflux/ansible
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop miniflux'
```

Create a compressed logical backup on the Raspberry Pi:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker exec miniflux-db pg_dump -U miniflux -d miniflux -Fc > /tmp/miniflux.dump'
```

Verify the backup:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'ls -lh /tmp/miniflux.dump'
```

Copy the backup locally:

```bash
scp admin@raspberrypi.local:/tmp/miniflux.dump ./miniflux.dump
```

Transfer it to GCP:

```bash
gcloud compute scp ./miniflux.dump miniflux:/tmp/miniflux.dump \
  --zone us-west1-b \
  --tunnel-through-iap
```

Stop the GCP app container while keeping PostgreSQL online:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop miniflux'
```

Recreate the GCP database:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker exec miniflux-db dropdb -U miniflux --if-exists miniflux'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker exec miniflux-db createdb -U miniflux miniflux'
```

Restore the backup:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cat /tmp/miniflux.dump | docker exec -i miniflux-db pg_restore -U miniflux -d miniflux --clean --if-exists'
```

Start the GCP app:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose up -d miniflux'
```

Verify database contents:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'docker exec miniflux-db psql -U miniflux -d miniflux -c "\dt"'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'docker exec miniflux-db psql -U miniflux -d miniflux -c "select count(*) as users from users; select count(*) as feeds from feeds;"'
```

Failure handling before cutover:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose down'
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose up -d miniflux'
```

## Phase D: Cutover

Stop the Raspberry Pi Cloudflare Tunnel connector:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop tunnel'
```

Ensure the GCP app and tunnel are running:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose up -d tunnel miniflux'
```

Check GCP tunnel logs:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'docker logs --tail=100 miniflux-tunnel'
```

Expected outcome:

- `rss.<zone_name>` routes through the GCP tunnel connector.
- No DNS change is required.

Rollback after cutover:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop tunnel'
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose up -d tunnel miniflux'
```

## Phase E: Validation

From a workstation:

```bash
curl -I https://rss.<zone_name>
curl -sS https://rss.<zone_name>/healthcheck || true
```

From the GCP VM:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'docker ps'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'docker logs --tail=100 miniflux'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'docker logs --tail=100 miniflux-db'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'df -h /var/lib/docker'
```

Validation criteria:

- Login succeeds.
- Feed and user counts match the Raspberry Pi backup.
- Cloudflare Tunnel is connected from GCP.
- Docker data is stored on the persistent disk mounted at `/var/lib/docker`.

## IAM and Authentication

The Terraform service account needs enough access to manage this workspace:

- `roles/compute.instanceAdmin.v1`
- `roles/compute.networkAdmin` if Terraform manages firewall rules
- `roles/iam.serviceAccountAdmin`
- `roles/iam.serviceAccountUser`
- `roles/serviceusage.serviceUsageAdmin`
- GCS object access to the Terraform state bucket

The Codex Terraform workspace grants these roles for non-interactive Terraform. Prefer Application Default Credentials or Workload Identity Federation over long-lived JSON keys where practical.

The VM runtime service account should not receive broad project permissions. The Terraform VM config only grants logging and monitoring OAuth scopes.

## Cost and Risk Notes

Designed low-cost defaults:

- `region = "us-west1"`
- `zone = "us-west1-b"`
- `machine_type = "e2-micro"`
- `boot_disk_type = "pd-standard"`
- `data_disk_type = "pd-standard"`
- `assign_public_ip = false`
- `create_static_ipv4 = false`

For a VM without Cloud NAT, use `assign_public_ip = true` and keep `create_static_ipv4 = false`. This attaches an ephemeral external IPv4 for outbound internet access without adding a public app listener. Terraform allows IAP SSH from `35.235.240.0/20` and adds a higher-priority deny rule for public SSH so default VPC SSH rules do not expose this VM.

Potential cost sources:

- Static or ephemeral external IPv4 addresses
- Larger disks
- `pd-balanced`, SSD, or snapshot-heavy storage
- NAT Gateway
- Load balancers
- Cloud SQL
- High egress from feed polling or media-heavy content

Operational risks:

- Running Pi and GCP Cloudflare Tunnel connectors at the same time can route requests to either host.
- A failed database restore should be rolled back before stopping the Pi tunnel.
- Changing the shared `debian_docker_host` role affects other playbooks using that role; the Docker repository architecture change is intended to preserve ARM64 behavior and add AMD64 support.
