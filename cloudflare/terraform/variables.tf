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

variable "uptime_check_secret" {
  description = "Secret value for the X-GCP-Uptime-Secret header to securely allow health checks."
  type        = string
  sensitive   = true
}
