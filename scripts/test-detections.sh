#!/bin/bash
# ─────────────────────────────────────────
#  👁️  Mangekyou — Attack Simulation
#  Generates real attack traffic to test
#  detection rules against MITRE ATT&CK
# ─────────────────────────────────────────

ES_URL="http://localhost:9200"
CREDS="elastic:mangekyou_secret"
INDEX="mangekyou-logs-$(date +%Y.%m.%d)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  MANGEKYOU — Attack Simulation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─────────────────────────────
#  TEST 1 — SSH Brute Force
#  MITRE T1110.001
# ─────────────────────────────
echo ""
echo "🔴 Simulating SSH Brute Force (T1110.001)..."
for i in $(seq 1 10); do
  curl -s -X POST -u "$CREDS" \
    "$ES_URL/$INDEX/_doc" \
    -H "Content-Type: application/json" \
    -d "{
      \"@timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
      \"message\": \"Failed password for invalid user admin from 192.168.1.100 port 4444 ssh2\",
      \"type\": \"syslog\",
      \"siem\": \"mangekyou\",
      \"tags\": [\"ssh\", \"brute-force\", \"mangekyou\"],
      \"source_ip\": \"192.168.1.100\",
      \"attack_type\": \"ssh_brute_force\",
      \"mitre_technique\": \"T1110.001\"
    }" > /dev/null
  echo "   → Injected SSH fail attempt $i/10"
  sleep 0.2
done
echo "✅ SSH Brute Force simulation complete!"

# ─────────────────────────────
#  TEST 2 — Port Scan
#  MITRE T1046
# ─────────────────────────────
echo ""
echo "🟠 Simulating Port Scan (T1046)..."
for port in 22 23 25 80 443 3306 5432 6379 8080 8443 9200 27017 3389 5900 21 53 110 143 993 995; do
  curl -s -X POST -u "$CREDS" \
    "$ES_URL/$INDEX/_doc" \
    -H "Content-Type: application/json" \
    -d "{
      \"@timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
      \"message\": \"Connection refused from 10.0.0.5 to port $port\",
      \"type\": \"syslog\",
      \"siem\": \"mangekyou\",
      \"tags\": [\"port-scan\", \"mangekyou\"],
      \"source_ip\": \"10.0.0.5\",
      \"destination_port\": $port,
      \"attack_type\": \"port_scan\",
      \"mitre_technique\": \"T1046\"
    }" > /dev/null
  echo "   → Scanned port $port"
  sleep 0.1
done
echo "✅ Port Scan simulation complete!"

# ─────────────────────────────
#  TEST 3 — Privilege Escalation
#  MITRE T1548
# ─────────────────────────────
echo ""
echo "🟡 Simulating Privilege Escalation (T1548)..."
SUDO_CMDS=(
  "sudo su root attempted by user kali TTY=unknown"
  "sudo NOPASSWD command executed by kali"
  "su root failed attempt from terminal TTY=unknown"
  "sudo -i attempted privilege escalation"
  "NOPASSWD entry used for root access"
)
for cmd in "${SUDO_CMDS[@]}"; do
  curl -s -X POST -u "$CREDS" \
    "$ES_URL/$INDEX/_doc" \
    -H "Content-Type: application/json" \
    -d "{
      \"@timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
      \"message\": \"$cmd\",
      \"type\": \"syslog\",
      \"siem\": \"mangekyou\",
      \"tags\": [\"privilege-escalation\", \"mangekyou\"],
      \"attack_type\": \"privilege_escalation\",
      \"mitre_technique\": \"T1548\"
    }" > /dev/null
  echo "   → Injected: $cmd"
  sleep 0.2
done
echo "✅ Privilege Escalation simulation complete!"

# ─────────────────────────────
#  TEST 4 — New User Created
#  MITRE T1136
# ─────────────────────────────
echo ""
echo "🔵 Simulating New User Creation (T1136)..."
curl -s -X POST -u "$CREDS" \
  "$ES_URL/$INDEX/_doc" \
  -H "Content-Type: application/json" \
  -d "{
    \"@timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
    \"message\": \"new user added: name=backdoor, UID=1337, GID=0 by useradd\",
    \"type\": \"syslog\",
    \"siem\": \"mangekyou\",
    \"tags\": [\"persistence\", \"new-user\", \"mangekyou\"],
    \"attack_type\": \"new_user_created\",
    \"mitre_technique\": \"T1136\"
  }" > /dev/null
echo "   → Injected: backdoor user created (UID=1337)"
echo "✅ New User Creation simulation complete!"

# ─────────────────────────────
#  RESULTS
# ─────────────────────────────
echo ""
echo "⏳ Waiting for Elasticsearch to index events..."
sleep 3

echo ""
echo "📊 Verifying injected attack events..."
TOTAL=$(curl -s -u "$CREDS" \
  "$ES_URL/$INDEX/_count?q=tags:mangekyou+AND+attack_type:*" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['count'])")
echo "   Total attack events indexed: $TOTAL"

echo ""
echo "🔍 Events by attack type:"
curl -s -u "$CREDS" \
  -H "Content-Type: application/json" \
  "$ES_URL/$INDEX/_search" \
  -d '{
    "size": 0,
    "aggs": {
      "by_attack": {
        "terms": { "field": "attack_type.keyword" }
      }
    }
  }' | python3 -c "
import sys, json
data = json.load(sys.stdin)
buckets = data['aggregations']['by_attack']['buckets']
for b in buckets:
    print(f'   {b[\"key\"]:<30} {b[\"doc_count\"]} events')
"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  Attack Simulation Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Now check Kibana Discover for events:"
echo "  http://localhost:5601"
echo ""
echo "  Search: attack_type: *"
echo "  Or:     tags: mangekyou AND attack_type: *"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
