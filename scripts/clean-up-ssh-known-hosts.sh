#!/usr/bin/env bash

set -e

source ../.env
K8S_NODES_FILE="${1:-../k8s_nodes.json}"
LONGHORN_NODES_FILE="${2:-../longhorn_nodes.json}"
KNOWN_HOSTS_FILE="${3:-$HOME/.ssh/known_hosts}"

# Extract all IPs from JSON files
extract_ips() {
  jq -r 'to_entries[] | .value.address' "$1" | cut -d '/' -f1
}

ALL_IPS=("$vip")
ALL_IPS+=($(extract_ips "$K8S_NODES_FILE"))
ALL_IPS+=($(extract_ips "$LONGHORN_NODES_FILE"))

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
