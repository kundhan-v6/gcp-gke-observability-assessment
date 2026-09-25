resource "google_project_iam_member" "github_terraform_binauthz_policy_editor" {
  project = var.project_id
  role    = "roles/binaryauthorization.policyEditor"
  member  = "serviceAccount:github-terraform@gcp-gke-assessment.iam.gserviceaccount.com"
}
