resource "vault_jwt_auth_backend" "github_oidc" {
  path = "github-oidc"

  bound_issuer       = var.github_identity_provider
  oidc_discovery_url = var.github_identity_provider
}

resource "vault_jwt_auth_backend_role" "github_actions_role" {
  backend         = vault_jwt_auth_backend.github_oidc.path
  role_name       = "${var.env}-github-actions-role"
  role_type       = "jwt"
  token_policies  = [vault_policy.vault_env_policy.name, vault_policy.shared_policy.name]
  token_max_ttl   = var.oidc_ttl
  bound_audiences = ["https://github.com/${var.github_organization}"]
  bound_subject   = "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/main"
  user_claim      = "actor"
}
