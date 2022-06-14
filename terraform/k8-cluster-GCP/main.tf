resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.cluster_region
  remove_default_node_pool = true
  initial_node_count       = 1
  network = "kubernetes"
}

resource "google_container_node_pool" "primary_pool_nodes" {
  count      = length(var.node_zones)
  name       = "node-pool-${count.index+1}"
  location   = var.cluster_region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  node_locations = [
    var.node_zones[count.index]
  ]
  node_config {
    preemptible  = true
    machine_type = var.machine_type

    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}