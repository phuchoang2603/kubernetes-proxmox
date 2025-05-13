variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint (e.g., https://your-proxmox-ip:8006)"
}
variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API Token"
}
variable "proxmox_insecure" {
  type        = bool
  description = "Skip TLS verification"
  default     = true
}
variable "proxmox_min_tls" {
  type        = string
  description = "Minimum TLS version"
  default     = "1.3"
}
variable "proxmox_ssh_username" {
  description = "SSH username for Proxmox node access"
  type        = string
}
variable "proxmox_ssh_private_key" {
  description = "SSH private key for Proxmox node access (PEM format)"
  type        = string
  sensitive   = true
}
variable "proxmox_ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "vm_name" {
  description = "Default VM name or template name"
  type        = string
}
variable "vm_node_name" {
  description = "Proxmox node where VMs are created"
  type        = string
}
variable "vm_datastore_id" {
  description = "Proxmox datastore ID where VM disks are stored"
  type        = string
}
variable "vm_bridge" {
  description = "Network bridge used for VM network"
  type        = string
}
variable "vm_cpu_cores" {
  description = "Number of CPU cores per VM"
  type        = number
}
variable "vm_memory_mb" {
  description = "Memory size in MB per VM"
  type        = number
}
variable "vm_disk_size_gb" {
  description = "Disk size in GB for VM disk"
  type        = number
}
variable "vm_timezone" {
  description = "Timezone for the VM"
  type        = string
}
variable "vm_ip_gateway" {
  description = "Gateway for Kubernetes VMs"
  type        = string
}
variable "template_vm_id" {
  description = "VM template ID to clone from"
  type        = number
}
variable "k8s_datastore_id" {
  description = "k8s datastore ID where VM disks are stored"
  type        = string
}
variable "k8s_nodes" {
  description = "Map of Kubernetes nodes with roles and IP addresses"
  type = map(object({
    vm_id   = number
    role    = string
    address = string
  }))
}
