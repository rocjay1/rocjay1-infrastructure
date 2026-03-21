data "terraform_remote_state" "cloudflare_shared" {
  backend = "gcs"
  config = {
    bucket = "daily-tech-brief-tfstate"
    prefix = "cloudflare"
  }
}
