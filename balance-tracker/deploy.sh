#!/bin/zsh

SCRIPT_DIR="${0:A:h}"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PI_HOST="${PI_HOST:-raspberrypi.local}"

# Load Cloudflare API token into environment for Terraform
if [[ -f "${REPO_DIR}/load-cloudflare-token.sh" ]]; then
  source "${REPO_DIR}/load-cloudflare-token.sh"
fi

echo "Copying config files and docker-compose.yml to ${PI_HOST}..."
# Ensure the directory exists on the Pi and is owned by the login user
ssh "${PI_HOST}" "sudo mkdir -p /opt/balance-tracker/config && sudo chown -R \$(whoami):\$(whoami) /opt/balance-tracker"

# Copy compose and env/config
scp "${SCRIPT_DIR}/docker-compose.yml" "${PI_HOST}:/opt/balance-tracker/docker-compose.yml"

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    scp "${SCRIPT_DIR}/.env" "${PI_HOST}:/opt/balance-tracker/.env"
else
    echo "Warning: .env not found at ${SCRIPT_DIR}/.env. Pulling TUNNEL_TOKEN from Terraform..."
    terraform -chdir="${REPO_DIR}" output -raw balance_tracker_tunnel_token \
      | sed 's/^/TUNNEL_TOKEN=/' \
      | ssh "${PI_HOST}" "cat > /opt/balance-tracker/.env"
fi

if [[ -f "${SCRIPT_DIR}/config/config.yaml" ]]; then
    scp "${SCRIPT_DIR}/config/config.yaml" "${PI_HOST}:/opt/balance-tracker/config/config.yaml"
fi

# Fix common "config.json is a directory" Docker issue and sync credentials
echo "Syncing Docker credentials for Watchtower..."
ssh "${PI_HOST}" '
  if [[ -d ~/.docker/config.json ]]; then rm -rf ~/.docker/config.json; fi
  sudo rm -rf /root/.docker/config.json
  if [[ -f ~/.docker/config.json ]]; then cp ~/.docker/config.json /opt/balance-tracker/docker-config.json; fi
'

echo "Starting Balance Tracker on ${PI_HOST}..."
ssh "${PI_HOST}" '
  cd /opt/balance-tracker
  # Run without sudo as admin is in the docker group and authenticated
  docker compose pull
  docker compose up -d
  docker image prune -f
'

echo "Balance Tracker is up on ${PI_HOST}."

