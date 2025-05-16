#!/usr/bin/env bash

set -e

# Default flags
WITH_LONGHORN=false
WITH_METALLB=false # Deprecated, dont use it

# Parse arguments
for arg in "$@"; do
  case $arg in
  --with-longhorn)
    WITH_LONGHORN=true
    ;;
  --with-metallb)
    WITH_METALLB=true
    ;;
  *)
    echo "❌ Unknown option: $arg"
    exit 1
    ;;
  esac
done

# Terraform: provision VMs
cd ../terraform/
make init MODULE=cloud-img-download
make apply MODULE=cloud-img-download
make init MODULE=k8s-cluster
make apply MODULE=k8s-cluster

# Optional: Longhorn VMs if user chooses
if $WITH_LONGHORN; then
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

# Run playbook with dynamic tag control
SKIP_TAGS=""
if ! $WITH_LONGHORN; then
  SKIP_TAGS="longhorn"
fi
if ! $WITH_METALLB; then
  if [[ -n "$SKIP_TAGS" ]]; then
    SKIP_TAGS="$SKIP_TAGS,metallb"
  else
    SKIP_TAGS="metallb"
  fi
fi

if [[ -n "$SKIP_TAGS" ]]; then
  ansible-playbook prepare-local.yaml --skip-tags "$SKIP_TAGS" --ask-become-pass
  ansible-playbook site.yaml --skip-tags "$SKIP_TAGS"
else
  ansible-playbook prepare-local.yaml --ask-become-pass
  ansible-playbook site.yaml
fi

cd -

# Wait for services to settle
sleep 300

# Post-setup scripts
cd ../scripts/
source ./post-setup.sh
cd -
