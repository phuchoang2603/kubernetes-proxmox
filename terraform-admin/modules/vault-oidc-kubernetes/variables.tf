variable "env" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "vault_addr" {
  description = "Vault address for OIDC issuer URL"
  type        = string
}

variable "redirect_uris" {
  description = "List of allowed redirect URIs for OIDC client"
  type        = list(string)
  default     = ["http://localhost:8250/oidc/callback"]
}

variable "userpass_mount_path" {
  description = "Mount path for userpass auth backend"
  type        = string
  default     = "userpass"
}
