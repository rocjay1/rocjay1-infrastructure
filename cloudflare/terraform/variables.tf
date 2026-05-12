variable "cloudflare_api_token" {
  description = "API token with permissions for DNS edits and Zero Trust management."
  type        = string
  sensitive   = true
}

variable "uptime_check_secret" {
  description = "Secret value for the X-GCP-Uptime-Secret header to securely allow health checks."
  type        = string
  sensitive   = true
}
