# GitHub Actions Push Role
resource "vault_jwt_auth_backend_role" "github_actions_push_role" {
  backend           = var.jwt_backend_path
  role_name         = "${var.env}-github-actions-push-role"
  role_type         = "jwt"
  token_policies    = [vault_policy.vault_env_policy.name]
  bound_audiences   = ["https://github.com/${var.github_organization}"]
  bound_claims_type = "glob"
  bound_claims = {
    "sub" = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
  }
  user_claim = "actor"
}

# GitHub Actions PR Role
resource "vault_jwt_auth_backend_role" "github_actions_pr_role" {
  backend           = var.jwt_backend_path
  role_name         = "${var.env}-github-actions-pr-role"
  role_type         = "jwt"
  token_policies    = [vault_policy.vault_env_policy.name]
  bound_audiences   = ["https://github.com/${var.github_organization}"]
  bound_claims_type = "glob"
  bound_claims = {
    "sub" = "repo:${var.github_organization}/${var.github_repository}:pull_request"
  }
  user_claim = "actor"
}

# Environment-specific Vault Policy
resource "vault_policy" "vault_env_policy" {
  name   = "${var.env}-github-actions-policy"
  policy = <<-EOT
    path "kv/${var.env}/data/*" {
      capabilities = ["read", "list"]
    }

    # Grant permission to sign keys using a specific role
    path "${vault_mount.ssh_client_signer.path}/sign/github-runner" {
      capabilities = ["update"]
    }

    # Grant permission to configure and read Kubernetes auth backend
    path "auth/${var.env}-kubernetes/config" {
      capabilities = ["create", "update", "read"]
    }

    # Shared policy
    path "kv/shared/data/*" {
      capabilities = ["read", "list"]
    }
    path "kv/shared/metadata/*" {
      capabilities = ["list"]
    }
  EOT
}

# SSH Client Signer Mount
resource "vault_mount" "ssh_client_signer" {
  type = "ssh"
  path = "${var.env}-ssh-client-signer"
}

# SSH CA Configuration
resource "vault_ssh_secret_backend_ca" "ssh_ca" {
  backend              = vault_mount.ssh_client_signer.path
  generate_signing_key = true
}

# Store SSH CA Public Key
resource "vault_generic_secret" "ssh_ca_public_key" {
  path = "kv/${var.env}/ssh_ca_public_key"

  data_json = jsonencode({
    public_key = vault_ssh_secret_backend_ca.ssh_ca.public_key
  })
}

# SSH Role for GitHub Runner
resource "vault_ssh_secret_backend_role" "github_runner" {
  backend                 = vault_mount.ssh_client_signer.path
  name                    = "github-runner"
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = "ubuntu"
  ttl                     = "1800" # 30 minutes
}
