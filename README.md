# RKE2 Kubernetes on Proxmox with Terraform + Ansible

This project automates the provisioning and configuration of a RKE2 Kubernetes cluster on Proxmox using Terraform and Ansible. Using GitHub Actions and HashiCorp Vault, the project achieves a fully automated CI/CD pipeline with centralized secret management.

**Demo Video**:

[![Demo Video](https://img.youtube.com/vi/G83csoZYCWQ/0.jpg)](https://youtu.be/G83csoZYCWQ)

## How It Works

> **Note:** HashiCorp Vault is deployed externally (outside the cluster) and serves as both the secrets manager and OIDC identity provider. This avoids the chicken-and-egg problem where OIDC authentication is required to access the cluster that hosts the OIDC provider.

### Terraform Provisioning (`terraform-provision/`)

1. Initializes Terraform with S3 backend (environment-specific state file)
2. Retrieves Proxmox credentials (from Vault or env vars)
3. Downloads Ubuntu cloud image
4. Creates cloud-init configuration snippets
5. Provisions VMs for Kubernetes and Longhorn nodes

### Ansible Configuration (`ansible/`)

After VMs are ready:

1. Generates inventory from JSON files
2. Authenticates via Vault SSH CA (automated) or standard SSH (manual)
3. Installs RKE2 on server and agent nodes with OIDC integration using Vault as the identity provider
4. Deploys kube-vip for HA virtual IP
5. **Deploys all essential applications via data-driven approach** (`deploy_helm_apps` role):
   - cert-manager with Cloudflare DNS
   - Traefik ingress controller with auto HTTPS
   - Longhorn distributed storage
   - External Secrets Operator, already integrated with HashiCorp Vault
   - ArgoCD for GitOps

All Helm applications are configured in a single data-driven file. To add/modify applications, simply edit `ansible/inventory/group_vars/all/helm.yaml`.

## Deployment Options

### Option A: Automated Deployment (GitHub Actions + Vault)

Fully automated CI/CD pipeline with centralized secret management.

**Quick Start:**

1. [Configure HashiCorp Vault](docs/vault-setup.md) - Set up secrets and OIDC authentication
2. [Set up GitHub Actions](docs/github-actions-setup.md) - Configure automated deployment
3. [Access your cluster](docs/cluster-access.md) - Configure kubectl with OIDC
4. [External Secrets Operator - Vault Integration](/docs/external-secrets-vault-integration.md) - Configure secrets for your pods inside the Cluster

**Blog post:** <https://phuchoang.sbs/posts/gitops-github-actions-hashicorp-vault/>

![Automated Deployment](./docs/img/img2.png)

### Option B: Manual Deployment (Local Execution)

Run Terraform and Ansible locally from your machine.

[Manual Deployment Guide](docs/manual-deployment.md) - Step-by-step local deployment

**Blog post:** <https://phuchoang.sbs/posts/on-premise-provison-ansible/>

![Manual Deployment](./docs/img/img.png)
