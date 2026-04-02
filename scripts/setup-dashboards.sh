#!/bin/bash
# ─────────────────────────────────────────
#  👁️  Mangekyou — Dashboard Setup Script
#  Creates all Kibana dashboards via API
# ─────────────────────────────────────────

KIBANA_URL="http://localhost:5601"
CREDS="elastic:mangekyou_secret"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  MANGEKYOU — Building Dashboards"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get data view ID
echo "🔍 Fetching data view ID..."
DATA_VIEW_ID=$(curl -s -u "$CREDS" \
  "$KIBANA_URL/api/data_views" \
  -H "kbn-xsrf: true" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
for dv in data.get('data_view', []):
    if 'mangekyou' in dv.get('title', '').lower():
        print(dv['id'])
        break
")

if [ -z "$DATA_VIEW_ID" ]; then
  echo "❌ Could not find Mangekyou data view. Run setup-kibana.sh first."
  exit 1
fi
echo "✅ Data view ID: $DATA_VIEW_ID"

# ─────────────────────────────
#  VISUALIZATION 1
#  Events Over Time (Bar chart)
# ─────────────────────────────
echo ""
echo "📈 Creating: Events Over Time..."
VIZ1_ID=$(cat /proc/sys/kernel/random/uuid)
curl -s -X POST -u "$CREDS" \
  "$KIBANA_URL/api/saved_objects/visualization/$VIZ1_ID" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d "{
    \"attributes\": {
      \"title\": \"Mangekyou - Events Over Time\",
      \"visState\": \"{\\\"title\\\":\\\"Mangekyou - Events Over Time\\\",\\\"type\\\":\\\"histogram\\\",\\\"aggs\\\":[{\\\"id\\\":\\\"1\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"count\\\",\\\"params\\\":{},\\\"schema\\\":\\\"metric\\\"},{\\\"id\\\":\\\"2\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"date_histogram\\\",\\\"params\\\":{\\\"field\\\":\\\"@timestamp\\\",\\\"timeRange\\\":{\\\"from\\\":\\\"now-24h\\\",\\\"to\\\":\\\"now\\\"},\\\"useNormalizedEsInterval\\\":true,\\\"scaleMetricValues\\\":false,\\\"interval\\\":\\\"auto\\\",\\\"drop_partials\\\":false,\\\"min_doc_count\\\":1,\\\"extended_bounds\\\":{}},\\\"schema\\\":\\\"segment\\\"}],\\\"params\\\":{\\\"type\\\":\\\"histogram\\\",\\\"grid\\\":{\\\"categoryLines\\\":false},\\\"categoryAxes\\\":[{\\\"id\\\":\\\"CategoryAxis-1\\\",\\\"type\\\":\\\"category\\\",\\\"position\\\":\\\"bottom\\\",\\\"show\\\":true,\\\"style\\\":{},\\\"scale\\\":{\\\"type\\\":\\\"linear\\\"},\\\"labels\\\":{\\\"show\\\":true,\\\"filter\\\":true,\\\"truncate\\\":100},\\\"title\\\":{}}],\\\"valueAxes\\\":[{\\\"id\\\":\\\"ValueAxis-1\\\",\\\"name\\\":\\\"LeftAxis-1\\\",\\\"type\\\":\\\"value\\\",\\\"position\\\":\\\"left\\\",\\\"show\\\":true,\\\"style\\\":{},\\\"scale\\\":{\\\"type\\\":\\\"linear\\\",\\\"mode\\\":\\\"normal\\\"},\\\"labels\\\":{\\\"show\\\":true,\\\"rotate\\\":0,\\\"filter\\\":false,\\\"truncate\\\":100},\\\"title\\\":{\\\"text\\\":\\\"Count\\\"}}],\\\"seriesParams\\\":[{\\\"show\\\":true,\\\"type\\\":\\\"histogram\\\",\\\"mode\\\":\\\"stacked\\\",\\\"data\\\":{\\\"label\\\":\\\"Count\\\",\\\"id\\\":\\\"1\\\"},\\\"valueAxis\\\":\\\"ValueAxis-1\\\",\\\"drawLinesBetweenPoints\\\":true,\\\"lineWidth\\\":2,\\\"showCircles\\\":true}],\\\"addTooltip\\\":true,\\\"addLegend\\\":true,\\\"legendPosition\\\":\\\"right\\\",\\\"times\\\":[],\\\"addTimeMarker\\\":false,\\\"labels\\\":{},\\\"thresholdLine\\\":{\\\"show\\\":false,\\\"value\\\":10,\\\"width\\\":1,\\\"style\\\":\\\"full\\\",\\\"color\\\":\\\"#E7664C\\\"}}}\"  ,
      \"uiStateJSON\": \"{}\",
      \"description\": \"Total events ingested by Mangekyou over time\",
      \"version\": 1,
      \"kibanaSavedObjectMeta\": {
        \"searchSourceJSON\": \"{\\\"query\\\":{\\\"query_string\\\":{\\\"query\\\":\\\"*\\\",\\\"analyze_wildcard\\\":true}},\\\"filter\\\":[],\\\"indexRefName\\\":\\\"kibanaSavedObjectMeta.searchSourceJSON.index\\\"}\"
      }
    },
    \"references\": [
      {
        \"name\": \"kibanaSavedObjectMeta.searchSourceJSON.index\",
        \"type\": \"index-pattern\",
        \"id\": \"$DATA_VIEW_ID\"
      }
    ]
  }" > /dev/null
