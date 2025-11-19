variable "authentik_url" {
  description = "URL of the Authentik instance (e.g., https://authentik.example.com)"
  type        = string
}

variable "authentik_token" {
  description = "API token for Authentik (create in Admin UI -> Tokens)"
  type        = string
  sensitive   = true
}

variable "kubernetes_client_id" {
  description = "OIDC client ID for Kubernetes"
  type        = string
  default     = "kubernetes"
}

variable "kubernetes_redirect_uris" {
  description = "List of allowed redirect URIs for kubectl OIDC callback"
  type        = list(string)
  default = [
    "http://localhost:8000",
    "http://localhost:18000"
  ]
}

variable "group_mappings" {
  description = "Map of group names to create in Authentik"
  type = map(object({
    name        = string
    description = string
  }))
  default = {
    admins = {
      name        = "kubernetes-admins"
      description = "Kubernetes cluster administrators with full access"
    }
    developers = {
      name        = "kubernetes-developers"
      description = "Kubernetes developers with namespace-level access"
    }
    viewers = {
      name        = "kubernetes-viewers"
      description = "Kubernetes viewers with read-only access"
    }
  }
}
