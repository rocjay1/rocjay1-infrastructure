# -----------------------------------------------------------------------------
# GITHUB PAGES
# -----------------------------------------------------------------------------

resource "cloudflare_dns_record" "github_docs" {
  zone_id = local.zone_id
  name    = "docs"
  content = "rocjay1.github.io"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "github_pages_verification" {
  zone_id = local.zone_id
  name    = "_github-pages-challenge-rocjay1"
  content = "\"eb414c49fdf720d52988db6b298a36\""
  type    = "TXT"
  ttl     = 1
  proxied = false
}
