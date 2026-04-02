#!/bin/bash
# ─────────────────────────────────────────
#  👁️  Mangekyou — Generate Kibana Token
#  Run this ONCE after first docker compose up
# ─────────────────────────────────────────

ES_URL="http://localhost:9200"
CREDS="elastic:mangekyou_secret"
COMPOSE_FILE="docker-compose.yml"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  MANGEKYOU — Kibana Token Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Wait for Elasticsearch
echo "⏳ Waiting for Elasticsearch..."
until curl -s -u "$CREDS" "$ES_URL/_cluster/health" | grep -q '"status"'; do
  sleep 3
  echo "   still waiting..."
done
echo "✅ Elasticsearch is up!"

# Delete old token if exists
curl -s -X DELETE -u "$CREDS" \
  "$ES_URL/_security/service/elastic/kibana/credential/token/mangekyou-kibana-token" \
  > /dev/null

# Generate fresh token
echo "🔑 Generating fresh Kibana service token..."
TOKEN=$(curl -s -X POST -u "$CREDS" \
  "$ES_URL/_security/service/elastic/kibana/credential/token/mangekyou-kibana-token" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['token']['value'])")

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to generate token. Is Elasticsearch running?"
  exit 1
fi

echo "✅ Token generated!"

# Inject token into docker-compose.yml
sed -i "s|ELASTICSEARCH_SERVICEACCOUNTTOKEN=.*|ELASTICSEARCH_SERVICEACCOUNTTOKEN=$TOKEN|g" \
  "$COMPOSE_FILE"

echo "✅ Token injected into docker-compose.yml!"

# Restart Kibana with new token
echo "🔄 Restarting Kibana..."
docker compose stop kibana
docker compose rm -f kibana
docker compose up -d kibana

echo ""
echo "⏳ Waiting for Kibana to start (90 seconds)..."
sleep 90

STATUS=$(curl -s "http://localhost:5601/api/status" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['status']['overall']['level'])" \
  2>/dev/null || echo "starting")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  Kibana Status: $STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Open: http://localhost:5601"
echo "  User: elastic"
echo "  Pass: mangekyou_secret"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
