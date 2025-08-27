variable "proxmox_endpoint" {
  type        = string
  description = "proxmox api endpoint (e.g., https://your-proxmox-ip:8006)"
}
variable "proxmox_insecure" {
  type        = bool
  description = "skip tls verification"
  default     = true
}
variable "proxmox_min_tls" {
  type        = string
  description = "minimum tls version"
  default     = "1.3"
}
variable "proxmox_username" {
  description = "proxmox username"
  type        = string
}
variable "proxmox_password" {
  description = "proxmox password"
  type        = string
  sensitive   = true
}
variable "proxmox_ssh_public_key" {
  description = "ssh public key for vm access"
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
variable "longhorn_nodes" {
  description = "Map of Kubernetes nodes with roles and IP addresses"
  type = map(object({
    vm_id   = number
    node    = string
    role    = string
    address = string
  }))
}
