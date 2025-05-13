resource "proxmox_virtual_environment_vm" "k8s_template" {
  name      = var.vm_name
  node_name = var.vm_node_name
  vm_id     = var.template_vm_id

  agent {
    enabled = true
  }

  template        = true
  started         = false
  stop_on_destroy = true

  machine     = "q35"
  bios        = "ovmf"
  description = "Cloud-Init ready Kubernetes template managed by Terraform"

  cpu {
    cores = var.vm_cpu_cores
  }

  memory {
    dedicated = var.vm_memory_mb
  }

  efi_disk {
    datastore_id = var.vm_datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.vm_disk_size_gb
  }

  network_device {
    bridge = var.vm_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }
}
