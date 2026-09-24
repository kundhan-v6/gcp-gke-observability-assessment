resource "google_project_service" "gkehub" {
  project = var.project_id
  service = "gkehub.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "multicluster_ingress" {
  project = var.project_id
  service = "multiclusteringress.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "multicluster_service_discovery" {
  project = var.project_id
  service = "multiclusterservicediscovery.googleapis.com"

  disable_on_destroy = false
}

resource "google_gke_hub_membership" "primary" {
  project       = var.project_id
  membership_id = "gke-primary"
  location      = "global"

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.primary.id}"
    }
  }

  authority {
    issuer = "https://container.googleapis.com/v1/${google_container_cluster.primary.id}"
  }

  depends_on = [
    google_project_service.gkehub
  ]
}

resource "google_gke_hub_membership" "secondary" {
  project       = var.project_id
  membership_id = "gke-secondary"
  location      = "global"

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.secondary.id}"
    }
  }

  authority {
    issuer = "https://container.googleapis.com/v1/${google_container_cluster.secondary.id}"
  }

  depends_on = [
    google_project_service.gkehub
  ]
}
