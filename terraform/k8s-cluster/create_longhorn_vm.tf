resource "proxmox_virtual_environment_vm" "longhorn_node" {
  for_each = var.longhorn_nodes

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
    cores = var.longhorn_cpu_cores
    type  = var.longhorn_cpu_type
  }

  memory {
    dedicated = var.longhorn_memory_mb
  }

  efi_disk {
    datastore_id = var.longhorn_datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.longhorn_datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.longhorn_disk_size_gb
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

