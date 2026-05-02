variable "cloudflare_api_token" {
  description = "API token with permissions for Cloudflare management."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "feed-aggregator"
}

variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
}

variable "zone_name" {
  description = "Cloudflare zone name."
  type        = string
}

variable "subdomain" {
  description = "Subdomain to host the aggregator on."
  type        = string
  default     = "feeds"
}

variable "auth_username" {
  description = "Username for basic authentication."
  type        = string
  sensitive   = true
  default     = ""
}

variable "auth_password" {
  description = "Password for basic authentication."
  type        = string
  sensitive   = true
  default     = ""
}

variable "youtube_api_key" {
  description = "API key for YouTube data retrieval."
  type        = string
  sensitive   = true
  default     = ""
}
