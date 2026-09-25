resource "google_project_iam_member" "github_terraform_gke_restore_admin" {
  project = var.project_id
  role    = "roles/gkebackup.restoreAdmin"
  member  = "serviceAccount:github-terraform@gcp-gke-assessment.iam.gserviceaccount.com"
}

resource "google_gke_backup_restore_plan" "primary_to_secondary" {
  project     = var.project_id
  name        = "gke-primary-to-secondary-restore"
  location    = var.secondary_region
  backup_plan = google_gke_backup_backup_plan.primary.id
  cluster     = google_container_cluster.secondary.id

  restore_config {
    selected_namespaces {
      namespaces = ["assessment"]
    }

    namespaced_resource_restore_mode = "MERGE_REPLACE_ON_CONFLICT"
    volume_data_restore_policy       = "RESTORE_VOLUME_DATA_FROM_BACKUP"

    cluster_resource_restore_scope {
      no_group_kinds = true
    }
  }

  depends_on = [
    google_project_iam_member.github_terraform_gke_restore_admin
  ]
}

resource "google_gke_backup_restore_plan" "secondary_to_primary" {
  project     = var.project_id
  name        = "gke-secondary-to-primary-restore"
  location    = var.primary_region
  backup_plan = google_gke_backup_backup_plan.secondary.id
  cluster     = google_container_cluster.primary.id

  restore_config {
    selected_namespaces {
      namespaces = ["assessment"]
    }

    namespaced_resource_restore_mode = "MERGE_REPLACE_ON_CONFLICT"
    volume_data_restore_policy       = "RESTORE_VOLUME_DATA_FROM_BACKUP"

    cluster_resource_restore_scope {
      no_group_kinds = true
    }
  }

  depends_on = [
    google_project_iam_member.github_terraform_gke_restore_admin
  ]
}
