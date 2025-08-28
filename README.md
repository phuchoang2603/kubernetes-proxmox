# 🧠 RKE2 Kubernetes on Proxmox with Terraform + Ansible

<!--toc:start-->

- [🧠 RKE2 Kubernetes on Proxmox with Terraform + Ansible](#🧠-rke2-kubernetes-on-proxmox-with-terraform-ansible)
  - [🚀 Getting Started](#🚀-getting-started)
    - [1. Clone the Repository](#1-clone-the-repository)
    - [2. Set Up Environment Variables](#2-set-up-environment-variables)
    - [3. Proxmox Setup (on Proxmox shell)](#3-proxmox-setup-on-proxmox-shell)
    - [4. SSH Setup](#4-ssh-setup)
    - [5. Set Up Ansible & Copy the ssh public key](#5-set-up-ansible-copy-the-ssh-public-key)
    - [6. Run the Master Script](#6-run-the-master-script)
  - [🧰 What the Master Script Does](#🧰-what-the-master-script-does)
    - [🔨 Phase 1: Terraform – Provisioning](#🔨-phase-1-terraform-provisioning)
    - [⚙️ Phase 2: Known Host Cleanup](#️-phase-2-known-host-cleanup)
    - [🤖 Phase 3: Ansible – Cluster Bootstrap](#🤖-phase-3-ansible-cluster-bootstrap)
  - [🧪 Feature Flags](#🧪-feature-flags)
  - [☁️ Terraform](#️-terraform)
    - [Modules](#modules)
  - [🧠 Ansible](#🧠-ansible)
  - [🔐 SSL via Cert-Manager + Cloudflare](#🔐-ssl-via-cert-manager-cloudflare)
  - [📍 Accessing Longhorn](#📍-accessing-longhorn)
  - [📜 Credits](#📜-credits)
  <!--toc:end-->

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

---

### 3. Set Up Ansible & Copy the ssh public key

```bash
cp ~/.ssh/id_ed25519.pub keys/
uv venv
source .venv/bin/activate
uv sync
```

---

### 4. Run the Master Script

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
