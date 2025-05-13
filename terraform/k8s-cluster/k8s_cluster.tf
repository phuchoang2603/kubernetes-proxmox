# Generate meta-data snippet per node (for hostname)
resource "proxmox_virtual_environment_file" "meta_data_per_node" {
  for_each     = var.k8s_nodes
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.vm_node_name

  source_raw {
    data = <<-EOF
    #cloud-config
    local-hostname: ${each.key}
    EOF

    file_name = "${each.key}-meta-data.yaml"
  }
}

# Clone VMs for masters and workers from the template
resource "proxmox_virtual_environment_vm" "k8s_node" {
  for_each = var.k8s_nodes

  name      = each.key
  node_name = var.vm_node_name
  vm_id     = each.value.vm_id

  clone {
    vm_id        = var.template_vm_id
    datastore_id = var.k8s_datastore_id
  }

  initialization {
    # dns {
    #   servers = ["1.1.1.1"]
    # }

    ip_config {
      ipv4 {
        address = each.value.address
        gateway = var.vm_ip_gateway
      }
    }

    meta_data_file_id = proxmox_virtual_environment_file.meta_data_per_node[each.key].id
  }
}
