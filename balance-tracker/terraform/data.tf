data "terraform_remote_state" "cloudflare_shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "q9pp4eqfiwkpmklctfstate"
    container_name       = "tfstate"
    key                  = "cloudflare-shared.tfstate"
    use_azuread_auth     = true
  }
}
