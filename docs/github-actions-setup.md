# GitHub Actions Automated Deployment

This guide covers setting up fully automated CI/CD pipeline with GitHub Actions and HashiCorp Vault.

![GitHub Actions Workflow](./img/img2.png)

## Prerequisites

Before proceeding, ensure you have completed:

- [HashiCorp Vault Setup](./vault-setup.md)
- Tailscale account for secure network access (Optional)
- GitHub repository with appropriate permissions
- Proxmox cluster with API access
- S3-compatible storage (MinIO) for Terraform state

## Step 1: Update VM Configurations

Edit the JSON files for your environment:

**For Dev:** `terraform-provision/env/dev/k8s_nodes.json` and `longhorn_nodes.json`  
**For Prod:** `terraform-provision/env/prod/k8s_nodes.json` and `longhorn_nodes.json`

Example `k8s_nodes.json`:

```json
[
  {
    "hostname": "k8s-server-01",
    "ip": "10.69.0.11"
  },
  {
    "hostname": "k8s-server-02",
    "ip": "10.69.0.12"
  }
]
```

## Step 2: Set GitHub Variables

Navigate to your GitHub repository → Settings → Secrets and variables → Actions → Variables:

| Variable Name | Value                       | Description                                              |
| ------------- | --------------------------- | -------------------------------------------------------- |
| `ENV_NAME`    | `dev` or `prod`             | Environment to deploy                                    |
| `VAULT_ADDR`  | `https://vault.example.com` | Vault server address (used to construct OIDC issuer URL) |
| `DESTROY`     | `false`                     | Set to `true` to destroy infrastructure                  |

**Note:** The OIDC issuer URL and client ID are automatically constructed from these variables:

- OIDC Issuer URL: `${VAULT_ADDR}/v1/identity/oidc/provider/${ENV_NAME}`
- OIDC Client ID: `${ENV_NAME}-kubernetes`

## Step 3: Set GitHub Secrets (Optional)

If you don't want to use self-hosted GitHub Actions, you can get the runner access to your private network using Tailscale VPN. Navigate to Secrets tab and add:

| Secret Name          | Value                          | Description    |
| -------------------- | ------------------------------ | -------------- |
| `TS_OAUTH_CLIENT_ID` | Your Tailscale OAuth client ID | For VPN access |
| `TS_OAUTH_SECRET`    | Your Tailscale OAuth secret    | For VPN access |

## Step 4: Deploy via GitHub Actions

The deployment happens automatically:

1. **On Pull Request**: Plans Terraform changes and posts a comment with the plan
2. **On Push to Master**: Applies Terraform changes and runs Ansible playbook

### Workflow Steps

1. Runs linting checks (Terraform + Ansible)
2. Connects to Tailscale VPN for private network access
3. Authenticates to Vault via JWT (no GitHub secrets needed!)
4. Retrieves all secrets dynamically from Vault
5. Provisions VMs with Terraform (terraform-provision/)
6. Configures RKE2 cluster with Ansible (with Vault OIDC pre-configured from GitHub variables)
7. Deploys all applications via data-driven `deploy_helm_apps` role

## Destroy Infrastructure

1. Set GitHub variable `DESTROY=true`
2. Push to master or manually trigger workflow
3. GitHub Actions will run `terraform destroy`

## Next Steps

After deployment completes, see [Cluster Access](./cluster-access.md) for instructions on accessing your cluster.
