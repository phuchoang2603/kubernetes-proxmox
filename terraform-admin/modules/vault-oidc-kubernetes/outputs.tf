output "group_ids" {
  description = "Map of group IDs by role"
  value = {
    admins     = vault_identity_group.kubernetes_admins.id
    developers = vault_identity_group.kubernetes_developers.id
    viewers    = vault_identity_group.kubernetes_viewers.id
  }
}
