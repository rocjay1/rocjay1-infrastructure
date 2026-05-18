# Ansible Roles

This document describes the shared Ansible roles used across the Rocjay ecosystem.

## debian_docker_host

Baseline Ansible role for configuring a Debian-based Docker host with standard security hardening and maintenance.

### Design Philosophy

This role is designed to be a **lean baseline**. It focuses on host-level security and lifecycle management, assuming that complex network-level security (like firewalling) is handled at the infrastructure layer (e.g., GCP VPC Firewalls or AWS Security Groups).

### Security Model

- **SSH Hardening:** Disables password authentication and root login. Requires SSH keys for access.
- **Auto-Updates:** Configures `unattended-upgrades` for automatic security patches.
- **Firewall (UFW) Omitted:**
  - **Rationale:** Host-level firewalls like UFW often conflict with Docker's `iptables` management.
  - **Security-in-Depth:** Network-level firewalls (managed via Terraform) provide a more robust perimeter. For generic hosts without a VPC, a separate firewall/fail2ban role should be used.
- **Privilege Escalation:** Assumes `sudo` access for the `ansible_user`.

### Components

- **Docker Engine:** Installs the official Docker CE and Compose plugin.
- **Maintenance:** Sets up weekly Docker system prunes and handles reboot-required notifications.
- **Logging:** Default configuration uses the `json-file` driver. Specialized roles (like `gcp_host`) override this to use platform-native logging (e.g., `gcplogs`).

### Usage (debian_docker_host)

This role is intended to be used as a dependency for platform-specific roles:

```yaml
# meta/main.yml of a child role
dependencies:
  - role: debian_docker_host
```

## gcp_host

A GCP-specific wrapper role that extends `debian_docker_host` with platform-native observability.

### Features

- **Google Cloud Ops Agent**: Automatically installs and configures the Ops Agent for system and application metrics.
- **Logging**: Overrides the default Docker logging driver to use `gcplogs`, routing all container logs directly to Google Cloud Logging.

### Usage (gcp_host)

This role should be used for all VMs running in Google Cloud.

```yaml
- name: Configure GCP host
  hosts: all
  roles:
    - role: gcp_host
```
