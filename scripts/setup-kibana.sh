#!/bin/bash
# ─────────────────────────────────────────
#  👁️  Mangekyou — Kibana Setup Script
#  Creates data views and saved searches
# ─────────────────────────────────────────

KIBANA_URL="http://localhost:5601"
ES_URL="http://localhost:9200"
CREDS="elastic:mangekyou_secret"

echo "👁️  Mangekyou — Setting up Kibana..."

# Wait for Kibana to be ready
echo "⏳ Waiting for Kibana to be ready..."
until curl -s "$KIBANA_URL/api/status" | grep -q '"level":"available"'; do
  echo "   still waiting..."
  sleep 5
done
echo "✅ Kibana is ready!"

# Create Data View for mangekyou logs
echo "📊 Creating Mangekyou Logs data view..."
curl -s -X POST "$KIBANA_URL/api/data_views/data_view" \
  -u "$CREDS" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "data_view": {
      "title": "mangekyou-logs-*",
      "name": "Mangekyou Logs",
      "timeFieldName": "@timestamp"
    }
  }' | python3 -m json.tool
echo ""
echo "✅ Data view created!"

# Create saved search — All Events
echo "🔍 Creating saved search: All Events..."
curl -s -X POST "$KIBANA_URL/api/saved_objects/search" \
  -u "$CREDS" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Mangekyou - All Events",
      "description": "All events ingested by Mangekyou SIEM",
      "hits": 0,
      "columns": ["host.name", "message", "tags"],
      "sort": [["@timestamp", "desc"]],
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query_string\":{\"query\":\"*\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
    }
  }' | python3 -m json.tool
echo ""
echo "✅ Saved search created!"

# Create saved search — SSH Activity
echo "🔍 Creating saved search: SSH Activity..."
curl -s -X POST "$KIBANA_URL/api/saved_objects/search" \
  -u "$CREDS" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Mangekyou - SSH Activity",
      "description": "All SSH related events",
      "hits": 0,
      "columns": ["host.name", "message"],
      "sort": [["@timestamp", "desc"]],
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query_string\":{\"query\":\"message:*ssh* OR message:*SSH*\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
    }
  }' | python3 -m json.tool
echo ""
echo "✅ SSH Activity search created!"

# Create saved search — Failed Logins
echo "🔍 Creating saved search: Failed Logins..."
curl -s -X POST "$KIBANA_URL/api/saved_objects/search" \
  -u "$CREDS" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "title": "Mangekyou - Failed Logins",
      "description": "All failed login attempts",
      "hits": 0,
      "columns": ["host.name", "message"],
      "sort": [["@timestamp", "desc"]],
      "version": 1,
      "kibanaSavedObjectMeta": {
        "searchSourceJSON": "{\"query\":{\"query_string\":{\"query\":\"message:*Failed* OR message:*failed* OR message:*invalid*\",\"analyze_wildcard\":true}},\"filter\":[]}"
      }
    }
  }' | python3 -m json.tool
echo ""
echo "✅ Failed Logins search created!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  Mangekyou Kibana Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Open Kibana: http://localhost:5601"
echo "📊 Go to Discover → select 'Mangekyou Logs'"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
