terraform {
  required_version = ">= 1.6.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.10.0"
    }
  }
  backend "s3" {
    bucket = "terraform"
    region = "us-east-1"
    endpoints = {
      s3 = "http://10.69.1.102:9000"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure
  min_tls  = var.proxmox_min_tls
  username = var.proxmox_username
  password = var.proxmox_password
}

provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
}
