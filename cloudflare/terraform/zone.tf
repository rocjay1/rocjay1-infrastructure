# -----------------------------------------------------------------------------
# ZONE & DNSSEC
# -----------------------------------------------------------------------------
data "cloudflare_zone" "main" {
  zone_id = local.zone_id
}

resource "cloudflare_zone_dnssec" "main_zone_dnssec" {
  zone_id = data.cloudflare_zone.main.zone_id

  lifecycle {
    ignore_changes = [status]
  }
}

# -----------------------------------------------------------------------------
# ZONE SETTINGS
# -----------------------------------------------------------------------------
resource "cloudflare_zone_setting" "always_use_https" {
  zone_id    = local.zone_id
  setting_id = "always_use_https"
  value      = "on"
}

resource "cloudflare_zone_setting" "automatic_https_rewrites" {
  zone_id    = local.zone_id
  setting_id = "automatic_https_rewrites"
  value      = "on"
}

resource "cloudflare_zone_setting" "ssl_strict" {
  zone_id    = local.zone_id
  setting_id = "ssl"
  value      = "strict"
}

resource "cloudflare_zone_setting" "hsts" {
  zone_id    = local.zone_id
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
