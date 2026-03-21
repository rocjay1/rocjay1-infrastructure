terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0"
    }
  }
}

resource "random_bytes" "tunnel_secret" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id    = var.account_id
  name          = var.tunnel_name
  tunnel_secret = random_bytes.tunnel_secret.base64
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "tunnel" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_cfg" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id

  config = {
    warp_routing = {
      enabled = var.warp_routing_enabled
    }
    ingress = var.ingress_rules
  }
}

resource "cloudflare_dns_record" "dns" {
  zone_id = var.zone_id
  name    = var.cname_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
