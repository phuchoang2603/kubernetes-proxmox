resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.vm_datastore_id
  node_name    = var.vm_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    host-name: ubuntu_cloud_image
    timezone: ${var.vm_timezone}
    users:
      - default
      - name: ${var.vm_username}
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.proxmox_ssh_public_key}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
      - cryptsetup
    runcmd:
      - systemctl start qemu-guest-agent
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  for_each     = merge(local.k8s_nodes, local.longhorn_nodes)
  content_type = "snippets"
  datastore_id = var.vm_datastore_id
  node_name    = var.vm_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: ${each.key}
    EOF

    file_name = "${each.key}-meta-data-cloud-config.yaml"
  }
}
