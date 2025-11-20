output "entity_id" {
  description = "Vault entity ID for the user"
  value       = vault_identity_entity.user.id
}

output "username" {
  description = "Username"
  value       = var.username
}

output "email" {
  description = "User email"
  value       = var.email
}

output "group_ids" {
  description = "List of group IDs the user belongs to"
  value       = var.group_ids
}
