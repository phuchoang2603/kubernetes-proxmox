output "kubernetes_client_id" {
  description = "OAuth2 Client ID for Kubernetes OIDC"
  value       = authentik_provider_oauth2.kubernetes.client_id
}

output "kubernetes_client_secret" {
  description = "OAuth2 Client Secret for Kubernetes OIDC (store securely!)"
  value       = authentik_provider_oauth2.kubernetes.client_secret
  sensitive   = true
}

output "kubernetes_issuer_url" {
  description = "OIDC Issuer URL for Kubernetes (configure in kube-apiserver)"
  value       = "${var.authentik_url}/application/o/kubernetes/"
}

output "kubernetes_groups" {
  description = "Created Kubernetes groups and their IDs"
  value = {
    for k, v in authentik_group.kubernetes_groups : k => {
      id   = v.id
      name = v.name
    }
  }
}

output "application_slug" {
  description = "Application slug for accessing Kubernetes app in Authentik"
  value       = authentik_application.kubernetes.slug
}
