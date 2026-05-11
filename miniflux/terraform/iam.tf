# -----------------------------------------------------------------------------
# SERVICE ACCOUNT & IAM
# -----------------------------------------------------------------------------
resource "google_service_account" "miniflux_runtime" {
  account_id   = "miniflux-runtime"
  display_name = "Miniflux runtime service account"
}

resource "google_project_iam_member" "miniflux_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = google_service_account.miniflux_runtime.member
}

resource "google_project_iam_member" "miniflux_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = google_service_account.miniflux_runtime.member
}

resource "google_project_iam_member" "miniflux_metadata" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = google_service_account.miniflux_runtime.member
}
