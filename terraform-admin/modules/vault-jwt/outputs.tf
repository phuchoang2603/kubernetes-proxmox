output "ssh_ca_public_key" {
  description = "SSH CA public key for the environment"
  value       = vault_ssh_secret_backend_ca.ssh_ca.public_key
  sensitive   = true
}

output "push_role_name" {
  description = "Name of the GitHub Actions push role"
  value       = vault_jwt_auth_backend_role.github_actions_push_role.role_name
}

output "pr_role_name" {
  description = "Name of the GitHub Actions PR role"
  value       = vault_jwt_auth_backend_role.github_actions_pr_role.role_name
}

output "ssh_signer_path" {
  description = "Path of the SSH client signer"
  value       = vault_mount.ssh_client_signer.path
}

output "env_policy_name" {
  description = "Name of the environment-specific policy"
  value       = vault_policy.vault_env_policy.name
}
