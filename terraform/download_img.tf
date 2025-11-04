resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.vm_datastore_id
  node_name    = var.vm_node_name
  file_name = "${var.env}-noble-server-cloudimg-amd64.img"

  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}
