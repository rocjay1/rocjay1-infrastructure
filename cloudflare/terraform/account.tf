resource "cloudflare_account" "main" {
  name = local.account_name

  settings = {
    enforce_twofactor = true
  }
}
