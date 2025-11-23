# Create userpass user
resource "vault_generic_endpoint" "user" {
  path                 = "auth/${var.userpass_mount_path}/users/${var.username}"
  ignore_absent_fields = true

  data_json = jsonencode({
    password       = var.password
    token_ttl      = var.token_ttl
    token_max_ttl  = var.token_max_ttl
    token_policies = var.vault_policies
  })
}

# Create entity
resource "vault_identity_entity" "user" {
  name     = var.username
  policies = var.vault_policies
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

# Note: Group membership will be managed from the parent module
# This avoids Terraform's for_each limitation with unknown values
