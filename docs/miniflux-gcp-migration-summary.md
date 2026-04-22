# Miniflux GCP Migration Summary

Date: 2026-04-22

This document summarizes the completed Miniflux migration from the Raspberry Pi host to Google Cloud and lists the remaining steps to fully decommission the Raspberry Pi workload.

## Completed Work

Miniflux now runs on Google Cloud while preserving the existing repo patterns:

- Terraform provisions infrastructure.
- Ansible deploys Docker Compose.
- Cloudflare Tunnel remains the only public ingress path.
- PostgreSQL remains containerized with a Docker-managed volume.

The new GCP runtime is:

- Project: `miniflux-494022`
- VM: `miniflux`
- Zone: `us-west1-b`
- Machine type: `e2-micro`
- OS: Debian 12
- Docker data disk: `miniflux-docker-data`
- Docker data mount: `/var/lib/docker`
- Public hostname: `https://rss.roccosmodernsite.net`

## Infrastructure Changes

The `miniflux/terraform` workspace now manages:

- Compute Engine API enablement.
- Runtime service account: `miniflux-runtime@miniflux-494022.iam.gserviceaccount.com`.
- GCE VM: `miniflux`.
- Persistent disk for Docker data.
- Egress firewall for DNS and HTTPS.
- IAP SSH ingress from `35.235.240.0/20`.
- Public SSH deny rule for the `miniflux` VM tag.
- Optional ephemeral external IPv4 for outbound internet access.
- Outputs for VM name, zone, self link, internal IP, and external IP.

The VM currently uses an ephemeral external IPv4 because the project does not have Cloud NAT. Public application traffic still enters only through Cloudflare Tunnel; Docker Compose does not publish Miniflux ports.

## Deployment Changes

The Miniflux Ansible inventory now has separate groups:

- `miniflux_pi`
- `miniflux_gcp`
- `miniflux_vm` as a parent group

The GCP host uses OS Login user:

```text
jasonroc19_gmail_com
```

The playbook now mounts the attached GCP disk at `/var/lib/docker` before Docker installation and resets the SSH connection after adding the user to the `docker` group.

The shared `pi_baseline` Docker role now supports both ARM64 and AMD64 Debian hosts by deriving the Docker apt repository architecture from `ansible_architecture`.

## Migration Validation

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

## Current Operating State

GCP is now the active Miniflux host.

The Raspberry Pi should remain in rollback posture for a short observation window:

- Pi Miniflux app stopped.
- Pi Cloudflare Tunnel stopped.
- Pi PostgreSQL data retained.
- Local database dump retained.

Do not delete the Pi Docker volume until the GCP deployment has been stable long enough that rollback is no longer needed.

## Rollback Procedure

Use this only if the GCP deployment fails during the observation window.

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

## Remaining Decommission Steps

### 1. Complete Observation Window

Wait at least a few days of normal use before deleting Pi data.

During this window, periodically check GCP health:

```bash
cd miniflux/ansible
ansible miniflux_gcp -i hosts.ini -m shell -a 'docker ps'
ansible miniflux_gcp -i hosts.ini -m shell -a 'docker logs --tail=100 miniflux'
ansible miniflux_gcp -i hosts.ini -m shell -a 'docker logs --tail=100 miniflux-tunnel'
```

Confirm the public endpoint still responds:

```bash
curl -I https://rss.roccosmodernsite.net
```

### 2. Persist Final Terraform Outputs

If not already done, save the output-only Terraform state update:

```bash
cd miniflux/terraform
terraform apply -input=false
terraform output miniflux_external_ip
```

Expected behavior: no infrastructure changes, only output persistence if pending.

### 3. Keep a Final Backup

Keep the migration dump outside the tracked repo or in a secure backup location. The current dump should not be committed.

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

### 8. Commit Repo Changes

Before committing, remove untracked backup artifacts from the repo tree:

```bash
git status --short
```

Do not commit:

- `miniflux/ansible/miniflux.dump`
- vault passwords
- decrypted vault material
- local `.tfvars` files containing secrets

Suggested commit message:

```text
Migrate Miniflux deployment to GCP VM
```

## Post-Decommission Follow-Ups

Recommended low-effort improvements after Pi retirement:

- Add scheduled PostgreSQL backups on the GCP VM.
- Consider short-retention GCE disk snapshots if the added cost is acceptable.
- Pin Docker image versions instead of using `latest`.
- Add an Ansible healthcheck task after Docker Compose deployment.
- Review the ephemeral external IPv4 cost after the first billing cycle.
- Consider Cloud NAT only if the external IPv4 model becomes operationally or financially undesirable.
