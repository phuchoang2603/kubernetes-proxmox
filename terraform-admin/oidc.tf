resource "vault_jwt_auth_backend" "github_oidc" {
  path = "github-oidc"

  bound_issuer       = var.github_identity_provider
  oidc_discovery_url = var.github_identity_provider
}

resource "vault_jwt_auth_backend_role" "github_actions_push_role" {
  backend           = vault_jwt_auth_backend.github_oidc.path
  role_name         = "${var.env}-github-actions-push-role"
  role_type         = "jwt"
  token_policies    = [vault_policy.vault_env_policy.name, vault_policy.shared_policy.name]
  bound_audiences   = ["https://github.com/${var.github_organization}"]
  bound_claims_type = "glob"
  bound_claims = {
    "sub" = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
  }
  user_claim = "actor"
}

resource "vault_jwt_auth_backend_role" "github_actions_pr_role" {
  backend           = vault_jwt_auth_backend.github_oidc.path
  role_name         = "${var.env}-github-actions-pr-role"
  role_type         = "jwt"
  token_policies    = [vault_policy.vault_env_policy.name, vault_policy.shared_policy.name]
  bound_audiences   = ["https://github.com/${var.github_organization}"]
  bound_claims_type = "glob"
  bound_claims = {
    "sub" = "repo:${var.github_organization}/${var.github_repository}:pull_request"
  }
  user_claim = "actor"
}
