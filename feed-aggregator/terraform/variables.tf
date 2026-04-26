variable "cloudflare_api_token" {
  description = "API token with permissions for Cloudflare Pages management."
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "project_name" {
  description = "The name of the Cloudflare Pages project."
  type        = string
  default     = "feed-aggregator"
}

variable "github_repo" {
  description = "The GitHub repository for the Pages project."
  type        = string
  default     = "rocjay1/feed-aggregator"
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
  description = "Subdomain to host the pages on."
  type        = string
  default     = "feeds"
}
