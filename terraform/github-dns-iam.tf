resource "google_project_iam_member" "github_terraform_dns_admin" {
  project = var.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:github-terraform@gcp-gke-assessment.iam.gserviceaccount.com"
}
