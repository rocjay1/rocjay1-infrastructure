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

variable "project_id" {
  description = "GCP project ID where Miniflux infrastructure is provisioned."
  type        = string
}

variable "region" {
  description = "GCP region for regional resources."
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "GCP zone for zonal resources."
  type        = string
  default     = "us-west1-b"
}

variable "machine_type" {
  description = "Machine type for the Miniflux VM."
  type        = string
  default     = "e2-micro"
}

variable "boot_image" {
  description = "Boot image for the Miniflux VM."
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "boot_disk_size_gb" {
  description = "Size in GB for the instance boot disk."
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "Disk type for the instance boot disk."
  type        = string
  default     = "pd-balanced"
}

variable "data_disk_size_gb" {
  description = "Size in GB for the persistent disk used by Docker data."
  type        = number
  default     = 20
}

variable "data_disk_type" {
  description = "Disk type for the persistent Docker data disk."
  type        = string
  default     = "pd-standard"
}

variable "assign_public_ip" {
  description = "Whether to assign an external IPv4 address to the instance. Disable for tunnel-only deployments."
  type        = bool
  default     = false
}

variable "create_static_ipv4" {
  description = "Whether to reserve and attach a static external IPv4 address. Requires assign_public_ip=true."
  type        = bool
  default     = false
}

variable "public_ingress_cidrs" {
  description = "Allowed source CIDRs for SSH ingress when assign_public_ip is enabled."
  type        = list(string)
  default     = []
}
