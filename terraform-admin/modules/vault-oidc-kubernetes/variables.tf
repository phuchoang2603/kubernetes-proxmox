variable "env" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "vault_addr" {
  description = "Vault address for OIDC issuer URL"
  type        = string
}

variable "userpass_auth_accessor" {
  description = "Accessor ID of the userpass auth backend"
  type        = string
}

variable "redirect_uris" {
  description = "List of allowed redirect URIs for OIDC client"
  type        = list(string)
  default = [
    "http://localhost:8000/oidc/callback",  # kubelogin default
    "http://localhost:18000/oidc/callback", # kubelogin alternative
    "http://localhost:8080/oidc/callback",  # common alternative
  ]
}

variable "userpass_mount_path" {
  description = "Mount path for userpass auth backend"
  type        = string
  default     = "userpass"
}
