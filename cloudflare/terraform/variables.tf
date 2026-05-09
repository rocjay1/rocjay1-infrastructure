variable "cloudflare_api_token" {
  description = "API token with permissions for DNS edits and Zero Trust management."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
  default     = "a7107b56168148c0c72a7040d5f98c76"
}

variable "account_name" {
  description = "Cloudflare account name."
  type        = string
  default     = "rocjay1"
}

variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
  default     = "f5ddaca671ac53ee0442c5ea08772dcf"
}

variable "zone_name" {
  description = "Cloudflare zone name."
  type        = string
  default     = "roccosmodernsite.net"
}

variable "cloudflare_team_domain" {
  description = "Cloudflare Access team domain (for example, your-team-name)"
  type        = string
  default     = "rocjay1"
}

variable "entra_application_display_name" {
  description = "Display name to use for the Microsoft Entra application registration."
  type        = string
  default     = "Cloudflare Zero Trust"
}

variable "entra_client_secret_validity_days" {
  description = "Number of days before the generated client secret expires."
  type        = number
  default     = 365
}

variable "enable_email_optional_claim" {
  description = "Whether to publish the email claim in issued tokens for Cloudflare."
  type        = bool
  default     = true
}

variable "email_claim_name" {
  description = "Name of the email claim to include in tokens. Leave as email unless your organization uses a custom claim."
  type        = string
  default     = "email"
}

variable "entra_cloudflare_group_display_name" {
  description = "Display name for the Entra ID security group granting Cloudflare Zero Trust access."
  type        = string
  default     = "Cloudflare Zero Trust Users"
}

variable "entra_cloudflare_group_description" {
  description = "Description for the Entra ID security group."
  type        = string
  default     = "Users allowed to access internal applications via Cloudflare Zero Trust."
}

variable "uptime_check_secret" {
  description = "Secret value for the X-GCP-Uptime-Secret header to securely allow health checks."
  type        = string
  sensitive   = true
}
