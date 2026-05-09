output "workload_identity_provider_id" {
  description = "The full name of the Workload Identity Provider to use in GitHub Actions."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
  description = "The email of the service account for GitHub Actions to impersonate."
  value       = google_service_account.drift_detector.email
}

output "github_actions_config" {
  description = "Helper output for configuring the google-github-actions/auth action."
  value = {
    workload_identity_provider = google_iam_workload_identity_pool_provider.github.name
    service_account            = google_service_account.drift_detector.email
  }
}
