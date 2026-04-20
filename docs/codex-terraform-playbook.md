# Codex Terraform Playbook

This document defines the repeatable workflow Codex should follow when working with Terraform in this repository.

## Standard workflow
1. Navigate to the correct workspace:
   - Example: `balance-tracker/terraform`

2. Format and validate:
   ```bash
   terraform fmt -recursive
   terraform init -input=false
   terraform validate
   ```

3. Plan changes (if needed):
   ```bash
   terraform plan -input=false
   ```

4. Never apply unless explicitly instructed.

---

## Workspace order (important)
1. cloudflare/terraform (shared infra)
2. Application workspaces (depend on shared outputs)

---

## Common failure modes

### Provider install fails
- Cause: no internet access
- Fix: enable Codex environment internet access

### Backend init fails
- Cause: missing GCS credentials
- Fix: ensure `GOOGLE_APPLICATION_CREDENTIALS` is set

### Cloudflare auth fails
- Cause: missing API token
- Fix: set `CLOUDFLARE_API_TOKEN`

---

## Safe defaults
- Prefer validate over plan
- Prefer plan over apply
- Always explain infra impact before changes

---

## When modifying modules
- Check all consumers under:
  - `balance-tracker/terraform`
  - `miniflux/terraform`
- Call out breaking changes explicitly

---

## Summary expectation
Every Codex run should clearly state:
- workspace used
- commands executed
- validation result
- any missing credentials or blockers
