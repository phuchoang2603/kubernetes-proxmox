output "oidc_issuer_url" {
  description = "OIDC issuer URL for Kubernetes API server configuration"
  value       = "https://${vault_identity_oidc_provider.kubernetes.issuer_host}/v1/identity/oidc/provider/${var.env}"
}

output "oidc_client_id" {
  description = "OIDC client ID for Kubernetes"
  value       = vault_identity_oidc_client.kubernetes.client_id
}

output "oidc_discovery_url" {
  description = "OIDC discovery URL"
  value       = "https://${vault_identity_oidc_provider.kubernetes.issuer_host}/v1/identity/oidc/provider/${var.env}/.well-known/openid-configuration"
}

output "kubernetes_admins_group_id" {
  description = "Vault group ID for Kubernetes admins"
  value       = vault_identity_group.kubernetes_admins.id
}

output "kubernetes_developers_group_id" {
  description = "Vault group ID for Kubernetes developers"
  value       = vault_identity_group.kubernetes_developers.id
}

output "kubernetes_viewers_group_id" {
  description = "Vault group ID for Kubernetes viewers"
  value       = vault_identity_group.kubernetes_viewers.id
}

output "userpass_accessor" {
  description = "Userpass auth backend accessor for creating group aliases"
  value       = vault_auth_backend.userpass.accessor
}

output "group_names" {
  description = "Map of group names to IDs"
  value = {
    admins     = "${var.env}-kubernetes-admins"
    developers = "${var.env}-kubernetes-developers"
    viewers    = "${var.env}-kubernetes-viewers"
  }
}
