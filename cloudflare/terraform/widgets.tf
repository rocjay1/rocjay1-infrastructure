resource "cloudflare_turnstile_widget" "main" {
  account_id = local.account_id
  name       = "Managed Turnstile Widget"
  domains    = [local.zone_name, "rss.${local.zone_name}"]
  mode       = "managed"
  region     = "world"
}
