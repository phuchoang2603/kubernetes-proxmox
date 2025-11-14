resource "vault_jwt_auth_backend" "github_oidc" {
  path = "github-oidc"

  bound_issuer       = var.github_identity_provider
  oidc_discovery_url = var.github_identity_provider
}

# ROLE 1: For PUSHES to 'master'
resource "vault_jwt_auth_backend_role" "github_actions_push_role" {
  backend         = vault_jwt_auth_backend.github_oidc.path
  role_name       = "${var.env}-github-actions-push-role"
  role_type       = "jwt"
  token_policies  = [vault_policy.vault_env_policy.name, vault_policy.shared_policy.name]
  bound_audiences = ["https://github.com/${var.github_organization}"]
  user_claim      = "actor"

  bound_subject = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
}

# ROLE 2: For PULL REQUESTS *targeting* 'master'
resource "vault_jwt_auth_backend_role" "github_actions_pr_role" {
  backend         = vault_jwt_auth_backend.github_oidc.path
  role_name       = "${var.env}-github-actions-pr-role"
  role_type       = "jwt"
  token_policies  = [vault_policy.vault_env_policy.name, vault_policy.shared_policy.name]
  bound_audiences = ["https://github.com/${var.github_organization}"]
  user_claim      = "actor"

  bound_claims = {
    "repository" = "${var.github_organization}/${var.github_repository}"
    "event_name" = "pull_request"
    "base_ref"   = "refs/heads/${var.github_branch}"
  }
}
