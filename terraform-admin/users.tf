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

  # Create a flat list of user-to-group mappings for processing
  user_group_list = flatten([
    for username, user in var.users : [
      for env_role_key, group_info in {
        "dev-${user.groups.dev_role}"   = { env = "dev", role = user.groups.dev_role }
        "prod-${user.groups.prod_role}" = { env = "prod", role = user.groups.prod_role }
        } : {
        username  = username
        env       = group_info.env
        role      = group_info.role
        group_key = env_role_key
      } if group_info.role != null
    ]
  ])

  # Group users by their group assignments (env-role)
  # This creates a map where each key is a group (e.g., "dev-admins")
  # and the value is a list of usernames belonging to that group
  group_memberships = {
    for item in distinct([for m in local.user_group_list : m.group_key]) : item => {
      env       = split("-", item)[0]
      role      = join("-", slice(split("-", item), 1, length(split("-", item))))
      usernames = [for m in local.user_group_list : m.username if m.group_key == item]
    }
  }
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

# Manage group memberships by grouping all users per group
# Each resource manages ALL members for a specific group
resource "vault_identity_group_member_entity_ids" "user_group_assignments" {
  for_each = local.group_memberships

  group_id = each.value.env == "dev" ? (
    module.vault_oidc_dev.group_ids[each.value.role]
    ) : (
    module.vault_oidc_prod.group_ids[each.value.role]
  )

  # Collect all entity IDs for users in this group
  member_entity_ids = [
    for username in each.value.usernames : module.vault_users[username].entity_id
  ]

  exclusive = true

  depends_on = [
    module.vault_users,
    module.vault_oidc_dev,
    module.vault_oidc_prod
  ]
}

