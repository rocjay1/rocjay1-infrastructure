data "terraform_remote_state" "miniflux" {
  backend = "gcs"
  config = {
    bucket = "daily-tech-brief-tfstate"
    prefix = "miniflux"
  }
}

# Cloudflare Worker (Identity)
resource "cloudflare_worker" "feed_aggregator" {
  account_id = var.account_id
  name       = "feed-aggregator"

  lifecycle {
    ignore_changes = [
      observability,
      subdomain,
    ]
  }
}

# Custom Domain for the Worker
resource "cloudflare_workers_custom_domain" "feed_aggregator_domain" {
  account_id = var.account_id
  zone_id    = var.zone_id
  hostname   = "${var.subdomain}.${var.zone_name}"
  service    = cloudflare_worker.feed_aggregator.name

  lifecycle {
    ignore_changes = [
      environment,
    ]
  }
}

# KV Namespace for feed sources
resource "cloudflare_workers_kv_namespace" "sources_kv" {
  account_id = var.account_id
  title      = "${var.project_name}-sources"
}
