# -----------------------------------------------------------------------------
# STORAGE BUCKETS
# -----------------------------------------------------------------------------

resource "google_storage_bucket" "daily_tech_brief_tfstate" {
  name                     = "daily-tech-brief-tfstate"
  location                 = "US-CENTRAL1"
  force_destroy            = false
  public_access_prevention = "enforced"

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# -----------------------------------------------------------------------------
# SECRET MANAGER
# -----------------------------------------------------------------------------   

resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = "gemini-api-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "gmail_app_password" {
  secret_id = "gmail-app-password"
  replication {
    auto {}
  }
}
