resource "google_container_cluster" "primary" {
  name     = "gke-primary"
  location = var.primary_zone

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.primary.id

  initial_node_count = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-primary-pods"
    services_secondary_range_name = "gke-primary-services"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

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
      environment  = var.environment
      cluster_role = "primary"
    }
  }

  deletion_protection = false

  resource_labels = {
    environment  = var.environment
    cluster_role = "primary"
    managed_by   = "terraform"
  }
}

resource "google_container_cluster" "secondary" {
  name     = "gke-secondary"
  location = var.secondary_zone

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.secondary.id

  initial_node_count = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-secondary-pods"
    services_secondary_range_name = "gke-secondary-services"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

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
      environment  = var.environment
      cluster_role = "secondary"
    }
  }

  deletion_protection = false

  resource_labels = {
    environment  = var.environment
    cluster_role = "secondary"
    managed_by   = "terraform"
  }
}
