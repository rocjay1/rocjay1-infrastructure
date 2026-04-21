output "codex_service_account_email" {
  description = "Email address of the Codex environment service account."
  value       = module.miniflux_codex_service_account.service_account_email
}

output "codex_service_account_name" {
  description = "Fully qualified resource name of the Codex environment service account."
  value       = module.miniflux_codex_service_account.service_account_name
}

output "codex_service_account_key_secret_id" {
  description = "Secret Manager secret ID containing the Codex service account JSON key."
  value       = module.miniflux_codex_service_account.service_account_key_secret_id
}

output "codex_service_account_key_secret_name" {
  description = "Fully qualified Secret Manager secret name containing the Codex service account JSON key."
  value       = module.miniflux_codex_service_account.service_account_key_secret_name
}
