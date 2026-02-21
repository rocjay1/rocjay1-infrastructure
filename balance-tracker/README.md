# Balance Tracker Infrastructure

This workspace contains the infrastructure-as-code and configuration management for the Balance Tracker application.

## Structure

- **[terraform](terraform/)**: Cloudflare and Azure AD (Entra ID) provisioning via Terraform.
- **[ansible](ansible/)**: Host configuration, security hardening, and Docker-based application deployment.

---

## Provisioning (Terraform)

Located in the `terraform/` directory.

### Requirements (Terraform)

- Terraform CLI
- Cloudflare API Token (set via `CLOUDFLARE_API_TOKEN` or `terraform.tfvars`)
- Access to the Azure Storage Account for remote state (authenticated via Azure CLI).

### Usage (Terraform)

```bash
cd terraform
terraform init
terraform apply
```

---

## Deployment (Ansible)

Located in the `ansible/` directory. This manages the full lifecycle of the Balance Tracker application on a Linux host (e.g., Raspberry Pi).

### Architecture

The deployment consists of several Dockerized services:

- **balance-tracker-frontend**: GHCR Image containing the Vite/Vue front-end.
- **balance-tracker-backend**: GHCR Image containing the Go back-end handling SQLite transactions and API logic.
- **cloudflared**: A secure Cloudflare Tunnel to expose the front-end to the internet without opening inbound firewall ports.
- **watchtower**: Automatically maintains up-to-date images from GHCR.

#### Monitoring & Observability

- **Prometheus**: Collects system and application metrics.
- **Grafana**: Provides dashboards for metrics visualization.
- **Loki & Promtail**: Centralized log aggregation and analysis.
- **Node Exporter**: System-level metrics from the host machine.

### Requirements (Ansible)

Ensure the target machine is accessible via SSH and `python3` is installed.

On your deployment machine, you need Ansible installed:

```bash
brew install ansible
ansible-galaxy collection install community.docker
ansible-galaxy collection install community.general
```

### Setup & Secrets

Sensitive variables and authentication credentials are managed by Ansible Vault.

1. **Create the Vault Password File**:
   Store your vault password in `ansible/.vault_pass` (this file is ignored by Git).

   ```bash
   cd ansible
   echo "your_secure_password" > .vault_pass
   ```

2. **Configure Vault Variables**:
   Edit `ansible/vars/vault.yml` to include:
   - `vault_tunnel_token`: The Cloudflare Tunnel token.
   - `vault_ghcr_auth`: Base64 encoded GHCR credentials for pulling private images.

   ```bash
   ansible-vault edit vars/vault.yml --vault-password-file .vault_pass
   ```

### Deployment

To provision the server and deploy the application:

```bash
cd ansible
ansible-playbook -i hosts.ini deploy_balance_tracker.yml --vault-password-file .vault_pass
```

### Ansible Roles & Tasks

- `tasks/security.yml`: Firewall (UFW), SSH hardening, and user management.
- `tasks/docker.yml`: Docker Engine setup and log rotation.
- `tasks/backups.yml`: SQLite database backups.
- `tasks/maintenance.yml`: Node Exporter installation and cron-based maintenance (e.g., system prunes).
- `handlers/main.yml`: Service restart triggers and system reboots.
