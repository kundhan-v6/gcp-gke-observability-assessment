# Enable Service Networking API for Private Service Access
resource "google_project_service" "service_networking" {
  project            = var.project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# Cloud NAT - Primary Region
resource "google_compute_router" "primary_nat_router" {
  name    = "gke-primary-nat-router"
  region  = var.primary_region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "primary_nat" {
  name                               = "gke-primary-nat"
  router                             = google_compute_router.primary_nat_router.name
  region                             = var.primary_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

# Cloud NAT - Secondary Region
resource "google_compute_router" "secondary_nat_router" {
  name    = "gke-secondary-nat-router"
  region  = var.secondary_region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "secondary_nat" {
  name                               = "gke-secondary-nat"
  router                             = google_compute_router.secondary_nat_router.name
  region                             = var.secondary_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ALL"
  }
}

# Private Service Access reserved range
resource "google_compute_global_address" "private_service_access" {
  name          = "google-managed-services-gke-assessment-vpc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.70.0.0"
  prefix_length = 16
  network       = google_compute_network.main.id
}

# Private Service Access connection
resource "google_service_networking_connection" "private_service_access" {
  network = google_compute_network.main.id
  service = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [
    google_compute_global_address.private_service_access.name
  ]

  depends_on = [
    google_project_service.service_networking
  ]
}
