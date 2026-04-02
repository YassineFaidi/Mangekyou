#!/bin/bash
# ─────────────────────────────────────────
#  👁️  Mangekyou — Detection Rules Setup
#  Loads all ElastAlert detection rules
# ─────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  MANGEKYOU — Loading Detection Rules"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ─────────────────────────────
#  RULE 1 — SSH Brute Force
#  MITRE ATT&CK: T1110.001
# ─────────────────────────────
cat > elastalert/rules/ssh_brute_force.yaml << 'RULE'
name: Mangekyou - SSH Brute Force Detection
type: frequency
index: mangekyou-logs-*

# Trigger if 5 failed SSH attempts in 1 minute
num_events: 5
timeframe:
  minutes: 1

filter:
  - query:
      query_string:
        query: 'message:*"Failed password"* OR message:*"Invalid user"*'

alert:
  - debug

alert_text: |
  👁️ MANGEKYOU ALERT — SSH BRUTE FORCE DETECTED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Rule:        SSH Brute Force Detection
  MITRE:       T1110.001 - Brute Force: Password Guessing
  Severity:    HIGH
  Events:      {num_hits} failed attempts in 1 minute
  Time:        {time}
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alert_text_type: alert_text_only
RULE
echo "✅ Rule 1 loaded: SSH Brute Force (MITRE T1110.001)"

# ─────────────────────────────
#  RULE 2 — Port Scan Detection
#  MITRE ATT&CK: T1046
# ─────────────────────────────
cat > elastalert/rules/port_scan.yaml << 'RULE'
name: Mangekyou - Port Scan Detection
type: frequency
index: mangekyou-logs-*

# Trigger if 20 connection attempts in 1 minute
num_events: 20
timeframe:
  minutes: 1

filter:
  - query:
      query_string:
        query: 'message:*"Connection refused"* OR message:*"connect to"* OR message:*"port scan"*'

alert:
  - debug

alert_text: |
  👁️ MANGEKYOU ALERT — PORT SCAN DETECTED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Rule:        Port Scan Detection
  MITRE:       T1046 - Network Service Discovery
  Severity:    MEDIUM
  Events:      {num_hits} connection attempts in 1 minute
  Time:        {time}
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alert_text_type: alert_text_only
RULE
echo "✅ Rule 2 loaded: Port Scan Detection (MITRE T1046)"

# ─────────────────────────────
#  RULE 3 — Privilege Escalation
#  MITRE ATT&CK: T1548
# ─────────────────────────────
cat > elastalert/rules/privilege_escalation.yaml << 'RULE'
name: Mangekyou - Privilege Escalation Detection
type: frequency
index: mangekyou-logs-*

num_events: 3
timeframe:
  minutes: 5

filter:
  - query:
      query_string:
        query: 'message:*"sudo"* OR message:*"su root"* OR message:*"NOPASSWD"* OR message:*"TTY=unknown"*'

alert:
  - debug

alert_text: |
  👁️ MANGEKYOU ALERT — PRIVILEGE ESCALATION DETECTED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Rule:        Privilege Escalation Detection
  MITRE:       T1548 - Abuse Elevation Control Mechanism
  Severity:    CRITICAL
  Events:      {num_hits} sudo/su attempts in 5 minutes
  Time:        {time}
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alert_text_type: alert_text_only
RULE
echo "✅ Rule 3 loaded: Privilege Escalation (MITRE T1548)"

# ─────────────────────────────
#  RULE 4 — New User Created
#  MITRE ATT&CK: T1136
# ─────────────────────────────
cat > elastalert/rules/new_user_created.yaml << 'RULE'
name: Mangekyou - New User Account Created
type: any
index: mangekyou-logs-*

filter:
  - query:
      query_string:
        query: 'message:*"new user"* OR message:*"useradd"* OR message:*"adduser"*'

alert:
  - debug

alert_text: |
  👁️ MANGEKYOU ALERT — NEW USER ACCOUNT CREATED
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Rule:        New User Account Created
  MITRE:       T1136 - Create Account
  Severity:    HIGH
  Time:        {time}
  Message:     {message}
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alert_text_type: alert_text_only
RULE
echo "✅ Rule 4 loaded: New User Created (MITRE T1136)"

# Restart ElastAlert to pick up new rules
echo ""
echo "🔄 Restarting ElastAlert to load rules..."
docker compose restart elastalert
sleep 5

# Verify ElastAlert is running
STATUS=$(docker inspect --format='{{.State.Status}}' mangekyou-elastalert)
echo "✅ ElastAlert status: $STATUS"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  Detection Rules Loaded Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Rule 1: SSH Brute Force     — T1110.001"
echo "  Rule 2: Port Scan           — T1046"
echo "  Rule 3: Privilege Escalation — T1548"
echo "  Rule 4: New User Created    — T1136"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next: run ./scripts/test-detections.sh to simulate attacks!"
echo ""
