variable "account_id" {
  type        = string
  description = "The Cloudflare Account ID."
}

variable "zone_id" {
  type        = string
  description = "The Cloudflare Zone ID."
}

variable "tunnel_name" {
  type        = string
  description = "The name for the Zero Trust Tunnel."
}

variable "cname_hostname" {
  type        = string
  description = "The subdomain/hostname for the CNAME record (e.g. 'rss')."
}

variable "ingress_rules" {
  description = "List of ingress rules for the tunnel config."
  type        = any
}

variable "warp_routing_enabled" {
  type        = bool
  description = "Whether warp routing is enabled."
  default     = false
}
