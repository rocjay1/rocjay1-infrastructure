resource "random_bytes" "miniflux_tunnel_secret" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "miniflux_tunnel" {
  account_id    = var.account_id
  name          = var.miniflux_tunnel_name
  tunnel_secret = random_bytes.miniflux_tunnel_secret.base64
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "miniflux_tunnel" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.miniflux_tunnel.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "miniflux_tunnel_cfg" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.miniflux_tunnel.id

  config = {
    ingress = [
      {
        hostname = "${var.miniflux_hostname}.${var.zone_name}"
        service  = "http://miniflux:8080"
        origin_request = {
          connect_timeout          = 10
          disable_chunked_encoding = true
          http2_origin             = false
          keep_alive_connections   = 200
          keep_alive_timeout       = 300
          no_tls_verify            = true
          tcp_keep_alive           = 30
          tls_timeout              = 10
        }
      },
      {
        service = "http_status:404"
      }
    ]
    warp_routing = {
      enabled = false
    }
  }
}

resource "cloudflare_dns_record" "miniflux_dns" {
  zone_id = var.zone_id
  name    = var.miniflux_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.miniflux_tunnel.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
