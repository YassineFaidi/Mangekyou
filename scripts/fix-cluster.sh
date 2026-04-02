#!/bin/bash
# ─────────────────────────────────────────
#  👁️  Mangekyou — Fix Cluster Health
# ─────────────────────────────────────────

ES_URL="http://localhost:9200"
CREDS="elastic:mangekyou_secret"

echo "🔧 Fixing Elasticsearch cluster health..."

curl -s -X PUT -u "$CREDS" "$ES_URL/_cluster/settings" \
  -H "Content-Type: application/json" \
  -d '{"persistent": {"cluster.routing.allocation.disk.threshold_enabled": false}}' \
  > /dev/null

curl -s -X PUT -u "$CREDS" "$ES_URL/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index": {"number_of_replicas": 0}}' \
  > /dev/null

curl -s -X POST -u "$CREDS" \
  "$ES_URL/_cluster/reroute?retry_failed=true" \
  -H "Content-Type: application/json" \
  > /dev/null

sleep 3

STATUS=$(curl -s -u "$CREDS" "$ES_URL/_cluster/health" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['status'].upper())")

echo "✅ Cluster status: $STATUS"
