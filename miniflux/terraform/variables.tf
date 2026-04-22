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

  validation {
    condition     = var.region == "us-west1"
    error_message = "Miniflux must stay in us-west1 for the selected free-tier target."
  }
}

variable "zone" {
  description = "GCP zone for zonal resources."
  type        = string
  default     = "us-west1-b"

  validation {
    condition     = var.zone == "us-west1-b"
    error_message = "Miniflux must stay in us-west1-b for the selected free-tier target."
  }
}

variable "machine_type" {
  description = "Machine type for the Miniflux VM."
  type        = string
  default     = "e2-micro"

  validation {
    condition     = var.machine_type == "e2-micro"
    error_message = "Only e2-micro is allowed for the low-cost/free-tier Miniflux VM."
  }
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

  validation {
    condition     = var.boot_disk_size_gb <= 30
    error_message = "Boot disk must be 30 GB or smaller to stay within the intended free-tier disk budget."
  }
}

variable "boot_disk_type" {
  description = "Disk type for the instance boot disk."
  type        = string
  default     = "pd-standard"

  validation {
    condition     = var.boot_disk_type == "pd-standard"
    error_message = "Use pd-standard for the boot disk to keep costs low."
  }
}

variable "data_disk_size_gb" {
  description = "Size in GB for the persistent disk used by Docker data."
  type        = number
  default     = 10

  validation {
    condition     = var.data_disk_size_gb >= 10 && var.data_disk_size_gb <= 30
    error_message = "Data disk must be between 10 and 30 GB for the low-cost Miniflux deployment."
  }
}

variable "data_disk_type" {
  description = "Disk type for the persistent Docker data disk."
  type        = string
  default     = "pd-standard"

  validation {
    condition     = var.data_disk_type == "pd-standard"
    error_message = "Use pd-standard for the data disk to keep costs low."
  }
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

  validation {
    condition     = !var.create_static_ipv4 || var.assign_public_ip
    error_message = "create_static_ipv4 requires assign_public_ip=true."
  }
}

variable "public_ingress_cidrs" {
  description = "Allowed source CIDRs for SSH ingress when assign_public_ip is enabled."
  type        = list(string)
  default     = []

  validation {
    condition     = var.assign_public_ip || length(var.public_ingress_cidrs) == 0
    error_message = "public_ingress_cidrs must be empty unless assign_public_ip=true."
  }
}
