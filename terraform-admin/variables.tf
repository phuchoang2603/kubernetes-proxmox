variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "github_identity_provider" {
  type        = string
  description = "The JWT authentication URL used for the GitHub OIDC trust configuration"
  default     = "https://token.actions.githubusercontent.com"
}

variable "github_organization" {
  type        = string
  description = "The GitHub organization name."
  default     = "phuchoang2603"
}

variable "github_repository" {
  type        = string
  description = "The GitHub repository name."
  default     = "kubernetes-proxmox"
}

variable "github_branch" {
  type        = string
  description = "The GitHub branch name to restrict access to."
  default     = "master"

}
