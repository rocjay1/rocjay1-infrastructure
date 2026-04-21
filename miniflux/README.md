# Miniflux Infrastructure

This workspace contains the infrastructure-as-code and configuration management for deploying the [Miniflux](https://miniflux.app/) RSS reader on a Raspberry Pi via a secure Cloudflare Tunnel.

## Structure

- **[terraform](terraform/)**: Cloudflare DNS and Zero Trust Tunnel provisioning via Terraform.
- **[ansible](ansible/)**: Host configuration and Docker-based application deployment rules.

---

## Provisioning (Terraform)

Located in the `terraform/` directory, this provisions the Cloudflare Tunnel (`miniflux-tunnel`) and assigns the CNAME mapping (e.g. `rss`).

### Requirements (Terraform)

- Terraform CLI
- Cloudflare API Token (set via `CLOUDFLARE_API_TOKEN` or `terraform.tfvars`)
- Access to the target GCS bucket for remote state.


### Codex Web Setup

For a non-interactive Codex Web environment (Terraform + credentials bootstrap), see [`terraform/CODEX_WEB_RUNBOOK.md`](terraform/CODEX_WEB_RUNBOOK.md).

### Usage (Terraform)

```bash
cd terraform
terraform init
terraform apply
```

*Retrieve the tunnel token from your terraform state via `terraform output miniflux_tunnel_token`.*

---

## Deployment (Ansible)

Located in the `ansible/` directory. This manages the full lifecycle of the Miniflux application on your Raspberry Pi target.

### Architecture

The deployment consists of several Dockerized services:

- **miniflux-db**: A PostgreSQL 16 container, which acts as the datastore for the RSS application.
- **miniflux**: The golang-based RSS reader UI & API.
- **tunnel**: A secure Cloudflared Tunnel container routing traffic out to Cloudflare.
- **watchtower**: Automatically maintains up-to-date images for the Miniflux stack.

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
ansible-playbook -i hosts.ini deploy_miniflux.yml
```

### Ansible Roles & Tasks

This deployment uses the shared **`pi_baseline`** Ansible role located at the root of the repository (`../ansible/roles/pi_baseline/`). This role automatically provisions standard host security (UFW, SSH hardening), installs required Docker engines, and configures routine maintenance and log rotation on the Raspberry Pi target.
