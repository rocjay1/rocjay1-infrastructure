# -----------------------------------------------------------------------------
# NETWORKING
# -----------------------------------------------------------------------------
resource "google_compute_address" "miniflux_ipv4" {
  count        = var.assign_public_ip && var.create_static_ipv4 ? 1 : 0
  name         = "miniflux-ipv4"
  address_type = "EXTERNAL"
  region       = var.region

  depends_on = [google_project_service.compute]
}

# -----------------------------------------------------------------------------
# FIREWALL RULES
# -----------------------------------------------------------------------------
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

resource "google_compute_firewall" "miniflux_deny_rdp" {
  name      = "miniflux-deny-rdp"
  network   = "default"
  direction = "INGRESS"
  priority  = 800

  target_tags   = ["miniflux"]
  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "tcp"
    ports    = ["3389"]
  }

  deny {
    protocol = "udp"
    ports    = ["3389"]
  }

  depends_on = [google_project_service.compute]
}

resource "google_compute_firewall" "miniflux_egress" {
  name      = "miniflux-egress"
  network   = "default"
  direction = "EGRESS"
  priority  = 1000

  target_tags        = ["miniflux"]
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  depends_on = [google_project_service.compute]
}
