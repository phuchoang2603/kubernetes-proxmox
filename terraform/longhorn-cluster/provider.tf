terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  insecure  = var.proxmox_insecure
  min_tls   = var.proxmox_min_tls
  username = var.proxmox_username
  password = var.proxmox_password
}


