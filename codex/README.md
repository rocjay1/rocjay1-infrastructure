# Codex Environment Infrastructure

This workspace provisions Google Cloud resources used by the Codex environment for the Miniflux project.

## Resources

- A dedicated Google Cloud service account for Codex.
- Project IAM bindings for the service account.
- A service account key.
- A Secret Manager secret version containing the JSON service account key.

The implementation uses the shared `terraform/modules/codex_gcp_service_account` module and passes Miniflux-specific project roles from this workspace.

The service account is always granted the project roles required by the Miniflux Terraform workspace:

- `roles/compute.admin`
- `roles/iam.serviceAccountUser`
- `roles/storage.objectAdmin`
- `roles/secretmanager.admin`

The generated service account key is stored in Terraform state as sensitive data because Terraform creates it before writing it to Secret Manager. Keep remote state access restricted.

## Usage

Run Terraform from the `terraform/` directory:

```bash
cd terraform
terraform fmt -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

Do not run `terraform apply` unless you intend to create or update the Codex environment resources.
