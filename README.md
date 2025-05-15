# Kubernetes Bare-Metal Cluster Automation (Proxmox + RKE2)

This project automates the provisioning and bootstrapping of a **Kubernetes cluster on Proxmox VE** using:

- **Terraform** for VM lifecycle management.
- **Ansible** for cluster installation and configuration using **RKE2**.

- Blog post:
- Video demo:
  [![Youtube video](https://img.youtube.com/vi/Ao6IPSmUFcE/maxresdefault.jpg)](https://youtu.be/Ao6IPSmUFcE)

---

## 🔗 Components Overview

### 🖥 Terraform (VM Provisioning)

Located in: `terraform/`

- **Modules:**

  - `vm-template`: Create a cloud-init-ready VM template.
  - `k8s-cluster`: Provision Kubernetes nodes from template, using cloud-init custom snippets.

- **Makefile driven workflow** (init, apply, destroy).
- Provider: [bpg/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox)

📄 Detailed docs: [Terraform README](./terraform/README.md)

---

### 🛠 Ansible (Cluster Bootstrap)

Located in: `ansible/`

- Generate dynamic `hosts.ini` from `k8s_nodes.json`.
- Sync `.env` variables into Ansible group variables.
- Automate:

  - RKE2 installation.
  - Cluster initialization (master, agent nodes).
  - MetalLB, IP pool, L2 Advertisement setup.

📄 Detailed docs: [Ansible README](./ansible/README.md)

---

## 🚀 Workflow Summary

### 1. Provision VMs with Terraform

1. Create VM template (`terraform/vm-template`).
2. Provision Kubernetes nodes (`terraform/k8s-cluster`).
3. Use `make` commands inside `terraform/`:

   ```bash
   make init MODULE=vm-template
   make apply MODULE=vm-template

   make init MODULE=k8s-cluster
   make apply MODULE=k8s-cluster
   ```

### 2. Bootstrap Kubernetes with Ansible

1. Generate `hosts.ini`:

   ```bash
   cd ansible
   ./gen_ansible_host.py -j ../k8s_nodes.json -o inventory/hosts.ini
   ```

2. Sync environment variables:

   ```bash
   ./sync_ansible_env.py -e ../.env -y inventory/group_vars/all.yaml
   ```

3. Run Ansible playbook:

   ```bash
   ansible-playbook -i inventory/hosts.ini site.yaml
   ```

---

## 📦 Project Structure

```
.
├── ansible/        # Ansible playbooks, inventory, helpers
├── terraform/      # Terraform modules and VM provisioning logic
├── k8s_nodes.json  # Cluster node definitions (IP, role, VM ID)
├── .env            # Environment variables (API, SSH, VIP, etc.)
├── id_ed25519.pub  # SSH public key used by cloud-init
└── Makefile        # Unified entry for Terraform modules
```

---

## 💡 Notes & Recommendations

- Ensure **Proxmox nodes have unique hostnames**.
- Adjust **Ansible playbooks to make server scaling dynamic** (currently hardcoded to 3).
- MetalLB configurations (IP pool, L2Advertisement) can be adjusted inside Ansible group vars.
