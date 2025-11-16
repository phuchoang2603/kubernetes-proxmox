variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "jwt_backend_path" {
  description = "Path of the shared JWT auth backend"
  type        = string
}

variable "shared_policy_name" {
  description = "Name of the shared Vault policy"
  type        = string
}

variable "github_organization" {
  type        = string
  description = "The GitHub organization name."
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository name."
}

variable "github_branch" {
  type        = string
  description = "The GitHub branch name to restrict access to."
}
