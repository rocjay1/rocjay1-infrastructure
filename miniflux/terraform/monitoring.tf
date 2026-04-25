resource "google_project_service" "monitoring" {
  project            = var.project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "logging" {
  project            = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

resource "google_monitoring_notification_channel" "email" {
  count        = var.alert_email != "" ? 1 : 0
  display_name = "Miniflux Alert Email"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }

  depends_on = [google_project_service.monitoring]
}

resource "google_monitoring_uptime_check_config" "miniflux_https" {
  display_name = "Miniflux HTTPS Uptime Check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/healthcheck"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = "${var.miniflux_hostname}.${var.zone_name}"
    }
  }

  depends_on = [google_project_service.monitoring]
}

resource "google_monitoring_alert_policy" "miniflux_uptime_alert" {
  display_name = "Miniflux Uptime Alert"
  combiner     = "OR"
  conditions {
    display_name = "Miniflux is unreachable"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id=\"${google_monitoring_uptime_check_config.miniflux_https.uptime_check_id}\" AND resource.type=\"uptime_url\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1
      trigger {
        count = 1
      }
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
      }
    }
  }

  notification_channels = var.alert_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  depends_on = [google_project_service.monitoring]
}

resource "google_monitoring_alert_policy" "miniflux_container_errors" {
  display_name = "Miniflux Container Errors"
  combiner     = "OR"
  conditions {
    display_name = "Miniflux or DB Container Error Logs"
    condition_matched_log {
      filter = "resource.type=\"gce_instance\" AND resource.labels.instance_id=\"${google_compute_instance.miniflux.instance_id}\" AND logName=~\"projects/${var.project_id}/logs/gcplogs.*\" AND severity>=ERROR"
    }
  }

  notification_channels = var.alert_email != "" ? [google_monitoring_notification_channel.email[0].name] : []

  alert_strategy {
    notification_rate_limit {
      period = "3600s" # 1 hour
    }
  }

  depends_on = [google_project_service.monitoring, google_project_service.logging]
}

resource "google_monitoring_dashboard" "miniflux_dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "Miniflux Overview",
  "mosaicLayout": {
    "columns": 12,
    "tiles": [
      {
        "widget": {
          "title": "VM CPU Utilization",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\" resource.label.\"instance_id\"=\"${google_compute_instance.miniflux.instance_id}\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ]
          }
        },
        "width": 6,
        "height": 4,
        "xPos": 0,
        "yPos": 0
      },
      {
        "widget": {
          "title": "VM Memory Utilization",
          "xyChart": {
            "dataSets": [
              {
                "timeSeriesQuery": {
                  "timeSeriesFilter": {
                    "filter": "metric.type=\"agent.googleapis.com/memory/percent_used\" resource.type=\"gce_instance\" resource.label.\"instance_id\"=\"${google_compute_instance.miniflux.instance_id}\" metric.label.\"state\"=\"used\"",
                    "aggregation": {
                      "alignmentPeriod": "60s",
                      "perSeriesAligner": "ALIGN_MEAN"
                    }
                  }
                }
              }
            ]
          }
        },
        "width": 6,
        "height": 4,
        "xPos": 6,
        "yPos": 0
      },
      {
        "widget": {
          "title": "Container Logs (Errors/Warnings)",
          "logsPanel": {
            "filter": "resource.type=\"gce_instance\" AND resource.labels.instance_id=\"${google_compute_instance.miniflux.instance_id}\" AND logName=~\"projects/${var.project_id}/logs/gcplogs.*\" AND severity>=WARNING"
          }
        },
        "width": 12,
        "height": 4,
        "xPos": 0,
        "yPos": 4
      }
    ]
  }
}
EOF

  depends_on = [google_project_service.monitoring]
}
