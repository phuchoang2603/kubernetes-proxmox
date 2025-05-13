vm_name          = "k8s-template"
vm_node_name     = "pve2"
vm_datastore_id  = "local-lvm"
vm_bridge        = "vmbr0"
vm_cpu_cores     = 2
vm_memory_mb     = 2048
vm_disk_size_gb  = 20
vm_timezone      = "Asia/Ho_Chi_Minh"
vm_ip_gateway    = "192.168.69.1"
template_vm_id   = 9000
k8s_datastore_id = "local-lvm"
k8s_nodes = {
  "master-1" = {
    vm_id   = 201
    role    = "master"
    address = "192.168.69.201/24"
  }
  "master-2" = {
    vm_id   = 202
    role    = "master"
    address = "192.168.69.202/24"
  }
  "worker-1" = {
    vm_id   = 211
    role    = "worker"
    address = "192.168.69.211/24"
  }
  "worker-2" = {
    vm_id   = 212
    role    = "worker"
    address = "192.168.69.212/24"
  }
  "worker-3" = {
    vm_id   = 213
    role    = "worker"
    address = "192.168.69.213/24"
  }
}
