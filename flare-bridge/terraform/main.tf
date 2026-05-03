# Cloudflare Worker (Identity)
resource "cloudflare_worker" "flare_bridge" {
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
resource "cloudflare_workers_custom_domain" "flare_bridge_domain" {
  account_id = var.account_id
  zone_id    = var.zone_id
  hostname   = "${var.subdomain}.${var.zone_name}"
  service    = cloudflare_worker.flare_bridge.name

  lifecycle {
    ignore_changes = [
      environment,
    ]
  }
}

# D1 Database for FlareBridge
resource "cloudflare_d1_database" "main" {
  account_id = var.account_id
  name       = "flare-bridge-db"
}
