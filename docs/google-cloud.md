# Google Cloud Infrastructure

This workspace provisions shared administrative and management infrastructure for the Rocjay ecosystem on Google Cloud Platform.

## Overview

The primary goal of this workspace is to centralize resources that are used for the management of the repository, CI/CD pipelines, and identity federation. By centralizing these resources, we avoid duplication and ensure a consistent security posture across the ecosystem.

## Resources

- **Workload Identity Federation (WIF)**: Configures GCP to trust GitHub Actions OIDC tokens, enabling keyless authentication for CI/CD pipelines.
- **Service Accounts**: Provisions specialized service accounts for automated tasks (e.g., Terraform drift detection).
- **IAM Bindings**: Manages the permissions for these service accounts across the GCP projects in the ecosystem.

## Workspace Structure

- `terraform/`: Contains the Terraform configuration for provisioning the management resources.
  - `main.tf`: Defines the WIF pool, provider, service accounts, and IAM bindings.
  - `variables.tf`: Configuration variables for the workspace.
  - `outputs.tf`: Key identifiers for use in other repositories or CI/CD configurations.

## Usage

To apply changes to this workspace:

1. Navigate to the `terraform/` directory.
2. Initialize the workspace: `terraform init`.
3. Plan and apply changes: `terraform plan` and `terraform apply`.

### GitHub Actions Configuration

To use the Workload Identity Federation in a GitHub Actions workflow, use the `google-github-actions/auth` action:

```yaml
- uses: 'google-github-actions/auth@v2'
  with:
    project_id: 'abiding-cycle-464914-p6'
    workload_identity_provider: 'projects/921000564704/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider'
    service_account: 'terraform-drift-detector@abiding-cycle-464914-p6.iam.gserviceaccount.com'
```
