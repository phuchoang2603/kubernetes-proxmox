variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint (e.g., https://your-proxmox-ip:8006)"
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
variable "proxmox_username" {
  description = "Proxmox username"
  type        = string
}
variable "proxmox_password" {
  description = "Proxmox password"
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

# Authentik OIDC Configuration
variable "authentik_url" {
  description = "URL of the Authentik instance (e.g., https://authentik.example.com)"
  type        = string
}

variable "authentik_token" {
  description = "API token for Authentik (create in Admin UI -> Tokens)"
  type        = string
  sensitive   = true
}

variable "kubernetes_client_id" {
  description = "OIDC client ID for Kubernetes"
  type        = string
  default     = "kubernetes"
}

variable "kubernetes_redirect_uris" {
  description = "List of allowed redirect URIs for kubectl OIDC callback"
  type        = list(string)
  default = [
    "http://localhost:8000",
    "http://localhost:18000"
  ]
}

variable "group_mappings" {
  description = "Map of group names to create in Authentik"
  type = map(object({
    name        = string
    description = string
  }))
  default = {
    admins = {
      name        = "kubernetes-admins"
      description = "Kubernetes cluster administrators with full access"
    }
    developers = {
      name        = "kubernetes-developers"
      description = "Kubernetes developers with namespace-level access"
    }
    viewers = {
      name        = "kubernetes-viewers"
      description = "Kubernetes viewers with read-only access"
    }
  }
}
