data "local_file" "ssh_public_key" {
  filename = var.proxmox_ssh_public_key
}

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
          - ${trimspace(data.local_file.ssh_public_key.content)}
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
  for_each     = var.k8s_nodes
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

resource "proxmox_virtual_environment_vm" "k8s_node" {
  for_each = var.k8s_nodes

  name      = each.key
  node_name = each.value.node
  vm_id     = each.value.vm_id

  agent {
    enabled = true
  }

  stop_on_destroy = true
  machine         = "q35"
  bios            = "ovmf"
  description     = "Cloud-Init ready Kubernetes template managed by Terraform"

  cpu {
    cores = var.k8s_cpu_cores
    type  = var.k8s_cpu_type
  }

  memory {
    dedicated = var.k8s_memory_mb
  }

  efi_disk {
    datastore_id = var.k8s_datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.k8s_datastore_id
    file_id      = "${var.vm_datastore_id}:iso/noble-server-cloudimg-amd64.img"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.k8s_disk_size_gb
    ssd          = true
  }

  network_device {
    bridge = var.vm_bridge
  }

  initialization {
    dns {
      servers = [var.dns_server]
    }

    ip_config {
      ipv4 {
        address = each.value.address
        gateway = var.vm_ip_gateway
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config[each.key].id
  }
}

