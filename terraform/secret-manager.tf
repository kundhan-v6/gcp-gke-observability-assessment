resource "google_secret_manager_secret" "app_runtime_secret" {
  project   = "gcp-gke-assessment"
  secret_id = "assessment-runtime-secret"

  replication {
    auto {}
  }

  labels = {
    environment = "assessment"
    managed_by  = "terraform"
  }
}

resource "google_secret_manager_secret_iam_member" "app_runtime_secret_access" {
  project   = google_secret_manager_secret.app_runtime_secret.project
  secret_id = google_secret_manager_secret.app_runtime_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"

  member = "serviceAccount:gke-app-runtime@gcp-gke-assessment.iam.gserviceaccount.com"
}

resource "google_secret_manager_secret_version" "app_runtime_secret_version" {
  secret                 = google_secret_manager_secret.app_runtime_secret.id
  secret_data_wo         = var.app_demo_secret
  secret_data_wo_version = var.app_demo_secret_wo_version
}

output "app_runtime_secret_resource" {
  description = "Secret Manager resource mounted by GKE workloads"
  value       = google_secret_manager_secret.app_runtime_secret.id
}
