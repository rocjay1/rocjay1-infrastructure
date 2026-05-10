# -----------------------------------------------------------------------------
# LOCALS
# -----------------------------------------------------------------------------
locals {
  miniflux_labels = {
    app         = "miniflux"
    environment = "production"
    managed_by  = "terraform"
  }
}

# -----------------------------------------------------------------------------
# STORAGE
# -----------------------------------------------------------------------------
resource "google_compute_disk" "docker_data" {
  name   = "miniflux-docker-data"
  type   = var.data_disk_type
  size   = var.data_disk_size_gb
  zone   = var.zone
  labels = local.miniflux_labels

  depends_on = [google_project_service.compute]
}

# -----------------------------------------------------------------------------
# COMPUTE INSTANCE
# -----------------------------------------------------------------------------
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
