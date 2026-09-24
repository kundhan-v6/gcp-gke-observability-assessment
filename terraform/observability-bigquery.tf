resource "google_bigquery_dataset" "observability" {
  project       = var.project_id
  dataset_id    = "gke_observability"
  friendly_name = "GKE Observability"
  description   = "Application and GKE platform logs for the assessment"
  location      = "US"

  # Limit newly created partitioned log tables to 30 days of retention.
  default_partition_expiration_ms = 2592000000

  # A test cleanup must not silently delete a dataset containing log evidence.
  delete_contents_on_destroy = false

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_logging_project_sink" "gke_to_bigquery" {
  project     = var.project_id
  name        = "gke-observability-bq"
  description = "Export application requests and GKE platform logs from both clusters"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.observability.dataset_id}"

  # App traffic and GKE platform logs for both clusters.
  # Exclude frequent application health checks to reduce unnecessary ingestion.
  filter = <<-EOT
    (
      resource.type="k8s_container"
      AND resource.labels.namespace_name="assessment"
      AND (
        resource.labels.container_name="app-a"
        OR resource.labels.container_name="app-b"
      )
      AND jsonPayload.path!="/health"
    )
    OR
    (
      (
        resource.type="k8s_node"
        OR resource.type="k8s_cluster"
        OR resource.type="k8s_pod"
        OR resource.type="k8s_control_plane_component"
      )
      AND (
        resource.labels.cluster_name="gke-primary"
        OR resource.labels.cluster_name="gke-secondary"
      )
    )
    OR
    (
      resource.type="gce_subnetwork"
      AND logName="projects/${var.project_id}/logs/compute.googleapis.com%2Fvpc_flows"
      AND (
        resource.labels.subnetwork_name="gke-primary-subnet"
        OR resource.labels.subnetwork_name="gke-secondary-subnet"
      )
    )
    OR
    (
      resource.type="gce_subnetwork"
      AND logName="projects/${var.project_id}/logs/compute.googleapis.com%2Ffirewall"
      AND (
        resource.labels.subnetwork_name="gke-primary-subnet"
        OR resource.labels.subnetwork_name="gke-secondary-subnet"
      )
    )
  EOT

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }
}

resource "google_bigquery_dataset_iam_member" "logging_writer" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.observability.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.gke_to_bigquery.writer_identity
}