echo "✅ Events Over Time created!"

# ─────────────────────────────
#  VISUALIZATION 2
#  Attacks by Type (Pie chart)
# ─────────────────────────────
echo "🥧 Creating: Attacks by Type..."
VIZ2_ID=$(cat /proc/sys/kernel/random/uuid)
curl -s -X POST -u "$CREDS" \
  "$KIBANA_URL/api/saved_objects/visualization/$VIZ2_ID" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d "{
    \"attributes\": {
      \"title\": \"Mangekyou - Attacks by Type\",
      \"visState\": \"{\\\"title\\\":\\\"Mangekyou - Attacks by Type\\\",\\\"type\\\":\\\"pie\\\",\\\"aggs\\\":[{\\\"id\\\":\\\"1\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"count\\\",\\\"params\\\":{},\\\"schema\\\":\\\"metric\\\"},{\\\"id\\\":\\\"2\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"terms\\\",\\\"params\\\":{\\\"field\\\":\\\"attack_type.keyword\\\",\\\"orderBy\\\":\\\"1\\\",\\\"order\\\":\\\"desc\\\",\\\"size\\\":10,\\\"otherBucket\\\":false,\\\"otherBucketLabel\\\":\\\"Other\\\",\\\"missingBucket\\\":false,\\\"missingBucketLabel\\\":\\\"Missing\\\"},\\\"schema\\\":\\\"segment\\\"}],\\\"params\\\":{\\\"type\\\":\\\"pie\\\",\\\"addTooltip\\\":true,\\\"addLegend\\\":true,\\\"legendPosition\\\":\\\"right\\\",\\\"isDonut\\\":true,\\\"labels\\\":{\\\"show\\\":true,\\\"values\\\":true,\\\"last_level\\\":true,\\\"truncate\\\":100}}}\",
      \"uiStateJSON\": \"{}\",
      \"description\": \"Distribution of attack types detected by Mangekyou\",
      \"version\": 1,
      \"kibanaSavedObjectMeta\": {
        \"searchSourceJSON\": \"{\\\"query\\\":{\\\"query_string\\\":{\\\"query\\\":\\\"attack_type:*\\\",\\\"analyze_wildcard\\\":true}},\\\"filter\\\":[],\\\"indexRefName\\\":\\\"kibanaSavedObjectMeta.searchSourceJSON.index\\\"}\"
      }
    },
    \"references\": [
      {
        \"name\": \"kibanaSavedObjectMeta.searchSourceJSON.index\",
        \"type\": \"index-pattern\",
        \"id\": \"$DATA_VIEW_ID\"
      }
    ]
  }" > /dev/null
