# Miniflux GCP Migration and Raspberry Pi Decommission

Date: 2026-04-22

This document records the completed Miniflux migration from the Raspberry Pi host to Google Cloud and tracks the remaining steps to fully decommission the Raspberry Pi workload.

## Summary

Miniflux now runs on Google Cloud while preserving the existing repo patterns:

- Terraform provisions infrastructure.
- Ansible deploys Docker Compose.
- Cloudflare Tunnel remains the only public ingress path.
- PostgreSQL remains containerized with a Docker-managed volume.

The active GCP runtime is:

- Project: `miniflux-494022`
- VM: `miniflux`
- Zone: `us-west1-b`
- Machine type: `e2-micro`
- OS: Debian 12
- Docker data disk: `miniflux-docker-data`
- Docker data mount: `/var/lib/docker`
- Public hostname: `https://rss.roccosmodernsite.net`

## Current Architecture

The `miniflux/terraform` workspace manages:

- Compute Engine API enablement.
- Runtime service account: `miniflux-runtime@miniflux-494022.iam.gserviceaccount.com`.
- GCE VM: `miniflux`.
- Persistent disk for Docker data.
- Egress firewall for DNS and HTTPS.
- IAP SSH ingress from `35.235.240.0/20`.
- Public SSH deny rule for the `miniflux` VM tag.
- Optional ephemeral external IPv4 for outbound internet access.
- Cloudflare Tunnel, tunnel config, and DNS CNAME.

The VM currently uses an ephemeral external IPv4 because the project does not have Cloud NAT. Public application traffic still enters only through Cloudflare Tunnel; Docker Compose does not publish Miniflux ports.

The `miniflux/ansible` workspace deploys:

- `miniflux-db`: PostgreSQL 16.
- `miniflux`: Miniflux app.
- `miniflux-tunnel`: Cloudflare Tunnel connector.

The GCP host uses OS Login user:

```text
jasonroc19_gmail_com
```

## Migration Record

The migration was completed in these phases:

1. Terraform provisioned the GCP VM, persistent disk, runtime service account, firewall rules, and Compute Engine API enablement.
2. Ansible deployed Docker and the Miniflux Compose stack to the GCP VM.
3. The Raspberry Pi Miniflux app was stopped to freeze writes while PostgreSQL remained online.
4. A compressed `pg_dump` backup was created from the Pi PostgreSQL container.
5. The dump was copied to the GCP VM through IAP.
6. The GCP PostgreSQL database was recreated and restored from the dump.
7. The GCP app was started and the Pi Cloudflare Tunnel connector was stopped.
8. The existing Cloudflare Tunnel and DNS record continued serving `rss.roccosmodernsite.net`.

Useful historical commands are below. They should not normally be needed again unless rolling back or auditing the migration.

Backup from Pi:

```bash
cd miniflux/ansible
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop miniflux'
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker exec miniflux-db pg_dump -U miniflux -d miniflux -Fc > /tmp/miniflux.dump'
scp admin@raspberrypi.local:/tmp/miniflux.dump ./miniflux.dump
```

Transfer to GCP:

```bash
gcloud compute scp ./miniflux.dump miniflux:/tmp/miniflux.dump \
  --project=miniflux-494022 \
  --zone us-west1-b \
  --tunnel-through-iap
```

Restore on GCP:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop miniflux'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker exec miniflux-db dropdb -U miniflux --if-exists miniflux'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker exec miniflux-db createdb -U miniflux miniflux'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cat /tmp/miniflux.dump | docker exec -i miniflux-db pg_restore -U miniflux -d miniflux --clean --if-exists'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose up -d miniflux'
```

Cutover:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop tunnel'
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose up -d tunnel miniflux'
```

## Validation

The following checks passed after deployment and cutover:

- `/var/lib/docker` is mounted from the attached persistent disk.
- GCP containers are running:
  - `miniflux`
  - `miniflux-db`
  - `miniflux-tunnel`
- PostgreSQL container is healthy.
- Cloudflare Tunnel registered four GCP connector connections.
- Public request succeeded:

```bash
curl -I https://rss.roccosmodernsite.net
```

Expected and observed result:

```text
HTTP/2 200
```

Pi source database counts before migration:

```text
users = 1
feeds = 10
```

