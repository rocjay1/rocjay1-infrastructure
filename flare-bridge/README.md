# FlareBridge Infrastructure

This workspace manages the infrastructure for the FlareBridge project using Cloudflare-native services.

## Architecture

The project has been migrated from Cloudflare Pages to a more flexible architecture using:

- **Cloudflare Workers**: Handles the aggregation logic and serves the feeds.
- **Custom Domain**: Bound to `feeds.roccosmodernsite.net`.

## Components

### Terraform (`terraform/`)

The Terraform configuration provisions:

- `cloudflare_worker_script`: The worker identity.
- `cloudflare_d1_database`: Persistent storage for feed data.
- `cloudflare_workers_custom_domain`: Routing for the custom domain.

The `d1_database_id` output provides the ID required for the `DB` binding in the application's `wrangler.toml`.

## Deployment

1. **Prerequisites**:
    - Cloudflare API Token with `Account.Worker Scripts`, `Zone.Workers Routes`, and `Zone.DNS` permissions.

2. **Workflow**:

    ```bash
    cd terraform/
    terraform init
    terraform plan
    terraform apply
    ```
