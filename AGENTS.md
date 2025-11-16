# Agent Guidelines for kubernetes-proxmox

## Project Overview
Infrastructure-as-code project that automates RKE2 Kubernetes provisioning on Proxmox using Terraform and Ansible. Supports separate dev/prod environments.

## Lint/Test Commands
- **Terraform Provision**: `cd terraform-provision && terraform fmt -check -recursive && terraform validate`
- **Terraform Admin**: `cd terraform-admin && terraform fmt -check -recursive && terraform validate`
- **Terraform format**: `terraform fmt -recursive` (auto-fix, run from project root)
- **Ansible**: `cd ansible && ansible-lint`
- **Ansible playbook**: `cd ansible && ansible-playbook site.yaml` (full run)
- **Ansible with tags**: `ansible-playbook site.yaml --tags <tag>` (e.g., ssl, longhorn)

## Environment-Specific Workflows
- **Terraform Provision**: `terraform init -reconfigure -backend-config="key=<env>.tfstate" && terraform apply -var-file="env/<env>/main.tfvars"`
  - Replace `<env>` with `dev` or `prod`
- **Terraform Admin**: `cd terraform-admin && terraform init && terraform apply`
  - Manages both dev and prod environments in single state (admin.tfstate)

## Code Style

### Terraform
- Use 2-space indentation, snake_case for resources/variables
- Run `terraform fmt -recursive` before committing
- Use Terraform 1.6.6+, define required versions in terraform blocks
- Place environment-specific configs in `env/dev/` or `env/prod/`
- Use descriptive resource names (e.g., `vault_jwt_auth_backend.jwt`)

### Ansible
- YAML with 2-space indentation
- Use `ansible.builtin.*` for built-in modules (fully qualified collection names)
- Variable naming: snake_case (ansible-lint skip_list allows flexibility)
- Templates end in `.j2`, placed in `roles/*/templates/`
- Use Jinja2 templates for conditionals: `{{ 'option1' if condition else 'option2' }}`
- Set file permissions explicitly (mode: "0644" or "0755")
