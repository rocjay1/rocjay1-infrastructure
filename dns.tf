data "cloudflare_account" "main" {
  account_id = var.account_id
}

data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

resource "cloudflare_zone_dnssec" "main_zone_dnssec" {
  zone_id             = data.cloudflare_zone.main.zone_id
  dnssec_multi_signer = false
  dnssec_presigned    = false
  dnssec_use_nsec3    = false
  status              = "active"

  lifecycle {
    ignore_changes = all
  }
}

resource "cloudflare_ruleset" "geoblock" {
  zone_id     = var.zone_id
  name        = "Geo Block"
  description = "Block non-US traffic"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [{
    action      = "block"
    expression  = "(ip.src.country ne \"US\")"
    description = "Block non-US traffic"
    enabled     = true
  }]
}


# balance-tracker
resource "cloudflare_dns_record" "balance_tracker_dns" {
  zone_id = var.zone_id
  name    = var.balance_tracker_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.balance_tracker_tunnel.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
