
module "k8s_nodes" {
  source = "./modules/vm"

  for_each = var.k8s_nodes

  name              = each.key
  node_name         = each.value.node
  vm_id             = each.value.vm_id
  cpu_cores         = var.k8s_cpu_cores
  cpu_type          = var.k8s_cpu_type
  memory_mb         = var.k8s_memory_mb
  datastore_id      = var.k8s_datastore_id
  disk_file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  disk_size_gb      = var.k8s_disk_size_gb
  bridge            = var.vm_bridge
  dns_server        = var.dns_server
  ip_address        = each.value.address
  ip_gateway        = var.vm_ip_gateway
  user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config[each.key].id
}

module "longhorn_nodes" {
  source = "./modules/vm"

  for_each = var.longhorn_nodes

  name              = each.key
  node_name         = each.value.node
  vm_id             = each.value.vm_id
  cpu_cores         = var.longhorn_cpu_cores
  cpu_type          = var.longhorn_cpu_type
  memory_mb         = var.longhorn_memory_mb
  datastore_id      = var.longhorn_datastore_id
  disk_file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  disk_size_gb      = var.longhorn_disk_size_gb
  bridge            = var.vm_bridge
  dns_server        = var.dns_server
  ip_address        = each.value.address
  ip_gateway        = var.vm_ip_gateway
  user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config[each.key].id
}
