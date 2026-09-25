resource "google_binary_authorization_policy" "assessment" {
  depends_on = [google_project_service.binary_authorization]

  project = var.project_id

  description = "Assessment Binary Authorization policy in dry-run mode"

  global_policy_evaluation_mode = "ENABLE"

  default_admission_rule {
    evaluation_mode  = "ALWAYS_DENY"
    enforcement_mode = "DRYRUN_AUDIT_LOG_ONLY"
  }
}
