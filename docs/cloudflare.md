# Cloudflare Terraform Workspace

This workspace manages shared Cloudflare and Entra/Zero Trust resources for the Rocjay ecosystem.

## Resources Managed

- **Zone & DNSSEC**: Basic configuration for `roccosmodernsite.net` (managed in `zone.tf`).
- **WAF Rules**: "Challenge by Default" policy that bypasses the Miniflux VM and authorized GCP health checks, but subjects all other traffic to a **Managed Challenge** (managed in `waf.tf`).
- **Email Infrastructure**: iCloud+ Custom Domain configuration and DMARC Management (managed in `email.tf`).
- **GitHub Pages**: Custom domain mapping and domain verification records (managed in `github.tf`).
- **Turnstile**: Managed widgets for site protection (managed in `widgets.tf`).

## Email Infrastructure

The domain `roccosmodernsite.net` is configured to use iCloud+ for custom email. 

### Key Records
- **MX**: Points to iCloud mail servers.
- **SPF**: Authorized to `icloud.com`.
- **DKIM**: CNAME record for Apple's signing service.
- **DMARC**: Hardened policy (`p=reject`) with dual reporting.

### Configuration
Static values like the iCloud verification code and DMARC reporting addresses are hardcoded or managed as constants in `locals.tf` since they do not vary across environments.

## Workflow

1.  **Initialize**: `terraform init` (requires GCS backend access).
2.  **Plan**: `terraform plan` (requires `CLOUDFLARE_API_TOKEN`).
3.  **Apply**: `terraform apply`.

> [!IMPORTANT]
> DNS records in this workspace are managed as **DNS-only** (`proxied = false`) where required by protocol (e.g., MX, TXT for SPF/DMARC) to ensure service compatibility.
