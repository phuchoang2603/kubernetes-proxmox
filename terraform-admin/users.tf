# User Management
# Define your users here with direct group references

locals {
  # Define users here
  # Uncomment and modify the examples below to create users
  users = {
    # Example: Admin user with access to both dev and prod
    # "admin-user" = {
    #   email    = "admin@example.com"
    #   password = "change-me-secure-password"
    #   group_ids = [
    #     module.vault_oidc_dev.group_ids["admins"],
    #     module.vault_oidc_prod.group_ids["admins"]
    #   ]
    # }

    # Example: Developer with dev access only
    # "developer" = {
    #   email     = "developer@example.com"
    #   password  = "change-me-secure-password"
    #   group_ids = [
    #     module.vault_oidc_dev.group_ids["developers"]
    #   ]
    # }

    # Example: Viewer with read-only access to both environments
    # "viewer" = {
    #   email    = "viewer@example.com"
    #   password = "change-me-secure-password"
    #   group_ids = [
    #     module.vault_oidc_dev.group_ids["viewers"],
    #     module.vault_oidc_prod.group_ids["viewers"]
    #   ]
    # }
  }
}

# Create users from the local definition
module "vault_users" {
  source   = "./modules/vault-user"
  for_each = local.users

  username            = each.key
  password            = each.value.password
  email               = each.value.email
  group_ids           = each.value.group_ids
  userpass_mount_path = "userpass"

  depends_on = [
    module.vault_oidc_dev,
    module.vault_oidc_prod
  ]
}
