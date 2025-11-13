variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "vm_node_name" {
  description = "Proxmox node where VMs are created"
  type        = string
}
variable "vm_datastore_id" {
  description = "Proxmox datastore ID where snippets cloud img are stored"
  type        = string
}
variable "vm_bridge" {
  description = "Network bridge used for VM network"
  type        = string
}
variable "vm_timezone" {
  description = "Timezone for the VM"
  type        = string
}
variable "vm_username" {
  description = "Username for the VM template"
  type        = string
}
variable "vm_ip_gateway" {
  description = "Gateway for Kubernetes VMs"
  type        = string
}
variable "dns_server" {
  description = "DNS server for Kubernetes VMs"
  type        = string
}

variable "k8s_cpu_cores" {
  description = "Number of CPU cores per VM"
  type        = number
}
variable "k8s_cpu_type" {
  description = "CPU type for VM"
  type        = string
}
variable "k8s_memory_mb" {
  description = "Memory size in MB per VM"
  type        = number
}
variable "k8s_datastore_id" {
  description = "k8s datastore ID where VM disks are stored"
  type        = string
}
variable "k8s_disk_size_gb" {
  description = "Disk size in GB for VM disk"
  type        = number
}


variable "longhorn_cpu_cores" {
  description = "Number of CPU cores per VM"
  type        = number
}
variable "longhorn_cpu_type" {
  description = "CPU type for VM"
  type        = string
}
variable "longhorn_memory_mb" {
  description = "Memory size in MB per VM"
  type        = number
}
variable "longhorn_datastore_id" {
  description = "longhorn datastore ID where VM disks are stored"
  type        = string
}
variable "longhorn_disk_size_gb" {
  description = "Disk size in GB for VM disk"
  type        = number
}

locals {
  k8s_nodes      = jsondecode(file("${path.root}/env/${var.env}/k8s_nodes.json"))
  longhorn_nodes = jsondecode(file("${path.root}/env/${var.env}/longhorn_nodes.json"))
}

data "vault_generic_secret" "proxmox" {
  path = "kv/${var.env}/proxmox"
}

