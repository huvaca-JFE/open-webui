#!/usr/bin/env bash
set -euo pipefail

LLM_URL="${1:?Erreur : L1URL du moteur LLM est obligatoire (parametre 1)}"
LLM_KEY="${2:-}"
PREFERRED_PORT="${3:-3000}"

CONTAINER_NAME="global-open-webui"

if docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  docker port "$CONTAINER_NAME" 8080/tcp 2>/dev/null | head -n1 | awk -F: "{print \$2}"
  exit 0
fi

if docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi

find_free_port() {
  local port=$1
  while true; do
    if ! (ss -tulpn 2>/dev/null | grep -q ":${port} " || timeout 1 bash -c "</dev/tcp/127.0.0.1/${port}" 2>/dev/null); then
      echo "$port"
      return 0
    fi
    ((port++))
  done
}

FREE_PORT=$(find_free_port "$PREFERRED_PORT")

DOCKER_CMD=(
  docker run -d
  --name "$CONTAINER_NAME"
  -p "${FREE_PORT}:8080"
  -e "OPENAI_API_BASE_URL=${LLM_URL}"
)

if [ -n "$LLM_KEY" ]; then
  DOCKER_CMD+=(-e "OPENAI_API_KEY=${LLM_KEY}")
fi

DOCKER_CMD+=(
  -v global_open_webui_data:/app/backend/data
  --restart always
  ghcr.io/open-webui/open-webui:main
)

if "${DOCKER_CMD[@]}" >/dev/null 2>&1; then
  echo "$FREE_PORT"
else
  exit 1
fi
