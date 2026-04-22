resource "google_service_account" "miniflux_runtime" {
  account_id   = "miniflux-runtime"
  display_name = "Miniflux runtime service account"
}

resource "google_compute_disk" "docker_data" {
  name = "miniflux-docker-data"
  type = var.data_disk_type
  size = var.data_disk_size_gb
  zone = var.zone
}

resource "google_compute_address" "miniflux_ipv4" {
  count        = var.assign_public_ip && var.create_static_ipv4 ? 1 : 0
  name         = "miniflux-ipv4"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "google_compute_instance" "miniflux" {
  name         = "miniflux"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["miniflux"]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  attached_disk {
    source      = google_compute_disk.docker_data.id
    device_name = "docker-data"
  }

  network_interface {
    network = "default"

    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        nat_ip = var.create_static_ipv4 ? google_compute_address.miniflux_ipv4[0].address : null
      }
    }
  }

  service_account {
    email = google_service_account.miniflux_runtime.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}

resource "google_compute_firewall" "miniflux_egress" {
  name      = "miniflux-egress"
  network   = "default"
  direction = "EGRESS"

  target_tags = ["miniflux"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "miniflux_ingress" {
  count     = var.assign_public_ip ? 1 : 0
  name      = "miniflux-ingress"
  network   = "default"
  direction = "INGRESS"

  target_tags   = ["miniflux"]
  source_ranges = var.public_ingress_cidrs

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
