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

# Create scope mappings for OIDC
resource "authentik_scope_mapping" "email" {
  name       = "kubernetes-email"
  scope_name = "email"
  expression = "return {\"email\": request.user.email}"
}

resource "authentik_scope_mapping" "profile" {
  name       = "kubernetes-profile"
  scope_name = "profile"
  expression = <<-EOT
    return {
      "name": request.user.name,
      "given_name": request.user.name,
      "preferred_username": request.user.username,
      "nickname": request.user.username,
    }
  EOT
}

resource "authentik_scope_mapping" "groups" {
  name       = "kubernetes-groups"
  scope_name = "groups"
  expression = <<-EOT
    return {
      "groups": [group.name for group in request.user.ak_groups.all()],
    }
  EOT
}

# Create OAuth2/OIDC Provider for Kubernetes
resource "authentik_provider_oauth2" "kubernetes" {
  name               = var.kubernetes_client_id
  client_id          = var.kubernetes_client_id
  client_type        = "public"
  authorization_flow = data.authentik_flow.default_authorization_flow.id

  redirect_uris = var.kubernetes_redirect_uris

  # OIDC Configuration
  issuer_mode = "per_provider"
  sub_mode    = "hashed_user_id"

  # Token settings
  access_token_validity  = "hours=1"
  refresh_token_validity = "days=30"

  # Scopes
  property_mappings = [
    authentik_scope_mapping.email.id,
    authentik_scope_mapping.profile.id,
    authentik_scope_mapping.groups.id,
  ]

  # Signing settings
  signing_key = data.authentik_certificate_key_pair.default.id
}

# Get default certificate for signing
data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

# Create Application for Kubernetes
resource "authentik_application" "kubernetes" {
  name               = "Kubernetes"
  slug               = var.kubernetes_client_id
  protocol_provider  = authentik_provider_oauth2.kubernetes.id
  meta_launch_url    = "blank://blank"
  meta_description   = "Kubernetes cluster authentication via OIDC"
  meta_publisher     = "Kubernetes"
  policy_engine_mode = "all"
}

# Assign groups to the application
resource "authentik_policy_binding" "kubernetes_groups" {
  for_each = authentik_group.kubernetes_groups

  target = authentik_application.kubernetes.uuid
  group  = each.value.id
  order  = 0
}
