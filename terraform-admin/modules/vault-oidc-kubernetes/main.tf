# Admin Policy - Full access to environment and shared secrets
resource "vault_policy" "admin_policy" {
  name   = "${var.env}-admin-policy"
  policy = <<-EOT
    # Full access to environment-specific secrets
    path "kv/${var.env}/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    # Full access to shared secrets
    path "kv/shared/*" {
      capabilities = ["create", "read", "update", "delete", "list"]
    }

    # List all secret engines
    path "sys/mounts" {
      capabilities = ["read", "list"]
    }

    # Read identity information
    path "identity/*" {
      capabilities = ["read", "list"]
    }

    # SSH CA access for this environment
    path "${var.env}-ssh-client-signer/*" {
      capabilities = ["read", "list", "update"]
    }
  EOT
}

# Developer Policy - Read access to environment and shared secrets
resource "vault_policy" "developer_policy" {
  name   = "${var.env}-developer-policy"
  policy = <<-EOT
    # Read access to environment-specific secrets
    path "kv/${var.env}/data/*" {
      capabilities = ["read", "list"]
    }

    # Read access to shared secrets
    path "kv/shared/data/*" {
      capabilities = ["read", "list"]
    }
  EOT
}

# Create Vault groups for Kubernetes RBAC
resource "vault_identity_group" "kubernetes_admins" {
  name     = "${var.env}-kubernetes-admins"
  type     = "internal"
  policies = [vault_policy.admin_policy.name]

  metadata = {
    environment = var.env
    purpose     = "Kubernetes cluster administrators"
  }
}

resource "vault_identity_group" "kubernetes_developers" {
  name     = "${var.env}-kubernetes-developers"
  type     = "internal"
  policies = [vault_policy.developer_policy.name]

  metadata = {
    environment = var.env
    purpose     = "Kubernetes application developers"
  }
}

resource "vault_identity_group" "kubernetes_viewers" {
  name     = "${var.env}-kubernetes-viewers"
  type     = "internal"
  policies = [] # No Vault secret access for viewers

  metadata = {
    environment = var.env
    purpose     = "Kubernetes read-only viewers"
  }
}

# Create OIDC key for signing tokens
resource "vault_identity_oidc_key" "kubernetes" {
  name               = "${var.env}-kubernetes"
  allowed_client_ids = ["*"]
  rotation_period    = 3600
  verification_ttl   = 3600
}

# Create custom scope for email
resource "vault_identity_oidc_scope" "email" {
  name        = "${var.env}-email"
  description = "Email scope for ${var.env} Kubernetes"
  template    = <<-EOT
    {
      "email": {{identity.entity.metadata.email}}
    }
  EOT
}

# Create custom scope for profile
resource "vault_identity_oidc_scope" "profile" {
  name        = "${var.env}-profile"
  description = "Profile scope for ${var.env} Kubernetes"
  template    = <<-EOT
    {
      "name": {{identity.entity.name}},
      "preferred_username": {{identity.entity.aliases.${var.userpass_auth_accessor}.name}}
    }
  EOT
}

# Create custom scope for groups
resource "vault_identity_oidc_scope" "groups" {
  name        = "${var.env}-groups"
  description = "Groups scope for ${var.env} Kubernetes"
  template    = <<-EOT
    {
      "groups": {{identity.entity.groups.names}}
    }
  EOT
}

# Create OIDC provider
resource "vault_identity_oidc_provider" "kubernetes" {
  name = var.env

  https_enabled = true
  issuer_host   = replace(var.vault_addr, "https://", "")

  allowed_client_ids = [
    vault_identity_oidc_client.kubernetes.client_id
  ]

  scopes_supported = [
    vault_identity_oidc_scope.email.name,
    vault_identity_oidc_scope.profile.name,
    vault_identity_oidc_scope.groups.name,
  ]
}

# Create OIDC assignment (controls who can authenticate)
resource "vault_identity_oidc_assignment" "kubernetes" {
  name = "${var.env}-kubernetes-users"

  group_ids = [
    vault_identity_group.kubernetes_admins.id,
    vault_identity_group.kubernetes_developers.id,
    vault_identity_group.kubernetes_viewers.id,
  ]
}

# Create OIDC client for Kubernetes
resource "vault_identity_oidc_client" "kubernetes" {
  name = "${var.env}-kubernetes"
  key  = vault_identity_oidc_key.kubernetes.name

  redirect_uris = var.redirect_uris

  assignments = [
    vault_identity_oidc_assignment.kubernetes.name
  ]

  id_token_ttl     = 3600 # 1 hour
  access_token_ttl = 3600 # 1 hour

  client_type = "public"
}

# Store OIDC client_id in Vault KV for use by Ansible
resource "vault_generic_secret" "oidc_client_id" {
  path = "kv/${var.env}/oidc"

  data_json = jsonencode({
    client_id = vault_identity_oidc_client.kubernetes.client_id
  })
}
