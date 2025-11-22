output "entity_id" {
  description = "The Vault identity entity ID for this user"
  value       = vault_identity_entity.user.id
}

output "username" {
  description = "The username"
  value       = var.username
}
