data "local_file" "ssh_public_key" {
  filename = var.proxmox_ssh_public_key
}


resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.vm_node_name

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.vm_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    host-name: ubuntu_cloud_image
    timezone: $(var.vm_timezone)
    users:
      - default
      - name: ubuntu
        groups:
          - sudo
        shell: /bin/bash
        ssh_authorized_keys:
          - ${trimspace(data.local_file.ssh_public_key.content)}
        sudo: ALL=(ALL) NOPASSWD:ALL
    package_update: true
    packages:
      - qemu-guest-agent
      - net-tools
      - curl
    runcmd:
      - systemctl start qemu-guest-agent
      - qemu-guest-agent
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}
