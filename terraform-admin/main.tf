# Shared JWT Auth Backend (used by both dev and prod)
resource "vault_jwt_auth_backend" "jwt" {
  path = "jwt"

  bound_issuer       = "https://token.actions.githubusercontent.com"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
}

# Shared Userpass Auth Backend (used by both dev and prod)
resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "userpass"
}

# Shared Policy (used by both dev and prod)
resource "vault_policy" "shared_policy" {
  name   = "shared-policy"
  policy = <<-EOT
    # Shared policy
    path "kv/shared/data/*" {
      capabilities = ["read", "list"]
    }
  EOT
}

# Admin Policy - Full access to all KV secrets
resource "vault_policy" "admin_policy" {
  name   = "admin-policy"
  policy = <<-EOT
    # Full access to all KV secrets
    path "kv/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    # List all secret engines
    path "sys/mounts" {
      capabilities = ["read", "list"]
    }

    # Read identity information
    path "identity/*" {
      capabilities = ["read", "list"]
    }

    # SSH CA access for all environments
    path "*-ssh-client-signer/*" {
      capabilities = ["read", "list"]
    }
  EOT
}

# Developer Policy - Read access to dev and shared secrets
resource "vault_policy" "developer_policy" {
  name   = "developer-policy"
  policy = <<-EOT
    # Read access to shared secrets
    path "kv/shared/data/*" {
      capabilities = ["read", "list"]
    }

    # Read access to dev secrets
    path "kv/dev/data/*" {
      capabilities = ["read", "list"]
    }
  EOT
}

# JWT backend for Dev Environment
module "vault_admin_dev" {
  source = "./modules/vault-jwt"

  env                 = "dev"
  jwt_backend_path    = vault_jwt_auth_backend.jwt.path
  shared_policy_name  = vault_policy.shared_policy.name
  github_organization = "phuchoang2603"
  github_repository   = "kubernetes-proxmox"
  github_branch       = "master"
}

# JWT backend for Prod Environment
module "vault_admin_prod" {
  source = "./modules/vault-jwt"

  env                 = "prod"
  jwt_backend_path    = vault_jwt_auth_backend.jwt.path
  shared_policy_name  = vault_policy.shared_policy.name
  github_organization = "phuchoang2603"
  github_repository   = "kubernetes-proxmox"
  github_branch       = "master"
}

# Vault OIDC Provider for Kubernetes (Dev)
module "vault_oidc_dev" {
  source = "./modules/vault-oidc-kubernetes"

  env                    = "dev"
  vault_addr             = var.vault_addr
  userpass_auth_accessor = vault_auth_backend.userpass.accessor

  redirect_uris = [
    "http://localhost:8000",  # kubelogin default
    "http://localhost:18000", # kubelogin alternative
  ]
}

# Vault OIDC Provider for Kubernetes (Prod)
module "vault_oidc_prod" {
  source = "./modules/vault-oidc-kubernetes"

  env                    = "prod"
  vault_addr             = var.vault_addr
  userpass_auth_accessor = vault_auth_backend.userpass.accessor

  redirect_uris = [
    "http://localhost:8000",  # kubelogin default
    "http://localhost:18000", # kubelogin alternative
  ]
}

# Vault Kubernetes Auth Backend for External Secrets (Dev)
module "vault_k8s_auth_dev" {
  source = "./modules/vault-kubernetes-auth"

  env        = "dev"
  vault_addr = var.vault_addr
}

# Vault Kubernetes Auth Backend for External Secrets (Prod)
module "vault_k8s_auth_prod" {
  source = "./modules/vault-kubernetes-auth"

  env        = "prod"
  vault_addr = var.vault_addr
}
