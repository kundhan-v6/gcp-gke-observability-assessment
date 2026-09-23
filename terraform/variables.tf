variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = "gcp-gke-assessment"
}

variable "primary_region" {
  description = "Primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "secondary_region" {
  description = "Secondary GCP region for the second GKE cluster"
  type        = string
  default     = "us-east1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "assessment"
}

variable "primary_zone" {
  description = "Zone for the primary GKE cluster"
  type        = string
  default     = "us-central1-a"
}

variable "secondary_zone" {
  description = "Zone for the secondary GKE cluster"
  type        = string
  default     = "us-east1-b"
}
