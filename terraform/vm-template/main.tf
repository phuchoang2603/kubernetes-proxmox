terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.1"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure
  min_tls   = var.proxmox_min_tls

  ssh {
    agent       = false
    username    = var.proxmox_ssh_username
    private_key = var.proxmox_ssh_private_key
  }
}

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
    runcmd:
      - systemctl start qemu-guest-agent
      - qemu-guest-agent
    EOF

    file_name = "user-data-cloud-config.yaml"
  }
}

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