echo "✅ Attacks by Type created!"

# ─────────────────────────────
#  VISUALIZATION 3
#  MITRE Techniques (Bar chart)
# ─────────────────────────────
echo "🎯 Creating: MITRE ATT&CK Techniques..."
VIZ3_ID=$(cat /proc/sys/kernel/random/uuid)
curl -s -X POST -u "$CREDS" \
  "$KIBANA_URL/api/saved_objects/visualization/$VIZ3_ID" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d "{
    \"attributes\": {
      \"title\": \"Mangekyou - MITRE ATT&CK Techniques\",
      \"visState\": \"{\\\"title\\\":\\\"Mangekyou - MITRE ATT&CK Techniques\\\",\\\"type\\\":\\\"horizontal_bar\\\",\\\"aggs\\\":[{\\\"id\\\":\\\"1\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"count\\\",\\\"params\\\":{},\\\"schema\\\":\\\"metric\\\"},{\\\"id\\\":\\\"2\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"terms\\\",\\\"params\\\":{\\\"field\\\":\\\"mitre_technique.keyword\\\",\\\"orderBy\\\":\\\"1\\\",\\\"order\\\":\\\"desc\\\",\\\"size\\\":10,\\\"otherBucket\\\":false,\\\"otherBucketLabel\\\":\\\"Other\\\",\\\"missingBucket\\\":false,\\\"missingBucketLabel\\\":\\\"Missing\\\"},\\\"schema\\\":\\\"segment\\\"}],\\\"params\\\":{\\\"type\\\":\\\"histogram\\\",\\\"grid\\\":{\\\"categoryLines\\\":false},\\\"categoryAxes\\\":[{\\\"id\\\":\\\"CategoryAxis-1\\\",\\\"type\\\":\\\"category\\\",\\\"position\\\":\\\"left\\\",\\\"show\\\":true,\\\"style\\\":{},\\\"scale\\\":{\\\"type\\\":\\\"linear\\\"},\\\"labels\\\":{\\\"show\\\":true,\\\"filter\\\":true,\\\"truncate\\\":100},\\\"title\\\":{}}],\\\"valueAxes\\\":[{\\\"id\\\":\\\"ValueAxis-1\\\",\\\"name\\\":\\\"LeftAxis-1\\\",\\\"type\\\":\\\"value\\\",\\\"position\\\":\\\"bottom\\\",\\\"show\\\":true,\\\"style\\\":{},\\\"scale\\\":{\\\"type\\\":\\\"linear\\\",\\\"mode\\\":\\\"normal\\\"},\\\"labels\\\":{\\\"show\\\":true,\\\"rotate\\\":0,\\\"filter\\\":false,\\\"truncate\\\":100},\\\"title\\\":{\\\"text\\\":\\\"Count\\\"}}],\\\"seriesParams\\\":[{\\\"show\\\":true,\\\"type\\\":\\\"histogram\\\",\\\"mode\\\":\\\"stacked\\\",\\\"data\\\":{\\\"label\\\":\\\"Count\\\",\\\"id\\\":\\\"1\\\"},\\\"valueAxis\\\":\\\"ValueAxis-1\\\",\\\"drawLinesBetweenPoints\\\":true,\\\"lineWidth\\\":2,\\\"showCircles\\\":true}],\\\"addTooltip\\\":true,\\\"addLegend\\\":true,\\\"legendPosition\\\":\\\"right\\\",\\\"times\\\":[],\\\"addTimeMarker\\\":false,\\\"labels\\\":{},\\\"thresholdLine\\\":{\\\"show\\\":false,\\\"value\\\":10,\\\"width\\\":1,\\\"style\\\":\\\"full\\\",\\\"color\\\":\\\"#E7664C\\\"}}}\",
      \"uiStateJSON\": \"{}\",
      \"description\": \"MITRE ATT&CK techniques observed by Mangekyou\",
      \"version\": 1,
      \"kibanaSavedObjectMeta\": {
        \"searchSourceJSON\": \"{\\\"query\\\":{\\\"query_string\\\":{\\\"query\\\":\\\"mitre_technique:*\\\",\\\"analyze_wildcard\\\":true}},\\\"filter\\\":[],\\\"indexRefName\\\":\\\"kibanaSavedObjectMeta.searchSourceJSON.index\\\"}\"
      }
    },
    \"references\": [
      {
        \"name\": \"kibanaSavedObjectMeta.searchSourceJSON.index\",
        \"type\": \"index-pattern\",
        \"id\": \"$DATA_VIEW_ID\"
      }
    ]
  }" > /dev/null
