# Fetch VIP from Vault KV (stored at kv/{env}/ip)
data "vault_generic_secret" "ip" {
  path = "kv/${var.env}/ip"
}

# Enable Kubernetes auth method for the environment
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "${var.env}-kubernetes"

  description = "Kubernetes auth backend for ${var.env} environment"
}

# Configure the Kubernetes auth method using the VIP from Vault
# This will automatically use the VIP address for the Kubernetes API server
resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend = vault_auth_backend.kubernetes.path

  # Use VIP from Vault KV store (reads the 'vip' key from kv/{env}/data/ip)
  # External Vault connects to Kubernetes API via the VIP on port 6443
  kubernetes_host = "https://${data.vault_generic_secret.ip.data["vip"]}:6443"

  # Disable local CA JWT since Vault is external to the cluster
  # This will be fully configured post-bootstrap with CA cert and token reviewer JWT
  disable_local_ca_jwt = true
}

# Create a policy for External Secrets Operator
resource "vault_policy" "external_secrets" {
  name   = "${var.env}-external-secrets-policy"
  policy = <<-EOT
    # Allow reading all secrets in the environment's KV path
    path "kv/${var.env}/data/*" {
      capabilities = ["read", "list"]
    }

    # Allow listing the KV metadata
    path "kv/${var.env}/metadata/*" {
      capabilities = ["list"]
    }

    # Allow reading all secrets in the shared KV path
    path "kv/shared/data/*" {
      capabilities = ["read", "list"]
    }

    path "kv/shared/metadata/*" {
      capabilities = ["list"]
    }
  EOT
}

# Create a role for External Secrets Operator
resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend   = vault_auth_backend.kubernetes.path
  role_name = "external-secrets"

  # Bind to the external-secrets service account in external-secrets namespace
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["external-secrets"]

  # Assign the policy
  token_policies = [vault_policy.external_secrets.name]

  # Token TTL settings
  token_ttl     = 3600  # 1 hour
  token_max_ttl = 86400 # 24 hours
}
