#!/usr/bin/env bash
set -euo pipefail

# Codex Web setup for miniflux/terraform.
# Expected secrets:
#   - GOOGLE_APPLICATION_CREDENTIALS_JSON (required)
#   - CLOUDFLARE_API_TOKEN (optional, required for Cloudflare workspaces)

TERRAFORM_VERSION="${TERRAFORM_VERSION:-1.8.5}"
TERRAFORM_ENFORCE_VERSION="${TERRAFORM_ENFORCE_VERSION:-false}"
GOOGLE_CREDS_PATH="${GOOGLE_CREDS_PATH:-/tmp/gcp-terraform-sa.json}"

log() {
  printf '[codex-setup] %s\n' "$*"
}

install_terraform_if_missing() {
  if command -v terraform >/dev/null 2>&1; then
    local installed_version
    installed_version="$(terraform version -json 2>/dev/null | sed -n 's/.*\"terraform_version\":\"\([^\"]*\)\".*/\1/p' || true)"

    if [[ -z "${installed_version}" ]]; then
      installed_version="$(terraform version | head -n1)"
      log "terraform already installed: ${installed_version}"
      return
    fi

    if [[ "${installed_version}" == "${TERRAFORM_VERSION}" ]]; then
      log "terraform already installed and matches requested version: v${installed_version}"
      return
    fi

    if [[ "${TERRAFORM_ENFORCE_VERSION}" != "true" ]]; then
      log "terraform already installed: v${installed_version} (requested v${TERRAFORM_VERSION})"
      log "set TERRAFORM_ENFORCE_VERSION=true to replace with requested version"
      return
    fi

    log "terraform version mismatch (installed v${installed_version}, requested v${TERRAFORM_VERSION}); replacing due to TERRAFORM_ENFORCE_VERSION=true"
  fi

  log "installing terraform v${TERRAFORM_VERSION}"
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
  local base_url="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}"
  local archive="terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"
  local archive_url="${base_url}/${archive}"
  local checksums="terraform_${TERRAFORM_VERSION}_SHA256SUMS"
  local checksums_url="${base_url}/${checksums}"
  local checksums_file="/tmp/${checksums}"

  wget -qO "${tmp_zip}" "${archive_url}"
  wget -qO "${checksums_file}" "${checksums_url}"

  log "validating checksum for ${archive} (${checksums_url})"
  local expected_hash
  expected_hash="$(awk -v artifact="${archive}" '$2 == artifact { print $1 }' "${checksums_file}")"

  if [[ -z "${expected_hash}" ]]; then
    log "ERROR: failed to find checksum entry for ${archive} in ${checksums_url}"
    return 1
  fi

  local actual_hash
  actual_hash="$(sha256sum "${tmp_zip}" | awk '{ print $1 }')"

  if [[ "${actual_hash}" != "${expected_hash}" ]]; then
    log "ERROR: checksum validation failed for ${archive} (${archive_url})"
    log "ERROR: expected ${expected_hash}, got ${actual_hash}"
    return 1
  fi

  unzip -qo "${tmp_zip}" -d /usr/local/bin
  chmod +x /usr/local/bin/terraform

  log "terraform installed: $(terraform version | head -n1)"
}

write_google_credentials() {
  if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS_JSON:-}" ]]; then
    log "ERROR: GOOGLE_APPLICATION_CREDENTIALS_JSON is required"
    return 1
  fi

  local creds_path
  creds_path="${GOOGLE_CREDS_PATH}"
  mkdir -p "$(dirname "${creds_path}")"
  log "using credentials path: ${creds_path}"

  umask 077
  printf '%s' "${GOOGLE_APPLICATION_CREDENTIALS_JSON}" > "${creds_path}"
  chmod 600 "${creds_path}"

  python3 - <<'PY' "${creds_path}"
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
with path.open("r", encoding="utf-8") as fh:
    doc = json.load(fh)

required = ["type", "client_email", "private_key"]
missing = [key for key in required if not doc.get(key)]
if missing:
    raise SystemExit(f"credentials JSON missing required key(s): {', '.join(missing)}")
PY

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
