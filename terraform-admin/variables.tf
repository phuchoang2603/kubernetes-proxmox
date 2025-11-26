variable "vault_addr" {
  description = <<-EOT
    Vault server address (e.g., https://vault.example.com)
    Can be set via environment variable: export TF_VAR_vault_addr="https://vault.example.com"
    Or sourced from VAULT_ADDR if using the Vault provider
  EOT
  type        = string
}

variable "environments" {
  description = "List of environments to create (e.g., ['dev', 'manage', 'prod'])"
  type        = list(string)
  default     = ["dev", "manage", "prod"]
}

variable "users" {
  description = "Map of users to create with their environment role assignments"
  type = map(object({
    email    = string
    password = string
    roles    = map(string) # Environment name -> role mapping (e.g., {dev = "admins", prod = "developers"})
  }))
  default = {}
  validation {
    condition = alltrue([
      for user in var.users : alltrue([
        for role in values(user.roles) :
        contains(["admins", "developers", "viewers"], role)
      ])
    ])
    error_message = "Role must be one of: 'admins', 'developers', 'viewers'."
  }
}
