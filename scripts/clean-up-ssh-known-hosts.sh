#!/usr/bin/env bash

set -e

ROOT_DIR="$(git rev-parse --show-toplevel)"
KNOWN_HOSTS_FILE="${3:-$HOME/.ssh/known_hosts}"
K8S_NODES_PATH="$ROOT_DIR/terraform/env/dev/k8s_nodes.json"
LONGHORN_NODES_PATH="$ROOT_DIR/terraform/env/dev/longhorn_nodes.json"

# Combine JSON files
COMBINED_JSON=$(jq -s 'add' "$K8S_NODES_PATH" "$LONGHORN_NODES_PATH")

# Get IPs
ALL_IPS+=($(echo "$COMBINED_JSON" | jq -r 'to_entries[] | .value.address' | cut -d '/' -f1))

# Deduplicate IPs
ALL_IPS=($(printf "%s\n" "${ALL_IPS[@]}" | sort -u))

# Backup known_hosts
cp "$KNOWN_HOSTS_FILE" "${KNOWN_HOSTS_FILE}.bak"

# Remove entries
for ip in "${ALL_IPS[@]}"; do
  echo "Removing $ip from known_hosts..."
  ssh-keygen -R "$ip" -f "$KNOWN_HOSTS_FILE" >/dev/null || true
done

echo "Cleanup done. Backup created at ${KNOWN_HOSTS_FILE}.bak"
