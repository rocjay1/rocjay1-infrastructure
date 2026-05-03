# Rocjay Infrastructure

This repository centralizes the infrastructure-as-code (IaC) and configuration management for various projects in the Rocjay ecosystem. It uses Terraform for provisioning and Ansible for configuration management.

## Project Structure

The repository is organized into workspaces for different applications and shared services:

- **[ansible](ansible/)**: Shared Ansible roles (e.g., `debian_docker_host`) for centralized host configuration, security, and maintenance across various projects.
- **[cloudflare](cloudflare/)**: Shared Cloudflare configurations and global infrastructure settings (DNSSEC, geo-blocking, Zero Trust Identity Provider).
- **[flare-bridge](flare-bridge/)**: Infrastructure provisioning for the FlareBridge project.
- **[miniflux](miniflux/)**: Infrastructure and deployment logic for the Miniflux RSS reader, utilizing Terraform for Cloudflare Tunnels and Ansible for container orchestration.
- **[terraform/modules](terraform/modules/)**: Shared Terraform modules (e.g., `cloudflare_tunnel_app`) reusable across application workspaces.
- **[GEMINI.md](GEMINI.md)**: Agent instructions and repository-wide standards for AI assistants working in this codebase.

## Technologies Used

- **Terraform**: Infrastructure provisioning (Cloudflare, Azure Entra ID).
- **Ansible**: Host configuration and Docker-based application deployment.
- **Cloudflare Tunnels**: Secure exposure of internal services.
- **Docker**: Containerized application environments.
- **Google Cloud**: Compute Engine for Miniflux and Google Cloud Storage for remote Terraform state.

## Getting Started

Each directory contains its own specific documentation and requirements. Refer to the `README.md` within each workspace for detailed instructions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
