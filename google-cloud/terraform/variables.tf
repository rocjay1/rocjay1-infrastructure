variable "project_id" {
  description = "The GCP project ID where management resources will be provisioned."
  type        = string
  default     = "abiding-cycle-464914-p6"
}

variable "region" {
  description = "The GCP region for provisioning resources."
  type        = string
  default     = "us-central1"
}

variable "github_org" {
  description = "The GitHub organization name."
  type        = string
  default     = "rocjay1"
}

variable "github_allowed_repos" {
  description = "A list of GitHub repositories allowed to use WIF for drift detection."
  type        = list(string)
  default     = ["github-mgmt", "rocjay1-infrastructure"]
}

variable "tfstate_bucket" {
  description = "The name of the GCS bucket storing Terraform state."
  type        = string
  default     = "daily-tech-brief-tfstate"
}

variable "managed_gcp_projects" {
  description = "A list of all GCP projects in the ecosystem that the drift detector needs to access."
  type        = list(string)
  default     = ["abiding-cycle-464914-p6", "miniflux-494022"]
}
