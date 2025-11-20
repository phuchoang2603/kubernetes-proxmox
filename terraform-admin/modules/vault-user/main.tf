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

# Create entity
resource "vault_identity_entity" "user" {
  name     = var.username
  metadata = {
    email = var.email
  }
}

# Create entity alias linking the userpass user to the entity
resource "vault_identity_entity_alias" "user" {
  name           = var.username
  mount_accessor = var.userpass_auth_accessor
  canonical_id   = vault_identity_entity.user.id
}

# Add user entity to all specified groups using a null_resource workaround
# This uses the Vault CLI to add the user to groups, avoiding the for_each limitation
resource "terraform_data" "add_to_groups" {
  count = length(var.group_ids)

  triggers_replace = {
    group_id  = var.group_ids[count.index]
    entity_id = vault_identity_entity.user.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      vault write identity/group/id/${var.group_ids[count.index]} \
        member_entity_ids+=${vault_identity_entity.user.id}
    EOT
  }
}
