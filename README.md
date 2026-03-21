# Rocjay Infrastructure

This repository centralizes the infrastructure-as-code (IaC) and configuration management for various projects in the Rocjay ecosystem. It uses Terraform for provisioning and Ansible for configuration management.

## Project Structure

The repository is organized into workspaces for different applications and shared services:

- **[balance-tracker](balance-tracker/)**: Infrastructure and deployment logic for the Balance Tracker application, including Terraform for Cloudflare/Azure and Ansible for host management.
- **[cloudflare](cloudflare/)**: Shared Cloudflare configurations and global infrastructure settings.
- **[feed-aggregator](feed-aggregator/)**: Infrastructure provisioning for the Feed Aggregator project.
- **[miniflux](miniflux/)**: Infrastructure and deployment logic for the Miniflux RSS reader, utilizing Terraform for Cloudflare Tunnels and Ansible for container orchestration.

## Technologies Used

- **Terraform**: Infrastructure provisioning (Cloudflare, Azure).
- **Ansible**: Host configuration and Docker-based application deployment.
- **Cloudflare Tunnels**: Secure exposure of internal services.
- **Docker**: Containerized application environments.

## Getting Started

Each directory contains its own specific documentation and requirements. Refer to the `README.md` within each workspace for detailed instructions.
