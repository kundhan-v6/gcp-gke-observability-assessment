resource "google_container_node_pool" "primary_apps" {
  name     = "apps-pool"
  cluster  = google_container_cluster.primary.name
  location = var.primary_zone

  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_type    = "pd-balanced"
    disk_size_gb = 30

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      environment = var.environment
      workload    = "applications"
    }
  }
}

resource "google_container_node_pool" "secondary_apps" {
  name     = "apps-pool"
  cluster  = google_container_cluster.secondary.name
  location = var.secondary_zone

  node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_type    = "pd-balanced"
    disk_size_gb = 30

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      environment = var.environment
      workload    = "applications"
    }
  }
}
