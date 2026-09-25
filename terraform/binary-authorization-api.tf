resource "google_project_service" "binary_authorization" {
  project            = var.project_id
  service            = "binaryauthorization.googleapis.com"
  disable_on_destroy = false
}
