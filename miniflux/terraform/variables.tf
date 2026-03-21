variable "cloudflare_api_token" {
  description = "API token with permissions for DNS edits and Zero Trust tunnel management."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
}

variable "zone_name" {
  description = "Cloud zone name"
  type        = string
}

variable "miniflux_hostname" {
  description = "Public hostname for the Miniflux app"
  type        = string
  default     = "rss"
}

variable "miniflux_tunnel_name" {
  description = "Friendly name for the Miniflux Cloudflare tunnel"
  type        = string
  default     = "miniflux-tunnel"
}
