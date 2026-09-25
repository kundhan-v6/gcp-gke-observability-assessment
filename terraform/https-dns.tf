resource "google_compute_managed_ssl_certificate" "gke_endpoint" {
  project = var.project_id
  name    = "gke-kundhanphotography-cert"

  managed {
    domains = ["gke.kundhanphotography.com"]
  }

  lifecycle {
    prevent_destroy = true
  }
}

import {
  to = google_compute_managed_ssl_certificate.gke_endpoint
  id = "projects/gcp-gke-assessment/global/sslCertificates/gke-kundhanphotography-cert"
}
