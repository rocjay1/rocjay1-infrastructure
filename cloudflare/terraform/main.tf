data "cloudflare_account" "main" {
  account_id = var.account_id
}

data "cloudflare_zone" "main" {
  zone_id = var.zone_id
}

resource "cloudflare_zone_dnssec" "main_zone_dnssec" {
  zone_id             = data.cloudflare_zone.main.zone_id
  dnssec_multi_signer = false
  dnssec_presigned    = false
  dnssec_use_nsec3    = false
  status              = "active"

  lifecycle {
    ignore_changes = [
      dnssec_multi_signer,
      dnssec_presigned,
      dnssec_use_nsec3,
      algorithm,
      digest,
      digest_algorithm,
      digest_type,
      ds,
      flags,
      key_tag,
      key_type,
      modified_on,
      public_key,
    ]
  }
}

resource "cloudflare_ruleset" "geoblock" {
  zone_id     = var.zone_id
  name        = "Geo Block"
  description = "Block non-US traffic"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [{
    action      = "block"
    expression  = "(ip.src.country ne \"US\")"
    description = "Block non-US traffic"
    enabled     = true
  }]
}

# Identity Provider Setup (Entra ID)
data "azuread_client_config" "current" {}
data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

locals {
  required_graph_scopes = [
    "email",
    "offline_access",
    "openid",
    "profile",
    "User.Read",
    "Directory.Read.All",
    "GroupMember.Read.All",
  ]

  graph_scope_map = {
    for scope in data.azuread_service_principal.msgraph.oauth2_permission_scopes :
    scope.value => scope.id
  }

  graph_resource_access = [
    for scope_name in local.required_graph_scopes :
    {
      id   = local.graph_scope_map[scope_name]
      type = "Scope"
    }
  ]

  cloudflare_redirect_uri = "https://${var.cloudflare_team_domain}.cloudflareaccess.com/cdn-cgi/access/callback"
}

resource "azuread_application" "cloudflare_access" {
  display_name     = var.entra_application_display_name
  sign_in_audience = "AzureADMyOrg"

  web {
    redirect_uris = [local.cloudflare_redirect_uri]

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = false
    }
  }

  required_resource_access {
    resource_app_id = data.azuread_service_principal.msgraph.client_id

    dynamic "resource_access" {
      for_each = local.graph_resource_access
      content {
        id   = resource_access.value.id
        type = resource_access.value.type
      }
    }
  }

  dynamic "optional_claims" {
    for_each = var.enable_email_optional_claim ? [var.email_claim_name] : []
    content {
      id_token {
        name = optional_claims.value
      }
      access_token {
        name = optional_claims.value
      }
    }
  }
}

resource "azuread_service_principal" "cloudflare_access" {
  client_id = azuread_application.cloudflare_access.client_id
}

resource "time_offset" "cloudflare_access_secret_expiry" {
  offset_days = var.entra_client_secret_validity_days
}

resource "azuread_application_password" "cloudflare_access" {
  application_id = azuread_application.cloudflare_access.id
  display_name   = "Cloudflare Zero Trust client secret"
  end_date       = time_offset.cloudflare_access_secret_expiry.rfc3339
}

resource "azuread_group" "cloudflare_access_users" {
  display_name            = var.entra_cloudflare_group_display_name
  description             = var.entra_cloudflare_group_description
  security_enabled        = true
  mail_enabled            = false
  owners                  = [data.azuread_client_config.current.object_id]
  assignable_to_role      = false
  prevent_duplicate_names = true
}

resource "azuread_group_member" "owner" {
  group_object_id  = azuread_group.cloudflare_access_users.object_id
  member_object_id = data.azuread_client_config.current.object_id
}

resource "cloudflare_zero_trust_access_identity_provider" "entra" {
  account_id = var.account_id
  name       = "Entra ID"
  type       = "azureAD"

  config = {
    client_id      = azuread_application.cloudflare_access.client_id
    client_secret  = azuread_application_password.cloudflare_access.value
    directory_id   = data.azuread_client_config.current.tenant_id
    support_groups = true
    pkce_enabled   = true
  }
}
