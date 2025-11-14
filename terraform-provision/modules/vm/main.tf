
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.name
  node_name = var.node_name
  vm_id     = var.vm_id

  agent {
    enabled = true
  }

  stop_on_destroy = true
  machine         = "q35"
  bios            = "ovmf"
  description     = "Cloud-Init ready Kubernetes template managed by Terraform"

  cpu {
    cores = var.cpu_cores
    type  = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
  }

  efi_disk {
    datastore_id = var.datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.datastore_id
    file_id      = var.disk_file_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size_gb
    ssd          = true
  }

  network_device {
    bridge = var.bridge
  }

  initialization {
    dns {
      servers = [var.dns_server]
    }

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.ip_gateway
      }
    }

    user_data_file_id = var.user_data_file_id
    meta_data_file_id = var.meta_data_file_id
  }
}
