terraform {
  required_version = ">= 1.6.6"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.0.0"
    }
  }
  backend "s3" {
    bucket = "terraform"
    key    = "admin.tfstate"
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

provider "vault" {
  # The Vault address and token must be set in the VAULT_ADDR and VAULT_TOKEN environment variable.
}
