resource "google_project_service" "gke_backup" {
  project            = var.project_id
  service            = "gkebackup.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "github_terraform_gke_backup_admin" {
  project = var.project_id
  role    = "roles/gkebackup.backupAdmin"
  member  = "serviceAccount:github-terraform@gcp-gke-assessment.iam.gserviceaccount.com"
}

resource "google_gke_backup_backup_plan" "primary" {
  project     = var.project_id
  name        = "gke-primary-dr-backup"
  cluster     = google_container_cluster.primary.id
  location    = var.secondary_region
  description = "Cross-region scheduled backup plan for the primary GKE cluster"

  retention_policy {
    backup_retain_days = 7
  }

  backup_schedule {
    cron_schedule = "0 3 * * *"
  }

  backup_config {
    include_volume_data = true
    include_secrets     = true
    all_namespaces      = true
  }

  labels = {
    environment = var.environment
    source      = "gke-primary"
    managed_by  = "terraform"
  }

  deletion_policy = "PREVENT"

  depends_on = [
    google_project_service.gke_backup,
    google_project_iam_member.github_terraform_gke_backup_admin
  ]
}

resource "google_gke_backup_backup_plan" "secondary" {
  project     = var.project_id
  name        = "gke-secondary-dr-backup"
  cluster     = google_container_cluster.secondary.id
  location    = var.primary_region
  description = "Cross-region scheduled backup plan for the secondary GKE cluster"

  retention_policy {
    backup_retain_days = 7
  }

  backup_schedule {
    cron_schedule = "30 3 * * *"
  }

  backup_config {
    include_volume_data = true
    include_secrets     = true
    all_namespaces      = true
  }

  labels = {
    environment = var.environment
    source      = "gke-secondary"
    managed_by  = "terraform"
  }

  deletion_policy = "PREVENT"

  depends_on = [
    google_project_service.gke_backup,
    google_project_iam_member.github_terraform_gke_backup_admin
  ]
}
