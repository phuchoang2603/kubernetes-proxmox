terraform {
  required_version = ">= 1.6.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.0.0"
    }
  }
  backend "s3" {}
}

provider "vault" {
  # The Vault address and token must be set in the VAULT_ADDR and VAULT_TOKEN environment variable.
}

provider "proxmox" {
  endpoint = data.vault_generic_secret.proxmox.data["endpoint"]
  insecure = data.vault_generic_secret.proxmox.data["insecure"]
  min_tls  = data.vault_generic_secret.proxmox.data["min_tls"]
  username = data.vault_generic_secret.proxmox.data["username"]
  password = data.vault_generic_secret.proxmox.data["password"]
}
