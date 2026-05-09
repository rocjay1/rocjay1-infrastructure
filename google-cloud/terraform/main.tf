# Workload Identity Federation for GitHub Actions
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Pool for GitHub Actions identity federation"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "GitHub OIDC provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository_owner == 'rocjay1'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Service Account for Drift Detection
resource "google_service_account" "drift_detector" {
  account_id   = "terraform-drift-detector"
  display_name = "Terraform Drift Detector"
  description  = "Used for automated Terraform drift detection across the ecosystem."
}

# Allow specified repositories to impersonate the service account
resource "google_service_account_iam_member" "wif_impersonation" {
  for_each           = toset(var.github_allowed_repos)
  service_account_id = google_service_account.drift_detector.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${each.value}"
}

# Grant permissions to the GCS bucket (Bucket and SA are in abiding-cycle-464914-p6)
resource "google_storage_bucket_iam_member" "drift_detector_storage_admin" {
  bucket = var.tfstate_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.drift_detector.email}"
}

# Grant permissions across all managed GCP projects
resource "google_project_iam_member" "drift_detector_viewer" {
  for_each = toset(var.managed_gcp_projects)
  project  = each.value
  role     = "roles/viewer"
  member   = "serviceAccount:${google_service_account.drift_detector.email}"
}

resource "google_project_iam_member" "drift_detector_security_reviewer" {
  for_each = toset(var.managed_gcp_projects)
  project  = each.value
  role     = "roles/iam.securityReviewer"
  member   = "serviceAccount:${google_service_account.drift_detector.email}"
}

resource "google_project_iam_member" "drift_detector_service_usage" {
  for_each = toset(var.managed_gcp_projects)
  project  = each.value
  role     = "roles/serviceusage.serviceUsageConsumer"
  member   = "serviceAccount:${google_service_account.drift_detector.email}"
}

# Management Project Specific Permissions
resource "google_project_iam_member" "drift_detector_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.drift_detector.email}"
}

resource "google_project_iam_member" "drift_detector_wif_viewer" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityPoolViewer"
  member  = "serviceAccount:${google_service_account.drift_detector.email}"
}
