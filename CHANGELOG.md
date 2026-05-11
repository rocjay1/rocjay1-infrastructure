# Changelog

All notable changes to the Rocjay Infrastructure project will be documented in this file. This project uses a date-based versioning scheme.

## [2026-05-11]

### Changed

- Reorganized and cleaned up `mkdocs.yml` configuration for better maintainability.
- Updated site and repository metadata in MkDocs to align with the `rocjay1` namespace.

## [2026-05-10]

### Added

- Provisioned CNAME record for `docs.roccosmodernsite.net` pointing to `rocjay1.github.io` to support a namespace-wide GitHub Pages custom domain.

## [2026-05-09]

### Added

- Implemented automated **Terraform Drift Detection** for all workspaces (`cloudflare`, `google-cloud`, `flare-bridge`, `miniflux`).
- Created GitHub Actions workflow `drift.yml` to run weekly scans and open PRs for detected drift.
- Provisioned Workload Identity Federation (WIF) support for the `rocjay1-infrastructure` repository.
- Added `.markdownlint.json` to globally disable line length limits and duplicate heading warnings.

### Changed

- Renamed the `management/` workspace to `google-cloud/` and migrated Terraform state in GCS.
- Refactored `google-cloud` and `miniflux` workspaces to split monolithic configurations into logical, domain-specific files (`apis.tf`, `iam.tf`, `network.tf`, `compute.tf`).
- Refactored `google-cloud` WIF permissions to support multiple repositories using `for_each`.
- Added comprehensive structural comments across all major Terraform configurations to improve readability.
- Cleaned up outdated configuration references in README files for `miniflux`, `google-cloud`, and `flare-bridge`.

### Removed

- Removed redundant `miniflux_egress` firewall rule from GCP configuration.

### Earlier on [2026-05-09]

- Created a new `management/` workspace for shared administrative infrastructure.
...
- Implemented **Workload Identity Federation (WIF)** for secure, keyless authentication from GitHub Actions to Google Cloud.
- Provisioned a `terraform-drift-detector` service account for automated Terraform drift detection in the `github-mgmt` repository.
- Implemented secure WAF allowlist for Google Cloud Uptime Checks using a secret header.
- Added custom header configuration to Miniflux uptime monitoring.

## [2026-05-06]

### Fixed

- Cleaned up Ansible warnings and deprecations in the `miniflux` workspace and shared roles (issue #23).
  - Explicitly set `ansible_python_interpreter` to resolve discovery warnings.
  - Disabled `inject_facts_as_vars` and updated playbooks/roles to use the `ansible_facts` dictionary.

### Removed

- Decommissioned YouTube Transcript microservice and all associated GCP infrastructure (Cloud Run, Artifact Registry, Workload Identity Pool).
- Cleaned up YouTube Transcript terraform workspace and repository references.

## [2026-05-05]

### Added

- Provisioned YouTube Transcript microservice on GCP Cloud Run.
- Created Artifact Registry for microservice Docker images.
- Initialized `CHANGELOG.md` to track infrastructure changes.
