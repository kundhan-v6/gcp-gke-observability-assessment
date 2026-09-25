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

variable "dev_members" {
  description = "IAM members for developers"
  type        = list(string)
  default     = []
}

variable "ops_members" {
  description = "IAM members for operations engineers"
  type        = list(string)
  default     = []
}

variable "sre_members" {
  description = "IAM members for SRE engineers"
  type        = list(string)
  default     = []
}

variable "app_demo_secret" {
  description = "Application demo secret written to Secret Manager through the provider write-only argument"
  type        = string
  sensitive   = true
}

variable "app_demo_secret_wo_version" {
  description = "Write-only version token used to trigger creation or rotation of the Secret Manager version"
  type        = string
  default     = "1"
}
