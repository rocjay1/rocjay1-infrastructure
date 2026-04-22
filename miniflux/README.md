# Miniflux Infrastructure

This workspace contains the infrastructure-as-code and configuration management for deploying the [Miniflux](https://miniflux.app/) RSS reader on a Raspberry Pi or a low-cost Google Cloud VM via a secure Cloudflare Tunnel.

## Structure

- **[terraform](terraform/)**: Cloudflare DNS, Zero Trust Tunnel, and Google Compute Engine provisioning via Terraform.
- **[ansible](ansible/)**: Host configuration and Docker-based application deployment rules.

---

## Provisioning (Terraform)

Located in the `terraform/` directory, this provisions the Cloudflare Tunnel (`miniflux-tunnel`), assigns the CNAME mapping (e.g. `rss`), and creates the Google Cloud VM and persistent Docker data disk.

### Requirements (Terraform)

- Terraform CLI
- Cloudflare API Token (set via `CLOUDFLARE_API_TOKEN` or `terraform.tfvars`)
- Required non-secret variables: `account_id`, `zone_id`, and `zone_name` (see `terraform/terraform.tfvars.example`)
- Access to the target GCS bucket for remote state.


### Codex Web Setup

For a non-interactive Codex Web environment (Terraform + credentials bootstrap), see [`terraform/CODEX_WEB_RUNBOOK.md`](terraform/CODEX_WEB_RUNBOOK.md).

### Usage (Terraform)

```bash
cd terraform
terraform fmt -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

Apply only after reviewing the plan:

```bash
terraform apply -input=false
```

Retrieve the tunnel token from Terraform state:

```bash
terraform output -raw miniflux_tunnel_token
```

### Google Cloud Cost Guardrails

This workspace is designed for a low-cost/free-tier-oriented deployment:

- VM: one `e2-micro`
- Zone: `us-west1-b`
- Region: `us-west1`
- Disks: `pd-standard`
- External IPv4: disabled by default; enable an ephemeral external IPv4 only when no Cloud NAT or other egress path exists
- Ingress: Cloudflare Tunnel only

Do not enable NAT Gateway, Load Balancer, Cloud SQL, static external IPv4, larger disks, or non-standard disk classes unless accepting extra cost.

---

## Deployment (Ansible)

Located in the `ansible/` directory. This manages the full lifecycle of the Miniflux application on Raspberry Pi and Google Cloud targets.

### Architecture

The deployment consists of several Dockerized services:

- **miniflux-db**: A PostgreSQL 16 container, which acts as the datastore for the RSS application.
- **miniflux**: The golang-based RSS reader UI & API.
- **tunnel**: A secure Cloudflared Tunnel container routing traffic out to Cloudflare.

### Setup & Secrets

Sensitive variables and authentication credentials are managed by Ansible Vault.

1. **Create the Vault Password File**:
   Store your vault password in `ansible/.vault_pass` (this file is ignored by Git).

   ```bash
   cd ansible
   echo "your_secure_password" > .vault_pass
   ```

2. **Configure Vault Variables**:
   Edit `ansible/vars/vault.yml` to securely encrypt sensitive properties:
   - `vault_tunnel_token`: The Cloudflare Tunnel token retrieved from the Terraform outputs.
   - `vault_db_password`: Secure password for your Postgres database container.
   - `vault_admin_password`: Initial login password for the main `admin` user on Miniflux.

   ```bash
   mkdir -p vars
   ansible-vault create vars/vault.yml --vault-password-file .vault_pass
   ```

### Deployment

To provision the server and deploy the container stack:

```bash
cd ansible
ansible-playbook -i hosts.ini deploy_miniflux.yml --limit miniflux_pi
ansible-playbook -i hosts.ini deploy_miniflux.yml --limit miniflux_gcp
```

For the Raspberry Pi to Google Cloud migration procedure, see [`MIGRATION_GCP.md`](MIGRATION_GCP.md).

### Ansible Roles & Tasks

This deployment uses the shared **`pi_baseline`** Ansible role located at the root of the repository (`../ansible/roles/pi_baseline/`). This role provisions standard host security (UFW, SSH hardening), installs Docker Engine, and configures routine maintenance and log rotation on Raspberry Pi and Debian-based Google Cloud targets.
