resource "vault_policy" "vault_env_policy" {
  name   = "${var.env}-policy"
  policy = <<-EOT
    path "kv/${var.env}/data/*" {
      capabilities = ["read", "list"]
    }

    # Grant permission to sign keys using a specific role
    path "${vault_mount.ssh_client_signer.path}/sign/github-runner" {
      capabilities = ["update"]
    }
  EOT
}

resource "vault_policy" "shared_policy" {
  name   = "shared-policy"
  policy = <<-EOT
    # Shared policy
    path "kv/shared/data/*" {
      capabilities = ["read", "list"]
    }
  EOT
}
