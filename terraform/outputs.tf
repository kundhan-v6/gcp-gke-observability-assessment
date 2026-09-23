output "project_id" {
  description = "Google Cloud project ID"
  value       = data.google_project.current.project_id
}

output "project_number" {
  description = "Google Cloud numeric project identifier"
  value       = data.google_project.current.number
}

output "primary_region" {
  description = "Primary deployment region"
  value       = var.primary_region
}

output "secondary_region" {
  description = "Secondary deployment region"
  value       = var.secondary_region
}

output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "primary_subnet_name" {
  description = "Primary GKE subnet"
  value       = google_compute_subnetwork.primary.name
}

output "secondary_subnet_name" {
  description = "Secondary GKE subnet"
  value       = google_compute_subnetwork.secondary.name
}

output "primary_gke_cluster_name" {
  description = "Primary GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "primary_gke_cluster_location" {
  description = "Primary GKE cluster location"
  value       = google_container_cluster.primary.location
}

output "secondary_gke_cluster_name" {
  description = "Secondary GKE cluster name"
  value       = google_container_cluster.secondary.name
}

output "secondary_gke_cluster_location" {
  description = "Secondary GKE cluster location"
  value       = google_container_cluster.secondary.location
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository name"
  value       = google_artifact_registry_repository.apps.repository_id
}

output "artifact_registry_location" {
  description = "Artifact Registry location"
  value       = google_artifact_registry_repository.apps.location
}
