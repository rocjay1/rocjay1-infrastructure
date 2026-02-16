#!/bin/zsh

KEYCHAIN_ACCOUNT="${KEYCHAIN_ACCOUNT:-cloudflare-api}"
KEYCHAIN_SERVICE="${KEYCHAIN_SERVICE:-terraform/cloudflare_api_token}"

if ! token=$(security find-generic-password \
  -a "${KEYCHAIN_ACCOUNT}" \
  -s "${KEYCHAIN_SERVICE}" \
  -w 2>/dev/null); then
  echo "Unable to retrieve Cloudflare API token from Keychain (account: ${KEYCHAIN_ACCOUNT}, service: ${KEYCHAIN_SERVICE})." >&2
  echo "Hint: security add-generic-password -a ${KEYCHAIN_ACCOUNT} -s ${KEYCHAIN_SERVICE} -w '<token>'" >&2
  return 1 2>/dev/null || exit 1
fi

export TF_VAR_cloudflare_api_token="${token}"
