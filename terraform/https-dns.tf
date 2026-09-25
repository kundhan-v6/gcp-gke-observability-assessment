data "google_dns_managed_zone" "photography" {
  project = var.project_id
  name    = "kundhanphotography-com"
}

resource "google_dns_record_set" "gke_endpoint" {
  project      = var.project_id
  managed_zone = data.google_dns_managed_zone.photography.name
  name         = "gke.kundhanphotography.com."
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_global_address.mci_global_ip.address
  ]

  lifecycle {
    prevent_destroy = true
  }
}

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
  to = google_dns_record_set.gke_endpoint
  id = "projects/gcp-gke-assessment/managedZones/kundhanphotography-com/rrsets/gke.kundhanphotography.com./A"
}

import {
  to = google_compute_managed_ssl_certificate.gke_endpoint
  id = "projects/gcp-gke-assessment/global/sslCertificates/gke-kundhanphotography-cert"
}
