locals {
  required_project_services = [
    "iam.googleapis.com",
    "secretmanager.googleapis.com",
  ]

  project_roles = toset(concat(
    var.required_project_roles,
    var.additional_project_roles,
  ))

  labels = merge(
    {
      environment = "codex"
      managed_by  = "terraform"
    },
    var.labels,
  )
}

resource "google_project_service" "required" {
  for_each = var.manage_required_project_services ? toset(local.required_project_services) : toset([])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "codex" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.service_account_description

  depends_on = [google_project_service.required]
}

resource "google_project_iam_member" "codex_project_roles" {
  for_each = local.project_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.codex.email}"
}

resource "google_service_account_key" "codex" {
  service_account_id = google_service_account.codex.name
}

resource "google_secret_manager_secret" "codex_service_account_key" {
  project   = var.project_id
  secret_id = var.service_account_key_secret_id
  labels    = local.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "codex_service_account_key" {
  secret      = google_secret_manager_secret.codex_service_account_key.id
  secret_data = base64decode(google_service_account_key.codex.private_key)
}

resource "google_secret_manager_secret_iam_member" "codex_service_account_key_accessors" {
  for_each = toset(var.service_account_key_secret_accessor_members)

  project   = var.project_id
  secret_id = google_secret_manager_secret.codex_service_account_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}
