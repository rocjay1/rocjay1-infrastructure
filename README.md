# Rocjay Infrastructure

This repository centralizes the infrastructure-as-code (IaC) and configuration management for various projects in the Rocjay ecosystem. It uses Terraform for provisioning and Ansible for configuration management.

## Project Structure

The repository is organized into workspaces for different applications and shared services:

- **[ansible](ansible/)**: Shared Ansible roles (e.g., `pi_baseline`) for centralized host configuration, security, and maintenance across various projects.
- **[cloudflare](cloudflare/)**: Shared Cloudflare configurations and global infrastructure settings (DNSSEC, geo-blocking, Zero Trust Identity Provider).
- **[codex](codex/)**: Google Cloud resources for non-interactive Codex Terraform workflows.
- **[feed-aggregator](feed-aggregator/)**: Infrastructure provisioning for the Feed Aggregator project.
- **[miniflux](miniflux/)**: Infrastructure and deployment logic for the Miniflux RSS reader, utilizing Terraform for Cloudflare Tunnels and Ansible for container orchestration.
- **[terraform/modules](terraform/modules/)**: Shared Terraform modules (e.g., `cloudflare_tunnel_app`) reusable across application workspaces.

## Technologies Used

- **Terraform**: Infrastructure provisioning (Cloudflare, Azure Entra ID).
- **Ansible**: Host configuration and Docker-based application deployment.
- **Cloudflare Tunnels**: Secure exposure of internal services.
- **Docker**: Containerized application environments.
- **Google Cloud Storage**: Remote Terraform state backend.

## Getting Started

Each directory contains its own specific documentation and requirements. Refer to the `README.md` within each workspace for detailed instructions.
