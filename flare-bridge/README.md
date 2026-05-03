# FlareBridge Infrastructure

This workspace manages the infrastructure for the FlareBridge project using Cloudflare-native services.

## Architecture

The project has been migrated from Cloudflare Pages to a more flexible architecture using:

- **Cloudflare Workers**: Handles the aggregation logic and serves the feeds.
- **Cron Triggers**: Executes the worker on an hourly schedule (`0 * * * *`).
- **Custom Domain**: Bound to `feeds.roccosmodernsite.net`.
- **IP-Based Lockdown**: Ingress is restricted via Cloudflare WAF to the Miniflux VM's static IP address.

## Components

### Terraform (`terraform/`)

The Terraform configuration provisions:
- `cloudflare_worker`: The worker identity.
- `cloudflare_d1_database`: Persistent storage for feed data.
- `cloudflare_workers_custom_domain`: Routing for the custom domain.

The `d1_database_id` output provides the ID required for the `DB` binding in the application's `wrangler.toml`.

Note: The WAF ruleset that enforces the IP lockdown is managed in the central `cloudflare/terraform` workspace to avoid ruleset limits.

## Deployment

1.  **Prerequisites**:
    - Cloudflare API Token with `Account.Worker Scripts`, `Zone.Workers Routes`, and `Zone.DNS` permissions.

2.  **Workflow**:
    ```bash
    cd terraform/
    terraform init
    terraform plan
    terraform apply
    ```

3.  **Note on Order**: The Cloudflare API requires a worker to have at least one active deployment before a Custom Domain or Cron Trigger can be attached. Terraform `depends_on` blocks are used to enforce this.
