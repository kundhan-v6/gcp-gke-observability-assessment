# Dedicated identity for Grafana's assessment data sources.
# Do not create or store a service-account key in Terraform.

resource "google_service_account" "grafana_reader" {
  project      = var.project_id
  account_id   = "grafana-assessment-reader"
  display_name = "Grafana assessment data-source reader"
}

# Read GKE and application metrics from Google Cloud Monitoring.
resource "google_project_iam_member" "grafana_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = google_service_account.grafana_reader.member
}

# Run BigQuery SELECT queries without permission to modify log tables.
resource "google_project_iam_member" "grafana_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.grafana_reader.member
}

# Allow Grafana's BigQuery data source to discover the GCP project.
resource "google_project_iam_member" "grafana_project_browser" {
  project = var.project_id
  role    = "roles/browser"
  member  = google_service_account.grafana_reader.member
}

# Restrict BigQuery data access to our assessment log dataset.
resource "google_bigquery_dataset_iam_member" "grafana_logs_reader" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.observability.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = google_service_account.grafana_reader.member
}
