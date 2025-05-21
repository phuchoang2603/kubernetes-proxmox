# 🧠 RKE2 Kubernetes on Proxmox with Terraform + Ansible

This project automates the provisioning and configuration of a RKE2 Kubernetes cluster on **Proxmox** using **Terraform** and **Ansible**, with optional components:

- 📦 Longhorn for persistent storage
- 🔐 SSL via cert-manager with Cloudflare DNS
- 🕹️ kube-vip for high availability virtual IP

- Blog post: <https://phuchoang.sbs/posts/terraform-ansible-proxmox-k8s/>
- Video demo:
  [![Youtube video](https://img.youtube.com/vi/Ao6IPSmUFcE/maxresdefault.jpg)](https://youtu.be/Ao6IPSmUFcE)

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/phuchoang2603/kubernetes-proxmox
cd kubernetes-proxmox
```

### 2. Set Up Environment Variables

```bash
cp .env.example .env
# Then edit .env to reflect your Proxmox IP, credentials, Cloudflare token, etc.
```

### 3. Proxmox Setup

1. **Create Terraform user**

   ```bash
   sudo pveum user add terraform@pve
   ```

2. **Create role (optional)**

   ```bash
   sudo pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"
   ```

3. **Assign role to user**

   ```bash
   sudo pveum aclmod / -user terraform@pve -role Terraform
   ```

4. **Generate API token**

   ```bash
   sudo pveum user token add terraform@pve provider --privsep=0
   ```

   Example token:

   ```
   terraform@pve2!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```

---

### 4. SSH Setup

1. **Generate SSH key pair**

   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/proxmox_terraform
   ```

2. **Create and configure Proxmox user**

   ```bash
   useradd -m -s /bin/bash terraform
   echo "terraform:yourpassword" | chpasswd
   usermod -aG sudo terraform
   echo "terraform ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/terraform
   ```

3. **Send SSH key to Proxmox node**

   ```bash
   ssh-copy-id -i ~/.ssh/proxmox_terraform.pub terraform@<proxmox-node-ip>
   ```

4. **Test SSH and API access**

   ```bash
   ssh -i ~/.ssh/proxmox_terraform terraform@<proxmox-node-ip>
   sudo pvesm apiinfo
   ```

---

### 5. Set Up Ansible

```bash
uv venv
uv sync
```

---

### 6. Run the Master Script

```bash
cd scripts
./master.sh
```

---

## 🧰 What the Master Script Does

The `master.sh` script orchestrates everything:

### 🔨 Phase 1: Terraform – Provisioning

- Downloads the base cloud-init image
- Provisions Kubernetes and (optionally) Longhorn VMs on Proxmox

### ⚙️ Phase 2: Known Host Cleanup

- Removes stale SSH fingerprints to avoid Ansible conflicts

### 🤖 Phase 3: Ansible – Cluster Bootstrap

- Installs RKE2 (Kubernetes)
- Configures kube-vip, Longhorn, and cert-manager + Cloudflare if enabled

---

## 🧪 Feature Flags

All features are enabled by default. You can selectively skip any of them:

```bash
./master.sh --skip-longhorn --skip-ssl --skip-kube_vip
```

| Feature                          | Enabled by Default | Skip Flag         |
| -------------------------------- | ------------------ | ----------------- |
| Longhorn                         | ✅ Yes             | `--skip-longhorn` |
| SSL (Let's Encrypt + Cloudflare) | ✅ Yes             | `--skip-ssl`      |
| kube-vip                         | ✅ Yes             | `--skip-kube_vip` |

---

## ☁️ Terraform

This project uses the [bpg/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox) for better control over Proxmox VMs and cloud-init.

### Modules

- `cloud-img-download`: Downloads the base image
- `k8s-cluster`: Provisions Kubernetes nodes using `k8s_nodes.json`
- `longhorn-cluster`: (Optional) Provisions Longhorn nodes using `longhorn_nodes.json`

---

## 🧠 Ansible

Ansible handles the full lifecycle of Kubernetes configuration:

- RKE2 cluster install
- kube-vip configuration
- SSL setup with cert-manager and Cloudflare DNS
- Longhorn deployment

---

## 🔐 SSL via Cert-Manager + Cloudflare

Cert-manager uses **DNS-01 challenges** with Cloudflare to issue wildcard TLS certificates.

Update your `.env` file with:

```env
ssl_cloudflare_api_token=<your_token>
ssl_email=you@example.com
ssl_local_domain=your.domain.com
```

---

## 📍 Accessing Longhorn

Once deployed:

- Access Longhorn at: `https://longhorn.<your.domain.com>`
- Secured with **TLS via Let's Encrypt** (if SSL feature is enabled)
- Uses Ingress with DNS-01 + cert-manager for certificate provisioning

---

## 📜 Credits

- Inspired by [JimsGarage RKE2 Ansible Playbooks](https://github.com/JamesTurland/JimsGarage)
- Built with [bpg Proxmox Terraform Provider](https://registry.terraform.io/providers/bpg/proxmox/latest)
