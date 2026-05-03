# Miniflux Infrastructure

This workspace contains the infrastructure-as-code and configuration management for deploying the [Miniflux](https://miniflux.app/) RSS reader on a low-cost Google Cloud VM via a secure Cloudflare Tunnel.

## Structure

- **[terraform](terraform/)**: Cloudflare DNS, Zero Trust Tunnel, and Google Compute Engine provisioning via Terraform.
- **[ansible](ansible/)**: Host configuration and Docker-based application deployment rules.

---

## Provisioning (Terraform)

Located in the `terraform/` directory, this provisions the Cloudflare Tunnel (`miniflux-tunnel`), assigns the CNAME mapping (e.g. `rss`), and creates the Google Cloud VM and persistent Docker data disk.

### Requirements (Terraform)

- Terraform CLI
- Cloudflare API Token (set via `CLOUDFLARE_API_TOKEN` or `terraform.tfvars`)
- Required non-secret variables: `account_id`, `zone_id`, `zone_name`, `billing_account`, and optionally `alert_email` (see `terraform/terraform.tfvars.example`)
- Access to the target GCS bucket for remote state.

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
- Disks: `pd-standard` or `pd-balanced`
- **External IPv4**: A static external IPv4 is used to provide a stable source IP for the FlareBridge WAF lockdown. This is typically covered by the GCP "Always Free" tier for one in-use external IP in `us-west1`.
- Ingress: Cloudflare Tunnel only (VPC-level deny rules for RDP/SSH are managed via Terraform)

Do not enable NAT Gateway, Load Balancer, Cloud SQL, or larger disks unless accepting extra cost. `pd-balanced` is recommended for improved performance over `pd-standard` while remaining cost-effective.

---

## Deployment (Ansible)

Located in the `ansible/` directory. This manages the full lifecycle of the Miniflux application on Google Cloud.

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
ansible-playbook -i hosts.ini deploy_miniflux.yml
```

For migration history from the legacy Raspberry Pi setup, see [`../docs/miniflux-gcp-migration.md`](../docs/miniflux-gcp-migration.md).

### Ansible Roles & Tasks

This deployment uses the following shared Ansible roles located at `../../ansible/roles/`:

- **`debian_docker_host`**: Provisions standard host security (SSH hardening, unattended-upgrades), installs Docker Engine, and configures routine maintenance. Note that UFW is deliberately omitted as network security is managed at the GCP VPC level.
- **`gcp_host`**: A GCP-specific wrapper that installs the Google Cloud Ops Agent and configures Docker to use the `gcplogs` driver.

---

## Observability & Monitoring (GCP only)

For GCP-based deployments, this workspace implements automated observability:

- **Logging**: Docker is configured to use the `gcplogs` driver, routing all container logs directly to Google Cloud Logging.
- **Security Logs**: GCP Firewall rules (managed via Terraform) are configured to explicitly deny RDP (port 3389) and public SSH (port 22) to minimize noise and connection attempts in system logs.
- **Ops Agent**: The Google Cloud Ops Agent is automatically installed and configured on the VM to collect system and application metrics.
- **Uptime Monitoring**: Terraform provisions a Cloud Monitoring Uptime Check to verify the availability of the Miniflux service.
- **Budgeting**: A GCP Billing Budget of 5.00 USD is configured for the project with alert thresholds at 50%, 90%, and 100% of the budget.
- **Alerting**: Monitoring Alert Policies are created for uptime, container errors, and budget thresholds. To receive email notifications, set the `alert_email` variable in your Terraform configuration.
