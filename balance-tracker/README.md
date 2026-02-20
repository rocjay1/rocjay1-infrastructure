# Balance Tracker Deployment

This directory contains the Ansible configuration to manage the full lifecycle and deployment of the Balance Tracker application on a Raspberry Pi.

## Architecture

The deployment consists of:

- **balance-tracker-frontend**: GHCR Image containing the Vite/Vue front-end.
- **balance-tracker-backend**: GHCR Image containing the Go back-end handling SQLite transactions and API logic.
- **watchtower**: Automatically maintains up-to-date images from GHCR without manual intervention.
- **cloudflared**: A secure Cloudflare Tunnel to expose the front-end to the internet without opening inbound firewall ports.

## Requirements

Ensure the target machine (e.g., Raspberry Pi) is accessible via SSH and `python3` is installed.

On your deployment machine (e.g., your Mac), you need Ansible installed:

```bash
brew install ansible
ansible-galaxy collection install community.docker
ansible-galaxy collection install community.general
```

## Setup & Secrets

Sensitive variables are managed by Ansible Vault.

1. **Create the Vault Password File**:
   Store your vault password in a local file (this is ignored by Git).

   ```bash
   echo "your_secure_password" > .vault_pass
   ```

2. **Configure Vault Variables**:
   There is one vault file used in this deployment:

   - `vars/vault.yml` (Core infrastructure and application secrets):
     Contains the `vault_tunnel_token` for Cloudflare, `vault_ghcr_auth` for Docker pulls, and `vault_gmail_app_password` used by the backend.

     ```bash
     ansible-vault edit vars/vault.yml --vault-password-file .vault_pass
     ```

## Deployment

To provision the server, apply security hardening, configure Docker, setup SQLite backups, and deploy the application, run:

```bash
ansible-playbook -i hosts.ini deploy_balance_tracker.yml --vault-password-file .vault_pass
```

### Ansible Roles & Tasks

The main playbook `deploy_balance_tracker.yml` imports specialized tasks to manage the node:

- `tasks/security.yml`: Configures UFW firewall, unattended-upgrades, and SSH hardening.
- `tasks/docker.yml`: Installs the Docker Engine, configures the daemon for log rotation, and manages permissions.
- `tasks/backups.yml`: Creates daily cron jobs to safely backup the `.db` SQLite file.
- `tasks/maintenance.yml`: Sets up metrics via `prometheus-node-exporter`, weekly docker cache pruning, and automated reboots.
- `handlers/main.yml`: Handles restart triggers for services like SSH and Docker.
