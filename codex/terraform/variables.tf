variable "project_id" {
  description = "Google Cloud project ID where Codex resources should be provisioned."
  type        = string
  default     = "miniflux-494022"
}

variable "manage_required_project_services" {
  description = "Whether Terraform should enable the IAM and Secret Manager APIs required by this workspace."
  type        = bool
  default     = true
}

variable "service_account_id" {
  description = "Account ID for the Codex service account. Must be 6-30 lowercase letters, digits, or hyphens."
  type        = string
  default     = "codex-environment"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "service_account_id must be 6-30 characters, start with a lowercase letter, end with a lowercase letter or digit, and contain only lowercase letters, digits, or hyphens."
  }
}

variable "service_account_display_name" {
  description = "Display name for the Codex service account."
  type        = string
  default     = "Codex Environment"
}

variable "additional_service_account_project_roles" {
  description = "Additional project-level IAM roles to grant to the Codex service account. Miniflux-required roles are always granted."
  type        = list(string)
  default     = []
}

variable "service_account_key_secret_id" {
  description = "Secret Manager secret ID used to store the Codex service account JSON key."
  type        = string
  default     = "codex-service-account-key"
}

variable "service_account_key_secret_accessor_members" {
  description = "Optional IAM members that can read the Codex service account key secret, for example user:name@example.com or group:admins@example.com."
  type        = list(string)
  default     = []
}
