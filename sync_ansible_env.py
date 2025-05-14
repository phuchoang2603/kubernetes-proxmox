#!/usr/bin/env python3

import argparse
import os
import yaml
import re


def parse_env_file(env_file):
    env_vars = {}
    export_pattern = re.compile(r'^export\s+(\w+)=["\']?(.*?)["\']?(?:\s+#.*)?$')

    with open(env_file) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            match = export_pattern.match(line)
            if match:
                key, value = match.groups()
                env_vars[key.strip()] = value.strip()
    return env_vars


def load_yaml(yaml_file):
    if os.path.exists(yaml_file):
        with open(yaml_file) as f:
            return yaml.safe_load(f) or {}
    return {}


def save_yaml(yaml_file, data):
    with open(yaml_file, "w") as f:
        yaml.dump(data, f, default_flow_style=False, sort_keys=False)


def map_env_to_ansible(env_vars, mapping, current_vars):
    for env_key, ansible_key in mapping.items():
        if env_key in env_vars:
            current_vars[ansible_key] = env_vars[env_key]
    return current_vars


def main():
    parser = argparse.ArgumentParser(
        description="Sync .env variables (with export) to Ansible group_vars YAML"
    )
    parser.add_argument("-e", "--env", required=True, help="Path to .env file")
    parser.add_argument(
        "-y", "--yml", required=True, help="Path to group_vars .yml file"
    )
    args = parser.parse_args()

    env_vars = parse_env_file(args.env)
    current_vars = load_yaml(args.yml)

    # Define the mappings explicitly
    mappings = {
        "TF_VAR_vm_username": "ansible_user",
        "TF_VAR_vm_timezone": "system_timezone",
        "apiserver_endpoint": "apiserver_endpoint",
        "metal_lb_ip_range": "metal_lb_ip_range",
        "k3s_token": "k3s_token",
    }

    # Map and update
    updated_vars = map_env_to_ansible(env_vars, mappings, current_vars)

    # Save back to YAML
    save_yaml(args.yml, updated_vars)

    print(f"✅ Updated {args.yml} with mapped variables from {args.env}")


if __name__ == "__main__":
    main()
