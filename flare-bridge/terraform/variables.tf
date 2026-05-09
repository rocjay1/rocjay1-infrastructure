variable "cloudflare_api_token" {
  description = "API token with permissions for Cloudflare management."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
  default     = "a7107b56168148c0c72a7040d5f98c76"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "flare-bridge"
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

variable "subdomain" {
  description = "Subdomain to host the aggregator on."
  type        = string
  default     = "feeds"
}
