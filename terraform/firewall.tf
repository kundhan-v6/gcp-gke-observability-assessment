resource "google_compute_firewall" "egress_observability" {
  name        = "assessment-egress-observability"
  network     = google_compute_network.main.id
  direction   = "EGRESS"
  priority    = 65534
  description = "Assessment egress rule used to demonstrate VPC firewall rule logging"

  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
