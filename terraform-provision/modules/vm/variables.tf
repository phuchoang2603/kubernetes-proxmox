
variable "name" {
  description = "The name of the VM."
  type        = string
}

variable "node_name" {
  description = "The name of the Proxmox node where the VM will be created."
  type        = string
}

variable "vm_id" {
  description = "The ID of the VM."
  type        = number
}

variable "cpu_cores" {
  description = "The number of CPU cores for the VM."
  type        = number
}

variable "cpu_type" {
  description = "The CPU type for the VM."
  type        = string
}

variable "memory_mb" {
  description = "The memory size in MB for the VM."
  type        = number
}

variable "datastore_id" {
  description = "The datastore ID where the VM disk will be stored."
  type        = string
}

variable "disk_file_id" {
  description = "The ID of the disk file to use for the VM."
  type        = string
}

variable "disk_size_gb" {
  description = "The disk size in GB for the VM."
  type        = number
}

variable "bridge" {
  description = "The network bridge for the VM."
  type        = string
}

variable "dns_server" {
  description = "The DNS server for the VM."
  type        = string
}

variable "ip_address" {
  description = "The IP address of the VM."
  type        = string
}

variable "ip_gateway" {
  description = "The IP gateway for the VM."
  type        = string
}

variable "user_data_file_id" {
  description = "The ID of the user data file for cloud-init."
  type        = string
}

variable "meta_data_file_id" {
  description = "The ID of the meta data file for cloud-init."
  type        = string
}
