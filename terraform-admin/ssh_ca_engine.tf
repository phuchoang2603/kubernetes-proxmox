# Init SSH engine for signing SSH for github runner dynamically
# 1. Mount SSH engine path
resource "vault_mount" "ssh_client_signer" {
  type = "ssh"
  path = "${var.env}-ssh-client-signer"
}

# 2. Config SSH CA signer at the path above
resource "vault_ssh_secret_backend_ca" "ssh_ca" {
  backend              = vault_mount.ssh_client_signer.path
  generate_signing_key = true
}

# 3. Push the public key to kv/env/
resource "vault_generic_secret" "ssh_ca_public_key" {
  path = "kv/${var.env}/ssh_ca_public_key"

  data_json = jsonencode({
    public_key = vault_ssh_secret_backend_ca.ssh_ca.public_key
  })
}

# 4. Config role for client
resource "vault_ssh_secret_backend_role" "github_runner" {
  backend                 = vault_mount.ssh_client_signer.path
  name                    = "github-runner"
  key_type                = "ca"
  allow_user_certificates = true
  ttl                     = "1800" # 30 minutes
}
