variable "vault_addr" {
  description = <<-EOT
    Vault server address (e.g., https://vault.example.com)
    Can be set via environment variable: export TF_VAR_vault_addr="https://vault.example.com"
    Or sourced from VAULT_ADDR if using the Vault provider
  EOT
  type        = string
}
