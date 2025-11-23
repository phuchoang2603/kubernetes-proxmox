# Manual Deployment

This guide covers running Terraform and Ansible locally from your machine.

**Blog post:** <https://phuchoang.sbs/posts/on-premise-provison-ansible/>

![Manual Deployment](./img/img.png)

## Prerequisites

- Terraform installed
- Ansible installed
- SSH access to Proxmox
- S3-compatible storage (MinIO) for Terraform state
- Direct network access to Proxmox and target VMs

## Step 1: Configure Environment Variables

Set up your local environment with necessary credentials:

```bash
# Proxmox credentials
export PM_API_URL="https://proxmox.example.com:8006/api2/json"
export PM_USER="root@pam"
export PM_PASSWORD="your-password"

# S3 backend for Terraform state
export AWS_ACCESS_KEY_ID="your-minio-access-key"
export AWS_SECRET_ACCESS_KEY="your-minio-secret-key"
```

## Step 2: Update VM Configurations

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

## Step 3: Provision Infrastructure with Terraform

```bash
cd terraform-provision

# Initialize Terraform
terraform init

# Plan changes
terraform plan -var-file=env/dev/main.tfvars

# Apply changes
terraform apply -var-file=env/dev/main.tfvars
```

## Step 4: Configure Cluster with Ansible

```bash
cd ../ansible

# Generate inventory from JSON files
../scripts/generate-all-hosts.sh

# Run the playbook
ansible-playbook -i inventory/hosts.ini site.yaml
```

## Step 5: Deploy Applications

Applications are automatically deployed via the `deploy_helm_apps` role during Ansible execution. To modify or add applications, edit `ansible/inventory/group_vars/all/helm.yaml`.

## Destroy Infrastructure

```bash
cd terraform-provision
terraform destroy -var-file=env/dev/main.tfvars
```

## Next Steps

After deployment completes, see [Cluster Access](./cluster-access.md) for instructions on accessing your cluster.
