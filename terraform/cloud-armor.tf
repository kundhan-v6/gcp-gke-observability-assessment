resource "google_compute_security_policy" "gke_mci_armor" {
  project     = var.project_id
  name        = "gke-mci-cloud-armor"
  description = "Cloud Armor WAF policy for GKE multi-cluster applications"
  type        = "CLOUD_ARMOR"

  rule {
    action   = "deny(403)"
    priority = 1000

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-v422-stable')"
      }
    }

    description = "Block SQL injection attempts"
  }

  rule {
    action   = "deny(403)"
    priority = 1100

    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v422-stable')"
      }
    }

    description = "Block cross-site scripting attempts"
  }

  rule {
    action   = "allow"
    priority = 2147483647

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "Default allow"
  }
}

output "cloud_armor_policy_name" {
  value = google_compute_security_policy.gke_mci_armor.name
}
