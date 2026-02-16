#!/bin/zsh

KEYCHAIN_ACCOUNT="${KEYCHAIN_ACCOUNT:-cloudflare-api}"
KEYCHAIN_SERVICE="${KEYCHAIN_SERVICE:-terraform/cloudflare_api_token}"

if [[ $# -ge 1 ]]; then
  cloudflare_token="$1"
else
  if [[ -t 0 ]]; then
    read -r -s -p "Enter Cloudflare API token: " cloudflare_token
    echo
    if [[ -z "${cloudflare_token}" ]]; then
      echo "Error: Cloudflare API token cannot be empty." >&2
      exit 1
    fi
  else
    cloudflare_token=$(cat)
    if [[ -z "${cloudflare_token}" ]]; then
      echo "Error: Cloudflare API token cannot be empty." >&2
      exit 1
    fi
  fi
fi

echo "Storing Cloudflare API token in macOS Keychain (account: ${KEYCHAIN_ACCOUNT}, service: ${KEYCHAIN_SERVICE})..."

security add-generic-password \
  -a "${KEYCHAIN_ACCOUNT}" \
  -s "${KEYCHAIN_SERVICE}" \
  -w "${cloudflare_token}" \
  -U >/dev/null

echo "Cloudflare API token stored successfully."
