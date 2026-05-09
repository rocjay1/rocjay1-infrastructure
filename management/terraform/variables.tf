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

variable "github_mgmt_repo" {
  description = "The name of the repository that will use WIF."
  type        = string
  default     = "github-mgmt"
}

variable "tfstate_bucket" {
  description = "The name of the GCS bucket storing Terraform state."
  type        = string
  default     = "daily-tech-brief-tfstate"
}
