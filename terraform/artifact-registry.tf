resource "google_artifact_registry_repository" "apps" {
  location      = "us"
  repository_id = "gke-apps"
  description   = "Docker images for GKE assessment applications"
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "keep-tagged-images"
    action = "KEEP"

    condition {
      tag_state = "TAGGED"
    }
  }

  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old-untagged"
    action = "DELETE"

    condition {
      tag_state  = "UNTAGGED"
      older_than = "30d"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_artifact_registry_repository_iam_member" "gke_nodes_reader" {
  project    = var.project_id
  location   = google_artifact_registry_repository.apps.location
  repository = google_artifact_registry_repository.apps.repository_id
  role       = "roles/artifactregistry.reader"

  member = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}
