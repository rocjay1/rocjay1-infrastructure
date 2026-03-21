output "entra_client_id" {
  description = "Client ID of the Microsoft Entra application registration used for Cloudflare."
  value       = data.terraform_remote_state.cloudflare_shared.outputs.entra_client_id
}

output "entra_client_secret" {
  description = "Client secret generated for the Cloudflare application registration."
  value       = data.terraform_remote_state.cloudflare_shared.outputs.entra_client_secret
  sensitive   = true
}

output "entra_tenant_id" {
  description = "Tenant ID associated with the current Azure AD credentials."
  value       = data.terraform_remote_state.cloudflare_shared.outputs.entra_tenant_id
}

output "cloudflare_access_redirect_uri" {
  description = "Redirect URI that must be configured in Cloudflare Zero Trust."
  value       = data.terraform_remote_state.cloudflare_shared.outputs.cloudflare_redirect_uri
}

output "balance_tracker_tunnel_token" {
  value     = module.cloudflare_tunnel.tunnel_token
  sensitive = true
}
