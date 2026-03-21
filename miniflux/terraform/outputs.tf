output "miniflux_tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.miniflux_tunnel.token
  sensitive = true
}
