#!/usr/bin/env bash

set -e

# Pre-setup, install kubectl, helm, and kubectx and load .env
source ./pre-setup.sh
source ../.env

# Terraform: provision VMs
cd ../terraform/
mise exec terraform -- terraform init -reconfigure -backend-config="../../config/${env}.s3.tfbackend"
mise exec terraform -- terraform apply -auto-approve

cd -

# Clean up known_hosts
source ./clean-up-ssh-known-hosts.sh

# Ansible: bootstrap the cluster
cd ../ansible/
source ../.venv/bin/activate
source ../.env

# Run all playbooks without skipping any tags
ansible-playbook prepare-local.yaml
ansible-playbook site.yaml

cd -
