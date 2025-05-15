# Terraform Proxmox Kubernetes Cluster Deployment

Provision Kubernetes VMs on Proxmox using **Terraform** and **Cloud-Init custom snippets**.

---

## 🔗 Resources

- [bpg/terraform-provider-proxmox](https://github.com/bpg/terraform-provider-proxmox) (recommended for advanced features)
- [Telmate/terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox) (legacy)
- [bpg Provider Docs](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#environment-variables-summary)

---

## 🚀 Prerequisites

- Proxmox node `pve` with:

  - **Local storages** `local` and `local-lvm`
  - **Snippets** content type enabled on `local`
  - Linux bridge `vmbr0` VLAN-aware (`Datacenter -> pve -> Network` -> edit & apply)

---

## 🔑 Proxmox API Setup

1. **Create Terraform user**

   ```bash
   sudo pveum user add terraform@pve
   ```

2. **Create role (optional if using existing roles)**

   ```bash
   sudo pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"
   ```

3. **Assign the role**

   ```bash
   sudo pveum aclmod / -user terraform@pve -role Terraform
   ```

4. **Create API token**

   ```bash
   sudo pveum user token add terraform@pve provider --privsep=0
   ```

Example token:

```
terraform@pve2!provider=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

---

## 🔐 SSH Setup

1. **Generate SSH key pair**

   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/proxmox_terraform
   ```

2. **Create user on Proxmox node**

   ```bash
   useradd -m -s /bin/bash terraform
   echo "terraform:yourpassword" | chpasswd
   usermod -aG sudo terraform
   echo "terraform ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/terraform
   ```

3. **Send SSH key**

   ```bash
   ssh-copy-id -i ~/.ssh/proxmox_terraform.pub terraform@<proxmox-node-ip>
   ```

4. **Test access**

   ```bash
   ssh -i ~/.ssh/proxmox_terraform terraform@<proxmox-node-ip>
   sudo pvesm apiinfo
   ```

---

## 📋 Usage Flow

1. **Create VM Template**

   - Use the `vm-template` module to download cloud-init image and create VM template.

2. **Provision Kubernetes Cluster VMs**

   - Use the `k8s-cluster` module.
   - Nodes and settings configured via `k8s_nodes.json`.
   - Uses cloud-init **custom snippets (meta-data, user-data)**.

---

## 💻 How to Run

```bash
# View available commands
make help

# Initialize Terraform module
make init MODULE=<module-name>

# Apply Terraform module
make apply MODULE=<module-name>

# Destroy module resources
make destroy MODULE=<module-name>
```

Example directory structure:

```
k8s-cluster/
vm-template/
Makefile
```

---

## ⚠ Notes

- Using **separate custom snippets per VM in `k8s-cluster` currently shows quirks** (ref [bpg docs](https://github.com/bpg/terraform-provider-proxmox/blob/a05c941de5ac914c6bddc8addf3b284d632d0dff/docs/guides/cloud-init.md?plain=1#L69)).
- Workarounds are used to inject `local-hostname` dynamically via meta-data snippets.
