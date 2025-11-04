locals {
  k8s_nodes      = jsondecode(file("${path.root}/env/${var.env}/k8s_nodes.json"))
  longhorn_nodes = jsondecode(file("${path.root}/env/${var.env}/longhorn_nodes.json"))
}
