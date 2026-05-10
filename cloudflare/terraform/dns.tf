# -----------------------------------------------------------------------------
# MAIL RECORDS (iCloud+ Custom Domain)
# -----------------------------------------------------------------------------

resource "cloudflare_dns_record" "icloud_mx_1" {
  zone_id  = var.zone_id
  name     = "@"
  content  = "mx01.mail.icloud.com"
  type     = "MX"
  priority = 10
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "icloud_mx_2" {
  zone_id  = var.zone_id
  name     = "@"
  content  = "mx02.mail.icloud.com"
  type     = "MX"
  priority = 10
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "icloud_spf" {
  zone_id = var.zone_id
  name    = "@"
  content = "\"v=spf1 include:icloud.com ~all\""
  type    = "TXT"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "icloud_verification" {
  zone_id = var.zone_id
  name    = "@"
  content = "\"apple-domain=${var.apple_domain_verification}\""
  type    = "TXT"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "icloud_dkim" {
  zone_id = var.zone_id
  name    = "sig1._domainkey"
  content = "sig1.dkim.roccosmodernsite.net.at.icloudmailadmin.com."
  type    = "CNAME"
  ttl     = 1
  proxied = false
}

# -----------------------------------------------------------------------------
# EMAIL SECURITY (DMARC Management)
# -----------------------------------------------------------------------------

resource "cloudflare_dns_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc"
  content = "\"v=DMARC1; p=reject; rua=${join(",", [for e in var.cloudflare_dmarc_report_emails : "mailto:${e}"])}\""
  type    = "TXT"
  ttl     = 1
  proxied = false
}
