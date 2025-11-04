# RKE2 Kubernetes on Proxmox with Terraform + Ansible

This project automates the provisioning and configuration of a RKE2 Kubernetes cluster on **Proxmox** using **Terraform** and **Ansible**.

**Features:**

- `S3-compatible` object storage for `Terraform` remote state
- Separate `dev` and `prod` environments
- Multiple-node `Proxmox` cluster support

**Pre-deployed applications:**

- `kube-vip` for a high-availability virtual IP
- SSL via `cert-manager` with `Cloudflare` DNS
- `Longhorn` for persistent storage
- `ArgoCD` for GitOps deployments

**Blog post:** <https://phuchoang.sbs/posts/terraform-ansible-proxmox-k8s/>

**Video demo:**
[![Youtube video](https://img.youtube.com/vi/Ao6IPSmUFcE/maxresdefault.jpg)](https://youtu.be/Ao6IPSmUFcE)

---

## Clone the Repository

```bash
git clone https://github.com/phuchoang2603/kubernetes-proxmox
cd kubernetes-proxmox
```

---

## Initial Setup

Before proceeding, run the `pre-setup.sh` script to install essential tools like `mise`, `kubectl`, `helm`, and `kubectx`.

```bash
./scripts/pre-setup.sh
cd terraform
mise use terraform
```

---

## Terraform Operations: Create VMs

### 1. Set Up Environment Variables

Customize your VM specifications, hostnames, and IP addresses in `terraform/env/dev/k8s_nodes.json` based on your environment (dev or prod). All other environment variables are located in `terraform/env/dev/main.tfvars`.

### 2. Initialize Backend and Variables

To manage different environments (e.g., `dev` and `prod`), it is best practice to use `init -reconfigure`. This prevents conflicts and ensures that you are working in the correct environment.

```bash
terraform init -reconfigure -backend-config=env/dev/backend.hcl
# For production:
# terraform init -reconfigure -backend-config=env/prod/backend.hcl
```

### 3. Apply Terraform Changes

To apply the Terraform configuration and provision the VMs, use the appropriate variables for your selected environments:

```bash
terraform apply -var-file="env/dev/main.tfvars"
# For production:
# terraform apply -var-file="env/prod/main.tfvars"
```

### 4. Destroy Terraform Resources

To destroy all resources provisioned by Terraform in the current environments:

```bash
terraform destroy -var-file="env/dev/main.tfvars"
# For production:
# terraform destroy -var-file="env/prod/main.tfvars"
```

### How it Works

- Configures the backend state to use Amazon S3 or a local backend.
- Downloads the base cloud-init image.
- Creates snippets to inject values into the cloud-init configuration.
- Provisions Kubernetes and (optionally) Longhorn VMs on Proxmox.

---

## Ansible: Install Kubernetes on VMs

### 1. Set up Ansible and Environments

It is recommended to use `uv` to manage the Python virtual environment. If you choose not to, ensure that you have Ansible and the required collections installed in your environment.

```bash
uv venv
source .venv/bin/activate
uv sync
```

Customize the hostnames and IP addresses of the machines in `ansible/inventory/hosts.ini`. Change all other environment variables in `ansible/inventory/group_vars/all.yaml`.

### 2. Run the Ansible Playbook

To execute the playbook, run the following command from the `ansible` directory:

```bash
ansible-playbook site.yaml
```

You can also run specific parts of the playbook by using tags:

```bash
# Example: Only apply the SSL-related roles
ansible-playbook site.yaml --tags ssl
```

### How it Works

The Ansible playbook automates the following tasks:

- **Prepare all nodes**: Prepares all nodes and downloads RKE2.
- **Deploy Kube VIP**: Deploys `kube-vip` for a high-availability virtual IP.
- **Prepare RKE2 on Servers**: Prepares the RKE2 configuration on the server nodes.
- **Add additional RKE2 Servers**: Joins additional server nodes to the cluster.
- **Add additional RKE2 Agents**: Joins agent nodes to the cluster.
- **Add additional RKE2 longhorn**: Adds Longhorn agents to the cluster with the `longhorn=true` tag.
- **Apply Cert-Manager & Traefik manifests**: Applies the manifests for `cert-manager` and `Traefik`.
- **Deploy Optional services**: Deploys optional services such as `Longhorn` and `ArgoCD`.

---

## Credits

- Inspired by [JimsGarage RKE2 Ansible Playbooks](https://github.com/JamesTurland/JimsGarage)
- Built with the [bpg Proxmox Terraform Provider](https://registry.terraform.io/providers/bpg/proxmox/latest)

---

## Utilities

### Auto-generate Ansible hosts.ini file

If you don't want to parse the IP and node-name from `terraform/env/dev/k8s_nodes.json` to `ansible/inventory/hosts.ini` manually, you can use the following script (make sure to change the file path in the script accordingly):

```bash
./scripts/generate-all-hosts.sh

```

### Clean Up SSH Known Hosts

If you encounter SSH connection issues or need to clear old host entries, you can use the following script:

```bash
./scripts/clean-up-ssh-known-hosts.sh
```
