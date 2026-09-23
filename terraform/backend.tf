terraform {
  backend "gcs" {
    bucket = "gcp-gke-assessment-tfstate-154908148121"
    prefix = "terraform/state"
  }
}
