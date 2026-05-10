# -----------------------------------------------------------------------------
# ACCOUNT
# -----------------------------------------------------------------------------
resource "cloudflare_account" "main" {
  name = var.account_name

  settings = {
    enforce_twofactor = true
  }
}

# -----------------------------------------------------------------------------
# ZONE & DNSSEC
# -----------------------------------------------------------------------------
data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

resource "cloudflare_zone_dnssec" "main_zone_dnssec" {
  zone_id = data.cloudflare_zone.main.zone_id
  status  = "active"
}

# -----------------------------------------------------------------------------
# ZONE SETTINGS
# -----------------------------------------------------------------------------
resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = var.zone_id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_zone_setting" "automatic_https_rewrites" {
  zone_id    = var.zone_id
  setting_id = "automatic_https_rewrites"
  value      = "on"
}

resource "cloudflare_zone_setting" "ssl_strict" {
  zone_id    = var.zone_id
  setting_id = "ssl"
  value      = "strict"
}

resource "cloudflare_zone_setting" "hsts" {
  zone_id    = var.zone_id
  setting_id = "security_header"

  value = jsonencode({
    strict_transport_security = {
      enabled            = true
      max_age            = 31536000
      include_subdomains = true
      preload            = true
      nosniff            = true
    }
  })
}

# -----------------------------------------------------------------------------
# TURNSTILE
# -----------------------------------------------------------------------------
resource "cloudflare_turnstile_widget" "main" {
  account_id = var.account_id
  name       = "Managed Turnstile Widget"
  domains    = [var.zone_name, "rss.${var.zone_name}"]
  mode       = "managed"
  region     = "world"
}

# -----------------------------------------------------------------------------
# WAF / FIREWALL
# -----------------------------------------------------------------------------
resource "cloudflare_ruleset" "main" {
  zone_id     = var.zone_id
  name        = "Geo Block"
  description = "Block non-US traffic and restrict feed aggregator"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action      = "skip"
      description = "Bypass WAF for Miniflux VM"
      enabled     = true
      expression  = "(ip.src eq 8.231.239.219)"
      logging = {
        enabled = true
      }
      action_parameters = {
        ruleset = "current"
      }
    },
    {
      action      = "skip"
      description = "Allow Google Cloud Uptime Checks with secret"
      enabled     = true
      expression  = "(http.user_agent contains \"GoogleStackdriverMonitoring-UptimeChecks\" and http.request.headers[\"x-gcp-uptime-secret\"][0] eq \"${var.uptime_check_secret}\")"
      logging = {
        enabled = true
      }
      action_parameters = {
        ruleset = "current"
      }
    },
    {
      action      = "managed_challenge"
      expression  = "(ip.src.country ne \"US\")"
      description = "Challenge non-US traffic"
      enabled     = true
    },
    {
      action      = "js_challenge"
      expression  = "(http.host eq \"feeds.${var.zone_name}\")"
      description = "Challenge non-Miniflux traffic to feed aggregator"
      enabled     = true
    }
  ]

  lifecycle {
    ignore_changes = [rules]
  }
}

