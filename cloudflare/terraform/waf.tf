resource "cloudflare_ruleset" "main" {
  zone_id     = local.zone_id
  name        = "Default Challenge Policy"
  description = "Allow authorized infrastructure and challenge everything else"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      action      = "skip"
      description = "Allow: Miniflux VM"
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
      description = "Allow: Google Cloud Uptime Checks"
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
      description = "Challenge: All other traffic"
      enabled     = true
      expression  = "true"
    }
  ]

  lifecycle {
    ignore_changes = [rules]
  }
}
