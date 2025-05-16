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

variable "vm_node_name" {
  description = "Proxmox node where VMs are created"
  type        = string
}
variable "vm_datastore_id" {
  description = "Proxmox datastore ID where VM disks are stored"
  type        = string
}
