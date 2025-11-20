# Shared Outputs
output "jwt_auth_path" {
  description = "Path of the shared JWT auth backend"
  value       = vault_jwt_auth_backend.jwt.path
}

output "shared_policy_name" {
  description = "Name of the shared Vault policy"
  value       = vault_policy.shared_policy.name
}

# Dev Outputs
output "dev_ssh_ca_public_key" {
  description = "SSH CA public key for dev environment"
  value       = module.vault_admin_dev.ssh_ca_public_key
  sensitive   = true
}

output "dev_push_role_name" {
  description = "Name of the GitHub Actions push role for dev"
  value       = module.vault_admin_dev.push_role_name
}

output "dev_pr_role_name" {
  description = "Name of the GitHub Actions PR role for dev"
  value       = module.vault_admin_dev.pr_role_name
}

output "dev_ssh_signer_path" {
  description = "Path of the SSH client signer for dev"
  value       = module.vault_admin_dev.ssh_signer_path
}

output "dev_policy_name" {
  description = "Name of the dev-specific policy"
  value       = module.vault_admin_dev.env_policy_name
}

# Prod Outputs
output "prod_ssh_ca_public_key" {
  description = "SSH CA public key for prod environment"
  value       = module.vault_admin_prod.ssh_ca_public_key
  sensitive   = true
}

output "prod_push_role_name" {
  description = "Name of the GitHub Actions push role for prod"
  value       = module.vault_admin_prod.push_role_name
}

output "prod_pr_role_name" {
  description = "Name of the GitHub Actions PR role for prod"
  value       = module.vault_admin_prod.pr_role_name
}

output "prod_ssh_signer_path" {
  description = "Path of the SSH client signer for prod"
  value       = module.vault_admin_prod.ssh_signer_path
}

output "prod_policy_name" {
  description = "Name of the prod-specific policy"
  value       = module.vault_admin_prod.env_policy_name
}

# Dev OIDC Outputs
output "dev_oidc_issuer_url" {
  description = "OIDC issuer URL for dev Kubernetes cluster"
  value       = module.vault_oidc_dev.oidc_issuer_url
}

output "dev_oidc_client_id" {
  description = "OIDC client ID for dev Kubernetes cluster"
  value       = module.vault_oidc_dev.oidc_client_id
}

output "dev_oidc_discovery_url" {
  description = "OIDC discovery URL for dev Kubernetes cluster"
  value       = module.vault_oidc_dev.oidc_discovery_url
}

output "dev_kubernetes_groups" {
  description = "Kubernetes RBAC groups for dev environment"
  value       = module.vault_oidc_dev.group_names
}

# Prod OIDC Outputs
output "prod_oidc_issuer_url" {
  description = "OIDC issuer URL for prod Kubernetes cluster"
  value       = module.vault_oidc_prod.oidc_issuer_url
}

output "prod_oidc_client_id" {
  description = "OIDC client ID for prod Kubernetes cluster"
  value       = module.vault_oidc_prod.oidc_client_id
}

output "prod_oidc_discovery_url" {
  description = "OIDC discovery URL for prod Kubernetes cluster"
  value       = module.vault_oidc_prod.oidc_discovery_url
}

output "prod_kubernetes_groups" {
  description = "Kubernetes RBAC groups for prod environment"
  value       = module.vault_oidc_prod.group_names
}
