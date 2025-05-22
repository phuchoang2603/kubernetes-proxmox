#!/bin/bash

set -e

# Load environment and cleanup scripts
source ./clean-up-ssh-known-hosts.sh

# -------------------------
# Setup kubectx context
# -------------------------
export KUBECONFIG=$(find ~/.kube \( -name '*.yaml' -o -name '*.yml' \) -print0 | xargs -0 echo | tr ' ' ':')
kubectx proxmox=default
kubectx proxmox
