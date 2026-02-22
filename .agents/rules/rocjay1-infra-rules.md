---
trigger: always_on
---

## Infrastructure as Code (IaC)

- **Terraform**:
  - Always run `terraform fmt` on modified files.
  - Proactively check `terraform plan` before suggesting execution.
- **Ansible**:
  - Ensure playbooks are idempotent.
  - Handle secrets securely via `ansible-vault` and reference `.vault_pass` when working in the `ansible/` directory.

## Docker & Containers

- **Observability**: When services fail, prioritize checking container logs (`docker logs`) and health checks.
