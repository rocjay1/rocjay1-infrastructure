# R2 Bucket for storage
resource "cloudflare_r2_bucket" "feed_storage" {
  account_id = var.account_id
  name       = "feed-storage"
}

# Cloudflare Worker (Identity)
resource "cloudflare_worker" "feed_aggregator" {
  account_id = var.account_id
  name       = "feed-aggregator"
}

# Cloudflare Worker Version (Code & Bindings)
resource "cloudflare_worker_version" "feed_aggregator_v1" {
  account_id = var.account_id
  worker_id  = cloudflare_worker.feed_aggregator.id

  main_module = "worker.js"
  modules = [{
    name         = "worker.js"
    content_file = "${path.module}/worker.js"
    content_type = "application/javascript+module"
  }]

  compatibility_date = "2024-01-01"

  bindings = [{
    name        = "FEED_STORAGE"
    type        = "r2_bucket"
    bucket_name = cloudflare_r2_bucket.feed_storage.name
  }]
}

# Deploy the Worker Version
resource "cloudflare_workers_deployment" "feed_aggregator_deployment" {
  account_id  = var.account_id
  script_name = cloudflare_worker.feed_aggregator.name
  strategy    = "percentage"
  versions = [{
    version_id = cloudflare_worker_version.feed_aggregator_v1.id
    percentage = 100
  }]
}

# Custom Domain for the Worker
resource "cloudflare_workers_custom_domain" "feed_aggregator_domain" {
  account_id = var.account_id
  zone_id    = var.zone_id
  hostname   = "${var.subdomain}.${var.zone_name}"
  service    = cloudflare_worker.feed_aggregator.name

  # Ensure the worker is deployed before attaching the domain
  depends_on = [cloudflare_workers_deployment.feed_aggregator_deployment]
}

# Hourly Cron Trigger
resource "cloudflare_workers_cron_trigger" "feed_aggregator_cron" {
  account_id  = var.account_id
  script_name = cloudflare_worker.feed_aggregator.name

  schedules = [{
    cron = "0 * * * *"
  }]

  # Ensure the worker is deployed before creating the trigger
  depends_on = [cloudflare_workers_deployment.feed_aggregator_deployment]
}
