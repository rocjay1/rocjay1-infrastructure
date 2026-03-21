module "cloudflare_tunnel" {
  source = "../../terraform/modules/cloudflare_tunnel_app"

  account_id           = var.account_id
  zone_id              = var.zone_id
  tunnel_name          = var.miniflux_tunnel_name
  cname_hostname       = var.miniflux_hostname

  ingress_rules = [
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
}

moved {
  from = random_bytes.miniflux_tunnel_secret
  to   = module.cloudflare_tunnel.random_bytes.tunnel_secret
}

moved {
  from = cloudflare_zero_trust_tunnel_cloudflared.miniflux_tunnel
  to   = module.cloudflare_tunnel.cloudflare_zero_trust_tunnel_cloudflared.tunnel
}

moved {
  from = cloudflare_zero_trust_tunnel_cloudflared_config.miniflux_tunnel_cfg
  to   = module.cloudflare_tunnel.cloudflare_zero_trust_tunnel_cloudflared_config.tunnel_cfg
}

moved {
  from = cloudflare_dns_record.miniflux_dns
  to   = module.cloudflare_tunnel.cloudflare_dns_record.dns
}
