# Changelog

All notable changes to the Rocjay Infrastructure project will be documented in this file. This project uses a date-based versioning scheme.

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
