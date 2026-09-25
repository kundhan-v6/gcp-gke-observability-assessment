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
