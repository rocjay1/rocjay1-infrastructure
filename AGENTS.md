# AGENTS.md

## Repository overview
- This repository is infrastructure-as-code for the Rocjay ecosystem.
- Primary tools are Terraform and Ansible.
- Shared Terraform modules live under `terraform/modules/`.
- Application or service workspaces live under directories such as `cloudflare/`, `miniflux/`, and `feed-aggregator/`.
- Many workspaces use a `terraform/` subdirectory for provisioning and an `ansible/` subdirectory for host configuration and deployment.

## How to work in this repo
- Read the nearest `README.md` before changing a workspace.
- Keep changes scoped to one workspace unless the task explicitly requires cross-workspace changes.
- Prefer small, reviewable edits.
- When changing shared modules in `terraform/modules/`, identify every workspace that could be affected and call that out in the final summary.
- Do not make assumptions about production credentials, tenant IDs, zone IDs, or hostnames.

## Terraform workflow
- Always run Terraform from the relevant workspace `terraform/` directory, not from the repo root.
- Before proposing or committing Terraform changes, run:
  - `terraform fmt -recursive`
  - `terraform init -input=false`
  - `terraform validate`
- If a task needs a plan, run `terraform plan -input=false` from the workspace being changed.
- Never run `terraform apply` or `terraform destroy` unless the user explicitly asks.
- If `terraform init` fails because credentials, backend access, or internet access are unavailable, stop and explain exactly what is missing.
- Do not hand-edit `.terraform/`, lockfiles, or state files unless the task is specifically about them.

## Backend and credentials
- Several Terraform workspaces use a GCS remote backend.
- Expect Terraform init/plan to require access to the configured GCS bucket and provider/plugin downloads.
- Cloudflare workspaces may require `CLOUDFLARE_API_TOKEN`.
- Azure/Entra workspaces may require Azure authentication that is already configured in the execution environment.
- Prefer environment variables or existing auth over writing secrets into `terraform.tfvars`.
- Never commit secrets, tokens, `.tfvars` files with secrets, Ansible vault passwords, or decrypted vault contents.

## Workspace-specific notes
### `cloudflare/terraform`
- This workspace provisions shared Cloudflare and Entra/Zero Trust resources.
- Treat changes here as high impact because other workspaces may depend on its remote-state outputs.
- Be conservative with identity provider, group, and access-policy changes.

### `miniflux/terraform`
- Uses the shared `terraform/modules/cloudflare_tunnel_app` module.
- Provisions the Miniflux Cloudflare Tunnel, DNS, GCP VM, persistent disk, runtime service account, and firewall rules.
- Keep free-tier guardrails intact unless the user explicitly accepts additional cost.
- Do not remove the `miniflux-runtime` VM service account; it is separate from the removed Codex automation service account.

### `ansible/`
- Ansible is used for host configuration and Docker-based deployment.
- Shared Docker host setup lives in `ansible/roles/debian_docker_host`.
- Do not modify encrypted vault files unless the task explicitly requires it.
- Do not print, copy, or transform secret values from vault material.

## Review expectations
- In summaries, state:
  - which workspace was changed,
  - which commands were run,
  - whether validation succeeded,
  - and any credentials, backend access, or network prerequisites still needed.
- Call out blast radius when a change affects shared modules or shared Cloudflare resources.

## Safe defaults
- Prefer read-only investigation first.
- Ask before making irreversible infra changes.
- Favor validation and planning over mutation.
