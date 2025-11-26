# Shared JWT Auth Backend (used by all environments)
resource "vault_jwt_auth_backend" "jwt" {
  path = "jwt"

  bound_issuer       = "https://token.actions.githubusercontent.com"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
}

# Shared Userpass Auth Backend (used by all environments)
resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "userpass"
}

# JWT backend for each environment
module "vault_admin" {
  source   = "./modules/vault-jwt"
  for_each = toset(var.environments)

  env                 = each.key
  jwt_backend_path    = vault_jwt_auth_backend.jwt.path
  github_organization = "phuchoang2603"
  github_repository   = "kubernetes-proxmox"
  github_branch       = "master"
}

# Vault OIDC Provider for Kubernetes (per environment)
module "vault_oidc" {
  source   = "./modules/vault-oidc-kubernetes"
  for_each = toset(var.environments)

  env                    = each.key
  vault_addr             = var.vault_addr
  userpass_auth_accessor = vault_auth_backend.userpass.accessor

  redirect_uris = [
    "http://localhost:8000",  # kubelogin default
    "http://localhost:18000", # kubelogin alternative
  ]
}

# Vault Kubernetes Auth Backend for External Secrets (per environment)
module "vault_k8s_auth" {
  source   = "./modules/vault-kubernetes-auth"
  for_each = toset(var.environments)

  env        = each.key
  vault_addr = var.vault_addr
}

