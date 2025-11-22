variable "vault_addr" {
  description = <<-EOT
    Vault server address (e.g., https://vault.example.com)
    Can be set via environment variable: export TF_VAR_vault_addr="https://vault.example.com"
    Or sourced from VAULT_ADDR if using the Vault provider
  EOT
  type        = string
}

variable "users" {
  description = "Map of users to create with their group memberships"
  type = map(object({
    email    = string
    password = string
    groups = object({
      dev_role  = optional(string) # "admins", "developers", "viewers", or null
      prod_role = optional(string) # "admins", "developers", "viewers", or null
    })
  }))
  default = {}
  validation {
    condition = alltrue([
      for user in var.users : alltrue([
        for role in [user.groups.dev_role, user.groups.prod_role] :
        role == null || contains(["admins", "developers", "viewers"], role)
      ])
    ])
    error_message = "Role must be one of: 'admins', 'developers', 'viewers', or null."
  }
}
