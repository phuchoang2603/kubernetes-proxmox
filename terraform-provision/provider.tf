terraform {
  required_version = ">= 1.6.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
  backend "s3" {}
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure
  min_tls  = var.proxmox_min_tls
  username = var.proxmox_username
  password = var.proxmox_password
}
