#!/bin/bash

set -e

# Check if the environment argument is provided
if [ -z "$1" ]; then
  echo "Error: Environment argument is not provided. Please provide 'dev' or 'prod'."
  exit 1
fi

# Check if the environment is valid
if [ "$1" != "dev" ] && [ "$1" != "prod" ]; then
  echo "Error: Invalid environment. Please use 'dev' or 'prod'."
  exit 1
fi

ENV=$1
ROOT_DIR="$(git rev-parse --show-toplevel)"
K8S_NODES_PATH="$ROOT_DIR/terraform/env/$ENV/k8s_nodes.json"
LONGHORN_NODES_PATH="$ROOT_DIR/terraform/env/$ENV/longhorn_nodes.json"
HOSTS_INI_PATH="$ROOT_DIR/ansible/inventory/hosts.ini"

# Combine JSON files
COMBINED_JSON=$(jq -s 'add' "$K8S_NODES_PATH" "$LONGHORN_NODES_PATH")

# Get unique roles
ROLES=$(echo "$COMBINED_JSON" | jq -r 'map(.role) | unique | .[]')

# Start generating hosts.ini
{
  # Generate sections for each role
  for role in $ROLES; do
    group_name=$role
    echo "[$group_name]"
    echo "$COMBINED_JSON" | jq -r --arg role "$role" 'to_entries[] | select(.value.role == $role) | "\(.key) \(.value.address)"' | while read -r key address; do
      echo "$key ansible_host=${address%/16}"
    done
    echo ""
  done

  # RKE2 Children
  echo "[rke2:children]"
  for role in $ROLES; do
    group_name=$role
    echo "$group_name"
  done

} >"$HOSTS_INI_PATH"

echo "Successfully generated $HOSTS_INI_PATH for environment $ENV"
