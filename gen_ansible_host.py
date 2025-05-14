#!/usr/bin/env python3

import json
import argparse


def parse_args():
    parser = argparse.ArgumentParser(
        description="Generate Ansible INI inventory from k8s_nodes.json"
    )
    parser.add_argument("-j", "--json", required=True, help="Path to k8s_nodes.json")
    parser.add_argument(
        "-o", "--output", required=True, help="Path to output hosts.ini"
    )
    return parser.parse_args()


def load_nodes(json_file):
    with open(json_file) as f:
        return json.load(f)


def generate_inventory(nodes):
    masters = []
    workers = []

    for name, info in nodes.items():
        ip = info["address"].split("/")[0]  # remove /24 if present
        if info["role"] == "master":
            masters.append(ip)
        elif info["role"] == "node":
            workers.append(ip)

    # Generate INI style
    inventory = []
    inventory.append("[master]")
    inventory.extend(masters)
    inventory.append("")

    inventory.append("[node]")
    inventory.extend(workers)
    inventory.append("")

    inventory.append("[k3s_cluster:children]")
    inventory.append("master")
    inventory.append("node")

    return "\n".join(inventory)


def main():
    args = parse_args()
    nodes = load_nodes(args.json)
    inventory_content = generate_inventory(nodes)

    with open(args.output, "w") as f:
        f.write(inventory_content + "\n")

    print(f"✅ Inventory generated at {args.output}")


if __name__ == "__main__":
    main()