echo "✅ MITRE ATT&CK Techniques created!"

# ─────────────────────────────
#  VISUALIZATION 4
#  Top Source IPs (Data table)
# ─────────────────────────────
echo "🌐 Creating: Top Source IPs..."
VIZ4_ID=$(cat /proc/sys/kernel/random/uuid)
curl -s -X POST -u "$CREDS" \
  "$KIBANA_URL/api/saved_objects/visualization/$VIZ4_ID" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d "{
    \"attributes\": {
      \"title\": \"Mangekyou - Top Source IPs\",
      \"visState\": \"{\\\"title\\\":\\\"Mangekyou - Top Source IPs\\\",\\\"type\\\":\\\"table\\\",\\\"aggs\\\":[{\\\"id\\\":\\\"1\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"count\\\",\\\"params\\\":{},\\\"schema\\\":\\\"metric\\\"},{\\\"id\\\":\\\"2\\\",\\\"enabled\\\":true,\\\"type\\\":\\\"terms\\\",\\\"params\\\":{\\\"field\\\":\\\"source_ip.keyword\\\",\\\"orderBy\\\":\\\"1\\\",\\\"order\\\":\\\"desc\\\",\\\"size\\\":10,\\\"otherBucket\\\":false,\\\"otherBucketLabel\\\":\\\"Other\\\",\\\"missingBucket\\\":false,\\\"missingBucketLabel\\\":\\\"Missing\\\"},\\\"schema\\\":\\\"bucket\\\"}],\\\"params\\\":{\\\"perPage\\\":10,\\\"showPartialRows\\\":false,\\\"showMetricsAtAllLevels\\\":false,\\\"showTotal\\\":false,\\\"totalFunc\\\":\\\"sum\\\",\\\"percentageCol\\\":\\\"\\\"}}\",
      \"uiStateJSON\": \"{}\",
      \"description\": \"Top attacking source IPs detected by Mangekyou\",
      \"version\": 1,
      \"kibanaSavedObjectMeta\": {
        \"searchSourceJSON\": \"{\\\"query\\\":{\\\"query_string\\\":{\\\"query\\\":\\\"source_ip:*\\\",\\\"analyze_wildcard\\\":true}},\\\"filter\\\":[],\\\"indexRefName\\\":\\\"kibanaSavedObjectMeta.searchSourceJSON.index\\\"}\"
      }
    },
    \"references\": [
      {
        \"name\": \"kibanaSavedObjectMeta.searchSourceJSON.index\",
        \"type\": \"index-pattern\",
        \"id\": \"$DATA_VIEW_ID\"
      }
    ]
  }" > /dev/null
echo "✅ Top Source IPs created!"

