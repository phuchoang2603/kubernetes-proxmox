# User Management
# Users are defined via the 'users' variable, which can be set via:
# 1. terraform.tfvars file
# 2. TF_VAR_users environment variable
# 3. -var or -var-file command line flags

locals {
  # Create a flat map of user-to-group assignments with static keys
  # This avoids Terraform's "for_each with unknown values" limitation
  user_group_memberships = merge(flatten([
    for username, user in var.users : [
      user.groups.dev_role != null ? {
        "${username}-dev-${user.groups.dev_role}" = {
          username = username
          env      = "dev"
          role     = user.groups.dev_role
        }
      } : {},
      user.groups.prod_role != null ? {
        "${username}-prod-${user.groups.prod_role}" = {
          username = username
          env      = "prod"
          role     = user.groups.prod_role
        }
      } : {}
    ]
  ])...)
}

# Create users (without group assignments)
module "vault_users" {
  source   = "./modules/vault-user"
  for_each = var.users

  username               = each.key
  password               = each.value.password
  email                  = each.value.email
  group_ids              = [] # Groups will be managed separately
  userpass_mount_path    = "userpass"
  userpass_auth_accessor = vault_auth_backend.userpass.accessor

  depends_on = [
    module.vault_oidc_dev,
    module.vault_oidc_prod
  ]
}

# Manage group memberships with static keys
# Each resource assigns one user to one group
resource "vault_identity_group_member_entity_ids" "user_group_assignments" {
  for_each = local.user_group_memberships

  group_id = each.value.env == "dev" ? (
    module.vault_oidc_dev.group_ids[each.value.role]
    ) : (
    module.vault_oidc_prod.group_ids[each.value.role]
  )

  member_entity_ids = [module.vault_users[each.value.username].entity_id]
  exclusive         = false

  depends_on = [
    module.vault_users,
    module.vault_oidc_dev,
    module.vault_oidc_prod
  ]
}


