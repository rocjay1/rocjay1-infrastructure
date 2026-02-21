output "account_id" {
  value = var.account_id
}

output "zone_id" {
  value = var.zone_id
}

output "zone_name" {
  value = var.zone_name
}

output "cloudflare_team_domain" {
  value = var.cloudflare_team_domain
}

output "entra_identity_provider_id" {
  value = cloudflare_zero_trust_access_identity_provider.entra.id
}

output "entra_group_id" {
  value = azuread_group.cloudflare_access_users.object_id
}

output "entra_client_id" {
  value = azuread_application.cloudflare_access.client_id
}

output "entra_client_secret" {
  value     = azuread_application_password.cloudflare_access.value
  sensitive = true
}

output "entra_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "cloudflare_redirect_uri" {
  value = local.cloudflare_redirect_uri
}
