output "worker_url" {
  value       = "https://${var.subdomain}.${var.zone_name}"
  description = "The URL of the deployed worker."
}

output "d1_database_id" {
  value       = cloudflare_d1_database.main.id
  description = "The ID of the D1 database."
}
