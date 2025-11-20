# Shared JWT Auth Backend (used by both dev and prod)
resource "vault_jwt_auth_backend" "jwt" {
  path = "jwt"

  bound_issuer       = "https://token.actions.githubusercontent.com"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
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

# Dev Environment
module "vault_admin_dev" {
  source = "./modules/vault-admin"

  env                 = "dev"
  jwt_backend_path    = vault_jwt_auth_backend.jwt.path
  shared_policy_name  = vault_policy.shared_policy.name
  github_organization = "phuchoang2603"
  github_repository   = "kubernetes-proxmox"
  github_branch       = "master"
}

# Prod Environment
module "vault_admin_prod" {
  source = "./modules/vault-admin"

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

  env        = "dev"
  vault_addr = var.vault_addr

  redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "http://localhost:8000/oidc/callback",
  ]
}

# Vault OIDC Provider for Kubernetes (Prod)
module "vault_oidc_prod" {
  source = "./modules/vault-oidc-kubernetes"

  env        = "prod"
  vault_addr = var.vault_addr

  redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "http://localhost:8000/oidc/callback",
  ]
}
