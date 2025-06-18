#!/usr/bin/env bash

set -e

# Define supported optional features (case-sensitive)
SUPPORTED_FEATURES=("longhorn" "ssl" "kube_vip" "argocd")

# Initialize feature flags: default is enabled
declare -A FEATURES
for feature in "${SUPPORTED_FEATURES[@]}"; do
  FEATURES["$feature"]=true
done

# Parse arguments
for arg in "$@"; do
  if [[ "$arg" == --skip-* ]]; then
    feature="${arg/--skip-/}"

    if [[ -v FEATURES["$feature"] ]]; then
      FEATURES["$feature"]=false
      echo "⛔ Skipping feature: $feature"
    else
      echo "❌ Unknown feature to skip: $feature"
      exit 1
    fi
  else
    echo "❌ Unknown option: $arg"
    exit 1
  fi
done

# Export feature environment variables
for key in "${!FEATURES[@]}"; do
  export "$key"="${FEATURES[$key]}"
done

# Pre-setup, install kubectl, helm, and kubectx
source ./pre-setup.sh

# Terraform: provision VMs
cd ../terraform/
make init MODULE=cloud-img-download
make apply MODULE=cloud-img-download
make init MODULE=k8s-cluster
make apply MODULE=k8s-cluster

# Optional Terraform modules
if [[ "${FEATURES[longhorn]}" == true ]]; then
  make init MODULE=longhorn-cluster
  make apply MODULE=longhorn-cluster
fi

cd -

# Clean up known_hosts
source ./clean-up-ssh-known-hosts.sh

# Ansible: bootstrap the cluster
cd ../ansible/
source ../.venv/bin/activate
source ../.env

# Build skip-tags string based on disabled features
TAGS_TO_SKIP=""
for key in "${!FEATURES[@]}"; do
  if [[ "${FEATURES[$key]}" != true ]]; then
    TAGS_TO_SKIP="${TAGS_TO_SKIP}${key},"
  fi
done

# Trim trailing comma
TAGS_TO_SKIP="${TAGS_TO_SKIP%,}"

# Run playbooks with skip-tags
if [[ -n "$TAGS_TO_SKIP" ]]; then
  ansible-playbook prepare-local.yaml --skip-tags "$TAGS_TO_SKIP"
  ansible-playbook site.yaml --skip-tags "$TAGS_TO_SKIP"
else
  ansible-playbook prepare-local.yaml
  ansible-playbook site.yaml
fi

cd -
