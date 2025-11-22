# User Management
# Users are defined via the 'users' variable, which can be set via:
# 1. terraform.tfvars file
# 2. TF_VAR_users environment variable
# 3. -var or -var-file command line flags

locals {
  # Transform the user input into a simpler format for user creation
  users_basic = {
    for username, user in var.users : username => {
      email    = user.email
      password = user.password
    }
  }

  # Create a flat list of user-to-group mappings
  # This allows us to create group memberships with static keys
  user_group_memberships = merge([
    for username, user in var.users : {
      for env_role, group_info in {
        "dev-${user.groups.dev_role}"   = { env = "dev", role = user.groups.dev_role }
        "prod-${user.groups.prod_role}" = { env = "prod", role = user.groups.prod_role }
        } : "${username}-${env_role}" => {
        username = username
        env      = group_info.env
        role     = group_info.role
      } if group_info.role != null
    }
  ]...)
}

# Create users (without group assignments)
module "vault_users" {
  source   = "./modules/vault-user"
  for_each = local.users_basic

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

# Manage group memberships separately with static keys
# This avoids the "for_each with unknown values" error
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

