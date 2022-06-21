resource "google_container_cluster" "primary" {
  provider                 = google-beta
  name                     = var.cluster_name
  location                 = var.cluster_region
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = "kubernetes"

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_pool_nodes" {
  count      = length(var.node_zones)
  name       = "node-pool-${count.index + 1}"
  location   = var.cluster_region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  node_locations = [
    var.node_zones[count.index]
  ]
  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }
  node_config {
    preemptible  = true
    machine_type = var.machine_type
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}