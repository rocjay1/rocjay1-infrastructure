#!/bin/zsh

# Load environment variables from .env file in the same directory
SCRIPT_DIR="${0:A:h}"
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "Error: .env file not found in $SCRIPT_DIR"
    exit 1
fi

# Configuration
MINIFLUX_URL="https://rss.roccosmodernsite.net"
MINIFLUX_API_KEY="$miniflux_api_key"
TARGET_DOMAIN="feeds.roccosmodernsite.net"

# 1. Fetch all feeds and identify matching IDs
echo "Identifying feeds matching $TARGET_DOMAIN..."
MATCHING_IDS=$(curl -s -f -H "X-Auth-Token: $MINIFLUX_API_KEY" "$MINIFLUX_URL/v1/feeds" | \
    jq -r ".[] | select(.feed_url | contains(\"$TARGET_DOMAIN\")) | .id")

if [ -z "$MATCHING_IDS" ]; then
    echo "No matching feeds found."
    exit 0
fi

echo "Found matching feed IDs:"
echo "$MATCHING_IDS"

# 3. Clear credentials for each feed
for ID in ${(f)MATCHING_IDS}; do
    echo "Clearing credentials for feed ID: $ID..."
    # Miniflux API expects a JSON object with the fields to update.
    # We set username and password to empty strings to remove them.
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "X-Auth-Token: $MINIFLUX_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"\", \"password\": \"\"}" \
        "$MINIFLUX_URL/v1/feeds/$ID")

    if [ "$RESPONSE" -eq 204 ] || [ "$RESPONSE" -eq 201 ]; then
        echo "Successfully cleared credentials for feed $ID (HTTP $RESPONSE)"
    else
        echo "Failed to update feed $ID (HTTP $RESPONSE)"
    fi
done

echo "Credential removal complete."