# ─────────────────────────────
#  DASHBOARD — Mangekyou Overview
# ─────────────────────────────
echo ""
echo "🖥️  Building Mangekyou Overview Dashboard..."
DASH_ID=$(cat /proc/sys/kernel/random/uuid)
curl -s -X POST -u "$CREDS" \
  "$KIBANA_URL/api/saved_objects/dashboard/$DASH_ID" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  -d "{
    \"attributes\": {
      \"title\": \"👁️ Mangekyou SIEM — Overview\",
      \"description\": \"Mangekyou SIEM main overview dashboard\",
      \"panelsJSON\": \"[{\\\"version\\\":\\\"8.13.0\\\",\\\"type\\\":\\\"visualization\\\",\\\"gridData\\\":{\\\"x\\\":0,\\\"y\\\":0,\\\"w\\\":24,\\\"h\\\":15,\\\"i\\\":\\\"1\\\"},\\\"panelIndex\\\":\\\"1\\\",\\\"embeddableConfig\\\":{\\\"enhancements\\\":{}},\\\"panelRefName\\\":\\\"panel_1\\\"},{\\\"version\\\":\\\"8.13.0\\\",\\\"type\\\":\\\"visualization\\\",\\\"gridData\\\":{\\\"x\\\":24,\\\"y\\\":0,\\\"w\\\":24,\\\"h\\\":15,\\\"i\\\":\\\"2\\\"},\\\"panelIndex\\\":\\\"2\\\",\\\"embeddableConfig\\\":{\\\"enhancements\\\":{}},\\\"panelRefName\\\":\\\"panel_2\\\"},{\\\"version\\\":\\\"8.13.0\\\",\\\"type\\\":\\\"visualization\\\",\\\"gridData\\\":{\\\"x\\\":0,\\\"y\\\":15,\\\"w\\\":24,\\\"h\\\":15,\\\"i\\\":\\\"3\\\"},\\\"panelIndex\\\":\\\"3\\\",\\\"embeddableConfig\\\":{\\\"enhancements\\\":{}},\\\"panelRefName\\\":\\\"panel_3\\\"},{\\\"version\\\":\\\"8.13.0\\\",\\\"type\\\":\\\"visualization\\\",\\\"gridData\\\":{\\\"x\\\":24,\\\"y\\\":15,\\\"w\\\":24,\\\"h\\\":15,\\\"i\\\":\\\"4\\\"},\\\"panelIndex\\\":\\\"4\\\",\\\"embeddableConfig\\\":{\\\"enhancements\\\":{}},\\\"panelRefName\\\":\\\"panel_4\\\"}]\",
      \"optionsJSON\": \"{\\\"useMargins\\\":true,\\\"syncColors\\\":false,\\\"hidePanelTitles\\\":false}\",
      \"version\": 1,
      \"timeRestore\": false,
      \"kibanaSavedObjectMeta\": {
        \"searchSourceJSON\": \"{\\\"query\\\":{\\\"language\\\":\\\"kuery\\\",\\\"query\\\":\\\"\\\"},\\\"filter\\\":[]}\"
      }
    },
    \"references\": [
      {\"name\": \"panel_1\", \"type\": \"visualization\", \"id\": \"$VIZ1_ID\"},
      {\"name\": \"panel_2\", \"type\": \"visualization\", \"id\": \"$VIZ2_ID\"},
      {\"name\": \"panel_3\", \"type\": \"visualization\", \"id\": \"$VIZ3_ID\"},
      {\"name\": \"panel_4\", \"type\": \"visualization\", \"id\": \"$VIZ4_ID\"}
    ]
  }" > /dev/null
echo "✅ Mangekyou Overview Dashboard created!"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  Dashboards Built Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📈 Events Over Time"
echo "  🥧 Attacks by Type"
echo "  🎯 MITRE ATT&CK Techniques"
echo "  🌐 Top Source IPs"
echo "  🖥️  Mangekyou Overview Dashboard"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Open Kibana → Dashboard → search 'Mangekyou'"
echo "  http://localhost:5601/app/dashboards"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
