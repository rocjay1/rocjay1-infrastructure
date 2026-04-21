# Codex Web Runbook (miniflux/terraform)

This runbook configures a non-interactive Codex Web environment for Terraform in `miniflux/terraform`.

## 1) Create the Codex Web environment

Use these environment-level settings:

- **Repository**: `rocjay1-infrastructure`
- **Working directory**: `/workspace/rocjay1-infrastructure/miniflux/terraform`
- **Network access**: enabled
- **Setup script**: `bash codex/setup-codex-env.sh`

## 2) Configure secrets in Codex Web

Required:

- `GOOGLE_APPLICATION_CREDENTIALS_JSON`: JSON key for the Terraform GCP service account.

Optional (needed if Cloudflare resources are in scope):

- `CLOUDFLARE_API_TOKEN`: Cloudflare API token.

Do not store credentials in tracked files or `terraform.tfvars`.

## 3) Expected IAM permissions

The Terraform service account should have at least:

- `roles/compute.admin`
- `roles/iam.serviceAccountUser`
- `roles/storage.objectAdmin` (for GCS state backend)

Optional if managing secrets via Terraform:

- `roles/secretmanager.admin`

## 4) Startup behavior

The setup script (`codex/setup-codex-env.sh`) does the following:

1. Installs Terraform if not present.
2. Writes `GOOGLE_APPLICATION_CREDENTIALS_JSON` to `/tmp/gcp-terraform-sa.json`.
3. Exports `GOOGLE_APPLICATION_CREDENTIALS`.
4. Exports `TF_VAR_cloudflare_api_token` when `CLOUDFLARE_API_TOKEN` is set.

## 5) Standard Terraform workflow

Run these commands from `miniflux/terraform`:

```bash
terraform fmt -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

Never run `terraform apply` or `terraform destroy` unless explicitly intended.

## 6) Troubleshooting

### `terraform init` fails with backend auth errors

Check:

- `GOOGLE_APPLICATION_CREDENTIALS` points to a readable file.
- The service account has access to the configured GCS backend bucket.
- Network egress is enabled for plugin/backend access.

### `terraform plan` fails after successful init

This usually means provider/API permissions are missing even though backend access works.

Check:

- Compute/IAM role bindings for the Terraform service account.
- Required APIs enabled in the target GCP project.

### Cloudflare errors during plan

Check:

- `CLOUDFLARE_API_TOKEN` is present in environment secrets.
- Token has the scopes required by resources in this workspace.
