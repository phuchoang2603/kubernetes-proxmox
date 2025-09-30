#!/usr/bin/env bash

set -e

KNOWN_HOSTS_FILE="${3:-$HOME/.ssh/known_hosts}"

ALL_IPS=("$vip")
ALL_IPS+=($(echo "$TF_VAR_k8s_nodes" | jq -r 'to_entries[] | .value.address' | cut -d '/' -f1))
ALL_IPS+=($(echo "$TF_VAR_longhorn_nodes" | jq -r 'to_entries[] | .value.address' | cut -d '/' -f1))

# Deduplicate IPs
ALL_IPS=($(printf "%s\n" "${ALL_IPS[@]}" | sort -u))

# Backup known_hosts
cp "$KNOWN_HOSTS_FILE" "${KNOWN_HOSTS_FILE}.bak"

# Remove entries
for ip in "${ALL_IPS[@]}"; do
  echo "🔧 Removing $ip from known_hosts..."
  ssh-keygen -R "$ip" -f "$KNOWN_HOSTS_FILE" >/dev/null || true
done

echo "✅ Cleanup done. Backup created at ${KNOWN_HOSTS_FILE}.bak"
