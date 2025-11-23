variable "username" {
  description = "Username for Vault userpass authentication"
  type        = string
}

variable "password" {
  description = "Password for the user (will prompt if not provided)"
  type        = string
  sensitive   = true
}

variable "email" {
  description = "Email address for the user"
  type        = string
}

variable "group_ids" {
  description = "List of Vault group IDs the user should be a member of"
  type        = list(string)
  default     = []
}

variable "userpass_auth_accessor" {
  description = "Accessor ID of the userpass auth backend"
  type        = string
}

variable "userpass_mount_path" {
  description = "Mount path for userpass auth backend"
  type        = string
  default     = "userpass"
}

variable "token_ttl" {
  description = "Token TTL in seconds"
  type        = number
  default     = 3600 # 1 hour
}

variable "token_max_ttl" {
  description = "Token max TTL in seconds"
  type        = number
  default     = 86400 # 24 hours
}
