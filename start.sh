cat << 'EOF' > start.sh
#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")"

echo "=== Démarrage d'Open WebUI Global ==="

# Vérification qu'Ollama est joignable via la passerelle Docker
if ! curl -s --max-time 3 "http://172.18.0.1:11434/api/tags" >/dev/null; then
  echo "⚠️️  Ollama ne répond pas sur http://172.18.0.1:11434. Vérifie le service systemd."
fi

docker compose up -d

WSL_IP=$(hostname -I | awk '{print $1}')

echo "=================================================="
echo " Open WebUI est opérationnel :"
echo " - URL locale  : http://127.0.0.1:3000"
echo " - URL réseau  : http://${WSL_IP}:3000"
echo "=================================================="
EOF

chmod +x start.sh