resource "google_project_service" "cloudtrace" {
  project            = var.project_id
  service            = "cloudtrace.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudprofiler" {
  project            = var.project_id
  service            = "cloudprofiler.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "errorreporting" {
  project            = var.project_id
  service            = "clouderrorreporting.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "app_runtime" {
  project      = var.project_id
  account_id   = "gke-app-runtime"
  display_name = "GKE application runtime identity"
}

resource "google_project_iam_member" "app_runtime_trace" {
  project = var.project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${google_service_account.app_runtime.email}"
}

resource "google_project_iam_member" "app_runtime_profiler" {
  project = var.project_id
  role    = "roles/cloudprofiler.agent"
  member  = "serviceAccount:${google_service_account.app_runtime.email}"
}

resource "google_project_iam_member" "app_runtime_error_reporting" {
  project = var.project_id
  role    = "roles/errorreporting.writer"
  member  = "serviceAccount:${google_service_account.app_runtime.email}"
}

resource "google_service_account_iam_member" "app_runtime_workload_identity" {
  service_account_id = google_service_account.app_runtime.name
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${var.project_id}.svc.id.goog[assessment/app-runtime]"
}

output "app_runtime_service_account" {
  value = google_service_account.app_runtime.email
}
