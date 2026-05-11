# Cloudflare Terraform Workspace

This workspace manages shared Cloudflare and Entra/Zero Trust resources for the Rocjay ecosystem.

## Resources Managed

- **Zone & DNSSEC**: Basic configuration for `roccosmodernsite.net`.
- **WAF Rules**: Global security rules, including Geo-blocking and IP bypasses for internal services.
- **Email Infrastructure**: iCloud+ Custom Domain configuration and DMARC Management.
- **GitHub Pages**: Custom domain mapping for `docs.roccosmodernsite.net` to support the GitHub Pages namespace.
- **Turnstile**: Managed widgets for site protection.

## Email Infrastructure

The domain `roccosmodernsite.net` is configured to use iCloud+ for custom email. The configuration is centralized in `dns.tf`.

### Key Records
- **MX**: Points to iCloud mail servers.
- **SPF**: Authorized to `icloud.com`.
- **DKIM**: CNAME record for Apple's signing service.
- **DMARC**: Hardened policy (`p=reject`) with dual reporting to:
  - `postmaster@roccosmodernsite.net`
  - Cloudflare DMARC Management dashboard.

### Required Variables
The following variables must be provided (typically via environment variables or a secure `.tfvars` file):
- `apple_domain_verification`: The unique verification code from the iCloud Custom Email setup wizard.
- `cloudflare_dmarc_report_emails`: A list of email addresses for DMARC aggregate reports.

## Workflow

1.  **Initialize**: `terraform init` (requires GCS backend access).
2.  **Plan**: `terraform plan` (requires `CLOUDFLARE_API_TOKEN`).
3.  **Apply**: `terraform apply`.

> [!IMPORTANT]
> DNS records in this workspace are managed as **DNS-only** (`proxied = false`) where required by protocol (e.g., MX, TXT for SPF/DMARC) to ensure service compatibility.
