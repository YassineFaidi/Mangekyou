#!/bin/bash
# ─────────────────────────────────────────
#  👁️  Mangekyou — Status Check Script
# ─────────────────────────────────────────

ES_URL="http://localhost:9200"
KIBANA_URL="http://localhost:5601"
CREDS="elastic:mangekyou_secret"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  MANGEKYOU SIEM — STATUS CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Docker containers
echo ""
echo "🐳 CONTAINERS:"
docker compose ps --format "table {{.Name}}\t{{.Status}}"

# Elasticsearch health
echo ""
echo "🔍 ELASTICSEARCH:"
HEALTH=$(curl -s -u "$CREDS" "$ES_URL/_cluster/health" | python3 -c "import sys,json; h=json.load(sys.stdin); print(f\"  Status: {h['status'].upper()} | Shards: {h['active_shards']} active | Nodes: {h['number_of_nodes']}\")")
echo "$HEALTH"

# Index stats
echo ""
echo "📦 INDICES:"
curl -s -u "$CREDS" "$ES_URL/_cat/indices/mangekyou-logs-*?h=index,docs.count,store.size&s=index" | \
  awk '{printf "  %-40s %8s docs  %s\n", $1, $2, $3}'

# Total docs
echo ""
TOTAL=$(curl -s -u "$CREDS" "$ES_URL/mangekyou-logs-*/_count" | python3 -c "import sys,json; print(json.load(sys.stdin)['count'])")
echo "📊 TOTAL EVENTS INDEXED: $TOTAL"

# Kibana status
echo ""
echo "🌐 KIBANA:"
KSTATUS=$(curl -s "$KIBANA_URL/api/status" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f\"  {d['status']['overall']['level'].upper()}\")" 2>/dev/null || echo "  STARTING...")
echo "$KSTATUS"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Kibana:        http://localhost:5601"
echo "🔍 Elasticsearch: http://localhost:9200"
echo "⚙️  Logstash API:  http://localhost:9600"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
