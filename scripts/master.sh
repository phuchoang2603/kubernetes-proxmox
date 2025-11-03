#!/usr/bin/env bash

set -e

# Pre-setup, install kubectl, helm, and kubectx and load .env
source ./pre-setup.sh
source ../.env

# Terraform: provision VMs
cd ../terraform/
make init MODULE=k8s-cluster
make apply MODULE=k8s-cluster

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

# Rename kubectl environment
kubectx $TF_VAR_env=default
