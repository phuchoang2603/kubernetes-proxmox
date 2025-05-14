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
  }
}
