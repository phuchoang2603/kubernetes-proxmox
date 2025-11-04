terraform {
  required_version = ">= 1.6.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
  backend "s3" {
    bucket                      = var.s3_bucket
    key                         = var.s3_key
    region                      = var.s3_region
    endpoint                    = var.s3_endpoint
    access_key                  = var.s3_access_key
    secret_key                  = var.s3_secret_key
    skip_credentials_validation = var.s3_skip_credentials_validation
    skip_metadata_api_check     = var.s3_skip_metadata_api_check
    skip_region_validation      = var.s3_skip_region_validation
    force_path_style            = var.s3_force_path_style
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = var.proxmox_insecure
  min_tls  = var.proxmox_min_tls
  username = var.proxmox_username
  password = var.proxmox_password
}
