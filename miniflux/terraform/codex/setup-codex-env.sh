#!/usr/bin/env bash
set -euo pipefail

# Codex Web setup for miniflux/terraform.
# Expected secrets:
#   - GOOGLE_APPLICATION_CREDENTIALS_JSON (required)
#   - CLOUDFLARE_API_TOKEN (optional, required for Cloudflare workspaces)

TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.8.5}"
GOOGLE_CREDS_PATH="${GOOGLE_CREDS_PATH:-/tmp/gcp-terraform-sa.json}"

log() {
  printf '[codex-setup] %s\n' "$*"
}

install_terraform_if_missing() {
  if command -v terraform >/dev/null 2>&1; then
    log "terraform already installed: $(terraform version -json 2>/dev/null | sed -n 's/.*\"terraform_version\":\"\([^\"]*\)\".*/\1/p' || terraform version | head -n1)"
    return
  fi

  log "terraform not found; installing v${TERRAFORM_VERSION}"
  apt-get update -y
  apt-get install -y wget unzip ca-certificates

  local tmp_zip="/tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
  wget -qO "${tmp_zip}" "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
  unzip -qo "${tmp_zip}" -d /usr/local/bin
  chmod +x /usr/local/bin/terraform

  log "terraform installed: $(terraform version | head -n1)"
}

write_google_credentials() {
  if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS_JSON:-}" ]]; then
    log "ERROR: GOOGLE_APPLICATION_CREDENTIALS_JSON is required"
    return 1
  fi

  umask 077
  printf '%s' "${GOOGLE_APPLICATION_CREDENTIALS_JSON}" > "${GOOGLE_CREDS_PATH}"

  export GOOGLE_APPLICATION_CREDENTIALS="${GOOGLE_CREDS_PATH}"
  log "wrote service account credentials to ${GOOGLE_APPLICATION_CREDENTIALS}"
}

export_optional_cloudflare_token() {
  if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]]; then
    export TF_VAR_cloudflare_api_token="${CLOUDFLARE_API_TOKEN}"
    log "exported TF_VAR_cloudflare_api_token from CLOUDFLARE_API_TOKEN"
  else
    log "CLOUDFLARE_API_TOKEN not set; skipping TF_VAR_cloudflare_api_token"
  fi
}

print_next_steps() {
  cat <<'EONEXT'
[codex-setup] Environment ready.
[codex-setup] Next commands (from miniflux/terraform):
  terraform fmt -recursive
  terraform init -input=false
  terraform validate
  terraform plan -input=false
EONEXT
}

main() {
  install_terraform_if_missing
  write_google_credentials
  export_optional_cloudflare_token
  print_next_steps
}

main "$@"
