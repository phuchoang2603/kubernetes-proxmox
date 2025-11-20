# Create userpass user
resource "vault_generic_endpoint" "user" {
  path                 = "auth/${var.userpass_mount_path}/users/${var.username}"
  ignore_absent_fields = true

  data_json = jsonencode({
    password      = var.password
    token_ttl     = var.token_ttl
    token_max_ttl = var.token_max_ttl
  })
}

# Get the entity ID for the user
data "vault_identity_entity" "user" {
  entity_name = var.username

  depends_on = [vault_generic_endpoint.user]
}

# Update entity metadata (for OIDC email claim)
resource "vault_identity_entity" "user" {
  name = var.username

  metadata = {
    email = var.email
  }

  # Ensure the user exists first
  depends_on = [data.vault_identity_entity.user]
}

# Add user to groups
resource "vault_identity_group_member_entity_ids" "user_groups" {
  for_each = toset(var.group_ids)

  group_id          = each.value
  member_entity_ids = [vault_identity_entity.user.id]
  exclusive         = false
}
