resource "google_compute_global_address" "mci_global_ip" {
  project      = var.project_id
  name         = "gke-multicluster-global-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  description = "Global static IP for GKE Multi Cluster Ingress"
}

output "mci_global_ip" {
  description = "Global static IPv4 address used by Multi Cluster Ingress"
  value       = google_compute_global_address.mci_global_ip.address
}
