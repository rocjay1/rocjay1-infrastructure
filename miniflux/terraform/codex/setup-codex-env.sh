#!/usr/bin/env bash
set -euo pipefail

# Codex Web setup for miniflux/terraform.
# Expected secrets:
#   - GOOGLE_APPLICATION_CREDENTIALS_JSON (required)
#   - CLOUDFLARE_API_TOKEN (optional, required for Cloudflare workspaces)

TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.8.5}"
GOOGLE_CREDS_PATH="${GOOGLE_CREDS_PATH:-}"
MANAGED_GOOGLE_CREDS_PATH=""

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

  local arch
  case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *)
      log "ERROR: unsupported architecture: $(uname -m)"
      return 1
      ;;
  esac

  local tmp_zip="/tmp/terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"
  wget -qO "${tmp_zip}" "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"
  unzip -qo "${tmp_zip}" -d /usr/local/bin
  chmod +x /usr/local/bin/terraform

  log "terraform installed: $(terraform version | head -n1)"
}

write_google_credentials() {
  if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS_JSON:-}" ]]; then
    log "ERROR: GOOGLE_APPLICATION_CREDENTIALS_JSON is required"
    return 1
  fi

  cleanup_managed_google_credentials() {
    if [[ -n "${MANAGED_GOOGLE_CREDS_PATH}" && -f "${MANAGED_GOOGLE_CREDS_PATH}" ]]; then
      rm -f "${MANAGED_GOOGLE_CREDS_PATH}"
      log "deleted managed temporary credentials file: ${MANAGED_GOOGLE_CREDS_PATH}"
    fi
  }

  local creds_path
  if [[ -n "${GOOGLE_CREDS_PATH}" ]]; then
    creds_path="${GOOGLE_CREDS_PATH}"
    log "using explicit GOOGLE_CREDS_PATH: ${creds_path}"
  else
    creds_path="$(mktemp /tmp/gcp-terraform-sa.XXXXXX.json)"
    MANAGED_GOOGLE_CREDS_PATH="${creds_path}"
    trap cleanup_managed_google_credentials EXIT
    log "using managed temporary credentials path: ${creds_path}"
  fi

  umask 077
  printf '%s' "${GOOGLE_APPLICATION_CREDENTIALS_JSON}" > "${creds_path}"
  chmod 600 "${creds_path}"

  export GOOGLE_APPLICATION_CREDENTIALS="${creds_path}"
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