The migrated GCP database was verified against these counts.

## Active Operations

Deploy Miniflux to the GCP VM:

```bash
cd miniflux/ansible
ansible-playbook -i hosts.ini deploy_miniflux.yml --limit miniflux_gcp
```

Check service health:

```bash
ansible miniflux_gcp -i hosts.ini -m shell -a 'docker ps'
ansible miniflux_gcp -i hosts.ini -m shell -a 'docker logs --tail=100 miniflux'
ansible miniflux_gcp -i hosts.ini -m shell -a 'docker logs --tail=100 miniflux-tunnel'
curl -I https://rss.roccosmodernsite.net
```

Run Terraform from the Miniflux workspace:

```bash
cd miniflux/terraform
terraform fmt -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

Apply only after reviewing the plan:

```bash
terraform apply -input=false
```

## Rollback Procedure

Use this only if the GCP deployment fails during the Raspberry Pi observation window.

From `miniflux/ansible`:

```bash
ansible miniflux_gcp -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop tunnel'
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose up -d tunnel miniflux'
```

Then verify:

```bash
curl -I https://rss.roccosmodernsite.net
```

Rollback does not require DNS changes because the Cloudflare Tunnel and DNS record were reused.

## Remaining Raspberry Pi Decommission Steps

### 1. Complete Observation Window

Wait at least a few days of normal use before deleting Pi data.

During this window:

- Keep the Pi Miniflux app stopped.
- Keep the Pi Cloudflare Tunnel stopped.
- Retain the Pi PostgreSQL data.
- Retain the local migration dump or another verified backup.

### 2. Persist Final Terraform Outputs

If not already done, save any output-only Terraform state update:

```bash
cd miniflux/terraform
terraform apply -input=false
terraform output miniflux_external_ip
```

Expected behavior: no infrastructure changes, only output persistence if pending.

### 3. Keep a Final Backup

Keep the migration dump outside the tracked repo or in a secure backup location. The dump should not be committed.

Recommended local cleanup after copying it somewhere safe:

```bash
rm miniflux/ansible/miniflux.dump
```

Only remove this file after confirming another backup exists.

### 4. Stop Remaining Pi Containers

After the rollback window, stop the remaining Pi database container:

```bash
cd miniflux/ansible
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose stop'
```

Verify nothing Miniflux-related is running on the Pi:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'cd /opt/miniflux && docker compose ps'
```

### 5. Archive or Remove Pi Deployment Directory

Archive the Pi deployment directory before deleting it:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'tar -czf /tmp/miniflux-pi-final-archive.tgz -C /opt miniflux'
scp admin@raspberrypi.local:/tmp/miniflux-pi-final-archive.tgz ./miniflux-pi-final-archive.tgz
```

After confirming the archive is copied and no rollback is needed:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'rm -rf /opt/miniflux'
```

### 6. Remove Pi Docker Volume

This is the destructive final data-removal step. Run only after the archive and backup are confirmed.

First identify the exact volume name:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'docker volume ls | grep miniflux'
```

Then remove the volume if it is no longer needed:

```bash
ansible miniflux_pi -i hosts.ini -b -m shell -a 'docker volume rm miniflux_db-data'
```

If the volume name differs, use the exact name from `docker volume ls`.

### 7. Update Inventory When Pi Is Fully Retired

After the Pi is fully decommissioned for Miniflux, remove or comment the Pi group from `miniflux/ansible/hosts.ini`:

```ini
[miniflux_pi]
# raspberrypi.local ansible_user=admin miniflux_target=pi
```

Keep `miniflux_gcp` as the active deployment target.

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

- Static or ephemeral external IPv4 addresses.
- Larger disks.
- `pd-balanced`, SSD, or snapshot-heavy storage.
- NAT Gateway.
- Load balancers.
- Cloud SQL.
- High egress from feed polling or media-heavy content.

Recommended follow-ups:

- Add scheduled PostgreSQL backups on the GCP VM.
- Consider short-retention GCE disk snapshots if the added cost is acceptable.
- Pin Docker image versions instead of using `latest`.
- Add an Ansible healthcheck task after Docker Compose deployment.
- Review the ephemeral external IPv4 cost after the first billing cycle.
- Consider Cloud NAT only if the external IPv4 model becomes operationally or financially undesirable.
