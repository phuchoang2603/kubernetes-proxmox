# Environment name
env = "prod"

# S3 settings for remote state
s3_access_key                  = "terraform"
s3_secret_key                  = ""
s3_bucket                      = "terraform"
s3_key                         = "prod-terraform.tfstate"
s3_region                      = "us-east-1"
s3_endpoint                    = "http://10.69.1.102:9000"
s3_skip_credentials_validation = true
s3_skip_metadata_api_check     = true
s3_skip_region_validation      = true
s3_force_path_style            = true

# Proxmox API details - PLEASE FILL THESE IN
proxmox_endpoint       = "https://10.69.1.1:8006/"
proxmox_username       = "root@pam"
proxmox_password       = ""
proxmox_ssh_public_key = "" # Paste your ssh public key on your machine here

# General VM settings - PLEASE REVIEW AND ADJUST
vm_node_name    = "pve"           # Proxmox node where VMs are created
vm_datastore_id = "truenas-scale" # storage for downloading cloud img, storing snippets, etc.
vm_bridge       = "vmbr0"
vm_timezone     = "America/New_York"
vm_username     = "ubuntu"
vm_ip_gateway   = "10.69.0.1"
dns_server      = "1.1.1.1"

# k8s cluster settings
k8s_cpu_cores    = 2
k8s_cpu_type     = "x86-64-v2-AES"
k8s_memory_mb    = 4096
k8s_disk_size_gb = 64
k8s_datastore_id = "local-lvm"
k8s_nodes        = jsondecode(file("./k8s_nodes.json"))

# longhorn cluster settings
longhorn_cpu_cores    = 2
longhorn_cpu_type     = "x86-64-v2-AES"
longhorn_memory_mb    = 2048
longhorn_disk_size_gb = 300
longhorn_datastore_id = "local-lvm"
longhorn_nodes        = jsondecode(file("./longhorn_nodes.json"))
