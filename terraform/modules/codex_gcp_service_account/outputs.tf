output "service_account_email" {
  description = "Email address of the Codex environment service account."
  value       = google_service_account.codex.email
}

output "service_account_name" {
  description = "Fully qualified resource name of the Codex environment service account."
  value       = google_service_account.codex.name
}

output "service_account_key_secret_id" {
  description = "Secret Manager secret ID containing the Codex service account JSON key."
  value       = google_secret_manager_secret.codex_service_account_key.secret_id
}

output "service_account_key_secret_name" {
  description = "Fully qualified Secret Manager secret name containing the Codex service account JSON key."
  value       = google_secret_manager_secret.codex_service_account_key.name
}
