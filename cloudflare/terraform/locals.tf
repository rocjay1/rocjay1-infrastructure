locals {
  account_id   = "a7107b56168148c0c72a7040d5f98c76"
  account_name = "rocjay1"
  zone_id      = "f5ddaca671ac53ee0442c5ea08772dcf"
  zone_name    = "roccosmodernsite.net"

  dmarc_report_emails = [
    "postmaster@roccosmodernsite.net",
    "222f1d4731c5492a85d53be8fc66e283@dmarc-reports.cloudflare.net"
  ]
}
