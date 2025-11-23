output "auth_backend_path" {
  description = "Path where the Kubernetes auth backend is mounted"
  value       = vault_auth_backend.kubernetes.path
}

output "role_name" {
  description = "Name of the Kubernetes auth role for External Secrets"
  value       = vault_kubernetes_auth_backend_role.external_secrets.role_name
}

output "policy_name" {
  description = "Name of the policy for External Secrets"
  value       = vault_policy.external_secrets.name
}
