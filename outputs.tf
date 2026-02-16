output "entra_client_id" {
  description = "Client ID of the Microsoft Entra application registration used for Cloudflare."
  value       = azuread_application.cloudflare_access.client_id
}

output "entra_client_secret" {
  description = "Client secret generated for the Cloudflare application registration."
  value       = azuread_application_password.cloudflare_access.value
  sensitive   = true
}

output "entra_tenant_id" {
  description = "Tenant ID associated with the current Azure AD credentials."
  value       = data.azuread_client_config.current.tenant_id
}

output "cloudflare_access_redirect_uri" {
  description = "Redirect URI that must be configured in Cloudflare Zero Trust."
  value       = local.cloudflare_redirect_uri
}

output "balance_tracker_tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.balance_tracker_tunnel.token
  sensitive = true
}
