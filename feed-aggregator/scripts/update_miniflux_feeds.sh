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
FEED_USERNAME="$auth_username"
FEED_PASSWORD="$auth_password"
TARGET_DOMAIN="feeds.roccosmodernsite.net"

# 1. Fetch all feeds
echo "Fetching feeds from Miniflux..."
FEEDS=$(curl -s -H "X-Auth-Token: $MINIFLUX_API_KEY" "$MINIFLUX_URL/v1/feeds")

# Check if FEEDS is valid JSON and not an error
if ! echo "$FEEDS" | jq . > /dev/null 2>&1; then
    echo "Error fetching feeds. Response:"
    echo "$FEEDS"
    exit 1
fi

# 2. Extract IDs of feeds matching the domain
echo "Identifying feeds matching $TARGET_DOMAIN..."
MATCHING_IDS=$(echo "$FEEDS" | jq -r ".[] | select(.feed_url | contains(\"$TARGET_DOMAIN\")) | .id")

if [ -z "$MATCHING_IDS" ]; then
    echo "No matching feeds found."
    exit 0
fi

echo "Found matching feed IDs:"
echo "$MATCHING_IDS"

# 3. Update each feed
for ID in $MATCHING_IDS; do
    echo "Updating feed ID: $ID..."
    # Miniflux API expects a JSON object with the fields to update.
    # The PUT /v1/feeds/{id} endpoint updates the feed.
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "X-Auth-Token: $MINIFLUX_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"username\": \"$FEED_USERNAME\", \"password\": \"$FEED_PASSWORD\"}" \
        "$MINIFLUX_URL/v1/feeds/$ID")

    if [ "$RESPONSE" -eq 204 ] || [ "$RESPONSE" -eq 201 ]; then
        echo "Successfully updated feed $ID (HTTP $RESPONSE)"
    else
        echo "Failed to update feed $ID (HTTP $RESPONSE)"
    fi
done

echo "Migration complete."
