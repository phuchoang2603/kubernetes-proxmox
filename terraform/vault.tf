# Define Vault path for proxmox creds
data "vault_generic_secret" "proxmox" {
  path = "kv/${var.env}/proxmox"
}

# Init SSH engine for signing SSH for github runner dynamically
# 1. Mount SSH engine path
resource "vault_mount" "ssh_client_signer" {
  type = "ssh"
  path = "${var.env}_ssh_client_signer"
}

# 2. Config SSH CA signer at the path above
resource "vault_ssh_secret_backend_ca" "ssh_ca" {
  backend              = vault_mount.ssh_client_signer.path
  generate_signing_key = true
}

# 3. Config role for client
resource "vault_ssh_secret_backend_role" "github_runner" {
  backend                 = vault_mount.ssh_client_signer.path
  name                    = "github-runner"
  key_type                = "ca"
  allow_user_certificates = true
  allowed_users           = var.vm_username
  ttl                     = "1800" # 30 minutes
}
