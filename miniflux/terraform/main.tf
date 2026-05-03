module "cloudflare_tunnel" {
  source = "../../terraform/modules/cloudflare_tunnel_app"

  account_id     = var.account_id
  zone_id        = var.zone_id
  tunnel_name    = var.miniflux_tunnel_name
  cname_hostname = var.miniflux_hostname

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
