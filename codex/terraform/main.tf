locals {
  miniflux_required_project_roles = [
    "roles/compute.instanceAdmin.v1",
    "roles/compute.networkAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.objectAdmin",
  ]
}

module "miniflux_codex_service_account" {
  source = "../../terraform/modules/codex_gcp_service_account"

  project_id                                  = var.project_id
  manage_required_project_services            = var.manage_required_project_services
  service_account_id                          = var.service_account_id
  service_account_display_name                = var.service_account_display_name
  required_project_roles                      = local.miniflux_required_project_roles
  additional_project_roles                    = var.additional_service_account_project_roles
  service_account_key_secret_id               = var.service_account_key_secret_id
  service_account_key_secret_accessor_members = var.service_account_key_secret_accessor_members
}
