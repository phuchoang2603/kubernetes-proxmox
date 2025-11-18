# Create groups for Kubernetes RBAC
resource "authentik_group" "kubernetes_groups" {
  for_each = var.group_mappings

  name = each.value.name
  attributes = jsonencode({
    description = each.value.description
  })
}

# Get the default Admin flow for authentication
data "authentik_flow" "default_authentication_flow" {
  slug = "default-authentication-flow"
}

# Get the default Authorization flow
data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}
