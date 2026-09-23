resource "google_container_cluster" "primary" {
  name     = "gke-primary"
  location = var.primary_region

  enable_autopilot = true

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.primary.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-primary-pods"
    services_secondary_range_name = "gke-primary-services"
  }

  release_channel {
    channel = "REGULAR"
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
  location = var.secondary_region

  enable_autopilot = true

  network    = google_compute_network.main.id
  subnetwork = google_compute_subnetwork.secondary.id

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-secondary-pods"
    services_secondary_range_name = "gke-secondary-services"
  }

  release_channel {
    channel = "REGULAR"
  }

  deletion_protection = false

  resource_labels = {
    environment  = var.environment
    cluster_role = "secondary"
    managed_by   = "terraform"
  }
}
