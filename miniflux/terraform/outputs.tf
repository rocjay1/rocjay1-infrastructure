output "miniflux_tunnel_token" {
  value     = module.cloudflare_tunnel.tunnel_token
  sensitive = true
}

output "miniflux_instance_name" {
  value       = google_compute_instance.miniflux.name
  description = "Name of the Miniflux GCE instance."
}

output "miniflux_instance_zone" {
  value       = google_compute_instance.miniflux.zone
  description = "Zone of the Miniflux GCE instance."
}

output "miniflux_instance_self_link" {
  value       = google_compute_instance.miniflux.self_link
  description = "Self link of the Miniflux GCE instance."
}

output "miniflux_internal_ip" {
  value       = google_compute_instance.miniflux.network_interface[0].network_ip
  description = "Internal IP of the Miniflux VM."
}

output "miniflux_external_ip" {
  value       = try(google_compute_instance.miniflux.network_interface[0].access_config[0].nat_ip, null)
  description = "Ephemeral external IP of the Miniflux VM when assign_public_ip=true."
}
