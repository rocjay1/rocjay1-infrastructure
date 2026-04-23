locals {
  miniflux_labels = {
    app         = "miniflux"
    environment = "production"
    managed_by  = "terraform"
  }
}

resource "google_project_service" "compute" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "miniflux_runtime" {
  account_id   = "miniflux-runtime"
  display_name = "Miniflux runtime service account"
}

resource "google_compute_disk" "docker_data" {
  name   = "miniflux-docker-data"
  type   = var.data_disk_type
  size   = var.data_disk_size_gb
  zone   = var.zone
  labels = local.miniflux_labels

  depends_on = [google_project_service.compute]
}

resource "google_compute_address" "miniflux_ipv4" {
  count        = var.assign_public_ip && var.create_static_ipv4 ? 1 : 0
  name         = "miniflux-ipv4"
  address_type = "EXTERNAL"
  region       = var.region

  depends_on = [google_project_service.compute]
}

resource "google_compute_instance" "miniflux" {
  name         = "miniflux"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["miniflux"]
  labels       = local.miniflux_labels

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

  lifecycle {
    precondition {
      condition     = !var.create_static_ipv4 || var.assign_public_ip
      error_message = "create_static_ipv4 requires assign_public_ip=true."
    }

    precondition {
      condition     = var.assign_public_ip || length(var.public_ingress_cidrs) == 0
      error_message = "public_ingress_cidrs must be empty unless assign_public_ip=true."
    }
  }

  depends_on = [google_project_service.compute]
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

  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "miniflux_iap_ssh" {
  name      = "miniflux-iap-ssh"
  network   = "default"
  direction = "INGRESS"
  priority  = 1000

  target_tags   = ["miniflux"]
  source_ranges = ["35.235.240.0/20"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "miniflux_deny_public_ssh" {
  name      = "miniflux-deny-public-ssh"
  network   = "default"
  direction = "INGRESS"
  priority  = 1001

  target_tags   = ["miniflux"]
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "miniflux_ingress" {
  count     = var.assign_public_ip && length(var.public_ingress_cidrs) > 0 ? 1 : 0
  name      = "miniflux-ingress"
  network   = "default"
  direction = "INGRESS"
  priority  = 900

  target_tags   = ["miniflux"]
  source_ranges = var.public_ingress_cidrs

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  depends_on = [google_project_service.compute]
}
