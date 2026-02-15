# variable "project_name" {
#   type        = string
#   default     = "rmanalyzer"
#   description = "Base name for the project resources"
# }

# variable "location" {
#   type        = string
#   default     = "eastus"
#   description = "Azure region for resources"
# }

# variable "swa_location" {
#   type        = string
#   default     = "eastus2"
#   description = "Region for Static Web App (must be a supported region)"
# }

# variable "data_location" {
#   type        = string
#   default     = "United States"
#   description = "Data location for Communication Services"
# }

variable "subscription_id" {
  type        = string
  description = "Target Azure Subscription ID"
}

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

# variable "github_repo" {
#   type        = string
#   default     = "rocjay1/rm-analyzer"
#   description = "The GitHub repository in 'owner/repo' format for OIDC trust."
# }

# New variables for Entra ID integration
# These are used in cloudflare_identity.tf

variable "cloudflare_team_domain" {
  description = "Cloudflare Access team domain (for example, your-team-name)"
  type        = string
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

variable "balance_tracker_hostname" {
  description = "Public hostname for the Balance Tracker app"
  type        = string
  default     = "balance-tracker"
}

variable "balance_tracker_tunnel_name" {
  description = "Friendly name for the Balance Tracker Cloudflare tunnel"
  type        = string
  default     = "balance-tracker-tunnel"
}
