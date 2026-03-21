output "tunnel_id" {
  value       = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
  description = "The ID of the provisioned tunnel."
}

output "tunnel_token" {
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.tunnel.token
  description = "The tunnel token used by cloudflared."
  sensitive   = true
}
