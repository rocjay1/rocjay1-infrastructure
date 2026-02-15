resource "random_bytes" "balance_tracker_tunnel_secret" {
  length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "balance_tracker_tunnel" {
  account_id    = var.account_id
  name          = var.balance_tracker_tunnel_name
  tunnel_secret = random_bytes.balance_tracker_tunnel_secret.base64
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "balance_tracker_tunnel" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.balance_tracker_tunnel.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "balance_tracker_tunnel_cfg" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.balance_tracker_tunnel.id

  config = {
    ingress = [
      {
        hostname = "${var.balance_tracker_hostname}.${var.zone_name}"
        path     = "api"
        service  = "http://backend:8080"
        origin_request = {
          connect_timeout          = 10
          disable_chunked_encoding = true
          http2_origin             = false
          keep_alive_connections   = 200
          keep_alive_timeout       = 300
          no_tls_verify            = true
          tcp_keep_alive           = 30
          tls_timeout              = 10
        }
      },
      {
        hostname = "${var.balance_tracker_hostname}.${var.zone_name}"
        service  = "http://frontend:80"
        origin_request = {
          connect_timeout          = 10
          disable_chunked_encoding = true
          http2_origin             = false
          keep_alive_connections   = 200
          keep_alive_timeout       = 300
          no_tls_verify            = true
          tcp_keep_alive           = 30
          tls_timeout              = 10
        }
      },
      {
        service = "http_status:404"
      }
    ]
    warp_routing = {
      enabled = false
    }
  }
}


# Access Application
resource "cloudflare_zero_trust_access_application" "balance_tracker_app" {
  account_id = var.account_id
  name       = "Balance Tracker"
  type       = "self_hosted"
  domain     = "${var.balance_tracker_hostname}.${var.zone_name}"

  session_duration = "24h"

  # Ensure only authenticated users can access
  policies = [{
    id         = cloudflare_zero_trust_access_policy.allow_entra_group.id
    precedence = 1
  }]
}

resource "cloudflare_zero_trust_access_identity_provider" "entra" {
  account_id = var.account_id
  name       = "Entra ID"
  type       = "azureAD"

  config = {
    client_id      = azuread_application.cloudflare_access.client_id
    client_secret  = azuread_application_password.cloudflare_access.value
    directory_id   = data.azuread_client_config.current.tenant_id
    support_groups = true # enable group lookups
    pkce_enabled   = true
  }
}

resource "cloudflare_zero_trust_access_policy" "allow_entra_group" {
  account_id = var.account_id
  name       = "Allow Entra Group"
  decision   = "allow"

  include = [
    {
      azure_ad = {
        identity_provider_id = cloudflare_zero_trust_access_identity_provider.entra.id
        id                   = azuread_group.cloudflare_access_users.id
      }
    }
  ]
}
