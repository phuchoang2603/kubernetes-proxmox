# RKE2 Kubernetes on Proxmox with Terraform + Ansible

This project automates the provisioning and configuration of a RKE2 Kubernetes cluster on Proxmox using Terraform and Ansible. Using GitHub Actions and HashiCorp Vault, the project achieves a fully automated CI/CD pipeline with centralized secret management.

**Demo Video**:

[![Demo Video](https://img.youtube.com/vi/G83csoZYCWQ/0.jpg)](https://youtu.be/G83csoZYCWQ)

## Motivation

This project began with a simple goal: create automatable scripts to spin up a Kubernetes cluster on Proxmox to learn more about its internals. Initially, I achieved this by running Terraform and Ansible from my laptop as a client. 

However, one day, my laptop died. I lost all my local `.env` files, configurations, and `tfstate` files, forcing me to re-bootstrap everything from scratch. 

That experience shifted the focus of this project. I realized that true infrastructure-as-code should not depend on a single machine. I decided to utilize **HashiCorp Vault** for centralized secret management, **GitHub Actions** for a portable CI/CD pipeline, and **MinIO** for remote Terraform state storage. This ensures the cluster can be managed, recovered, and scaled from anywhere, regardless of the local client's state.

## Quick Start

1. **Configure HashiCorp Vault**: Follow the [Vault Setup Guide](docs/vault-setup.md) to set up secrets and OIDC authentication.
2. **Set up GitHub Actions**: Configure the [Automated Deployment](docs/github-actions-setup.md) to enable CI/CD pipelines.
3. **Access your cluster**: Follow the [Cluster Access Guide](docs/cluster-access.md) to configure kubectl with OIDC.
4. **Integrate Secrets**: Use the [External Secrets Operator - Vault Integration](/docs/external-secrets-vault-integration.md) to sync secrets into your cluster.

## Usage

### Terraform Provisioning (`terraform-provision/`)
Terraform handles the infrastructure layer:
1. Initializes with S3 backend for state management.
2. Retrieves Proxmox credentials from Vault.
3. Provisions Ubuntu-based VMs for Kubernetes and Longhorn nodes.

### Ansible Configuration (`ansible/`)
Ansible handles the software and cluster layer:
1. Generates inventory and authenticates via Vault SSH CA.
2. Installs RKE2 with OIDC integration.
3. Deploys `kube-vip` for High Availability.
4. Deploys essential apps (cert-manager, Traefik, Longhorn, ArgoCD) via the `deploy_helm_apps` role.

For local execution, see the [Manual Deployment Guide](docs/manual-deployment.md).

## Contributing

This project uses **Nix flakes** and **direnv** to manage a reproducible development environment including all necessary tools (Terraform, Ansible, etc.). To get started:

1. Install [Nix](https://nixos.org/download.html).
2. Install [direnv](https://direnv.net/docs/installation.html).
3. Run `direnv allow` in the project root to load the environment automatically.

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change. 

Ensure that you update tests as appropriate and follow the project's coding standards.
