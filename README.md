<div align="center">

# 👁️ Mangekyou

### *A containerised SIEM that sees what others miss*

![Docker](https://img.shields.io/badge/Docker-Containerised-2496ED?logo=docker)
![Elasticsearch](https://img.shields.io/badge/Elasticsearch-8.13.0-005571?logo=elasticsearch)
![Kibana](https://img.shields.io/badge/Kibana-8.13.0-005571?logo=kibana)
![MITRE](https://img.shields.io/badge/MITRE-ATT%26CK-red)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

## 📖 Overview

**Mangekyou** is a fully containerised Security Information and Event Management (SIEM) system built from scratch as a final year cybersecurity engineering project. Named after the evolved Sharingan eye from the anime Naruto — which grants the ability to see through deception and perceive threats others cannot — Mangekyou is designed to collect, normalise, correlate, and alert on security events across your infrastructure.

---

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────┐
│                   KALI LINUX HOST                   │
│                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐  │
│  │ Filebeat │───▶│Logstash  │───▶│Elasticsearch │  │
│  │          │    │          │    │   Cluster    │  │
│  └──────────┘    └──────────┘    └──────┬───────┘  │
│                                         │           │
│                  ┌──────────┐    ┌──────▼───────┐  │
│                  │ElastAlert│◀───│    Kibana    │  │
│                  │  Rules   │    │  Dashboards  │  │
│                  └──────────┘    └──────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Data Flow
```
Host Logs ──▶ Filebeat ──▶ Logstash ──▶ Elasticsearch ──▶ Kibana
                                              │
                                         ElastAlert
                                              │
                                          Alerts 🔴
```

---

## 🧱 Stack

| Component | Version | Role |
|---|---|---|
| **Elasticsearch** | 8.13.0 | Storage & indexing engine |
| **Kibana** | 8.13.0 | Visualisation & dashboards |
| **Logstash** | 8.13.0 | Log parsing & normalisation |
| **Filebeat** | 8.13.0 | Log collection & shipping |
| **ElastAlert 2** | Latest | Detection & alerting engine |
| **Docker** | 24+ | Containerisation |

---

## 🛡️ Detection Rules

| Rule | MITRE Technique | Severity | Trigger |
|---|---|---|---|
| SSH Brute Force | T1110.001 | 🔴 HIGH | 5 failed SSH logins in 1 min |
| Port Scan | T1046 | 🟠 MEDIUM | 20 connection attempts in 1 min |
| Privilege Escalation | T1548 | 🔴 CRITICAL | 3 sudo/su attempts in 5 mins |
| New User Created | T1136 | 🟠 HIGH | Any useradd/adduser event |

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Linux host (Kali recommended)
- 8GB RAM minimum
- 20GB disk space

### Deploy Mangekyou
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/mangekyou.git
cd mangekyou

# Set vm.max_map_count for Elasticsearch
sudo sysctl -w vm.max_map_count=262144

# Start the stack
docker compose up -d

# Wait for all containers to be healthy
./scripts/mangekyou-status.sh

# Set up Kibana
./scripts/setup-kibana.sh

# Load detection rules
./scripts/setup-rules.sh

# Build dashboards
./scripts/setup-dashboards.sh
```

### Access

| Service | URL | Credentials |
|---|---|---|
| **Kibana** | http://localhost:5601 | elastic / mangekyou_secret |
| **Elasticsearch** | http://localhost:9200 | elastic / mangekyou_secret |
| **Logstash API** | http://localhost:9600 | — |

---

## 🧪 Testing
```bash
# Run attack simulation
./scripts/test-detections.sh

# Check system status
./scripts/mangekyou-status.sh
```

---

## 📁 Project Structure
```
mangekyou/
├── docker-compose.yml          # Stack orchestration
├── .env                        # Environment variables
├── logstash/
│   ├── pipeline/
│   │   └── mangekyou.conf      # Log parsing pipeline
│   └── config/
│       └── logstash.yml
├── kibana/
│   └── kibana.yml
├── filebeat/
│   └── filebeat.yml
├── elastalert/
│   ├── config.yaml
│   └── rules/
│       ├── ssh_brute_force.yaml
│       ├── port_scan.yaml
│       ├── privilege_escalation.yaml
│       └── new_user_created.yaml
├── scripts/
│   ├── mangekyou-status.sh
│   ├── setup-kibana.sh
│   ├── setup-rules.sh
│   ├── setup-dashboards.sh
│   ├── test-detections.sh
│   └── generate-docs.sh
└── docs/
    ├── architecture.md
    ├── mitre-mapping.md
    ├── testing-report.md
    └── deployment-guide.md
```

---

## 👤 Author

FAIDI Yassine

---

<div align="center">
<i>The Mangekyou Sharingan sees through deception.<br>So does this SIEM.</i>
</div>

---

## 🚀 Correct Deployment Order (For Fresh Install)
```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/mangekyou.git
cd mangekyou

# 2. Prepare host
sudo sysctl -w vm.max_map_count=262144
sudo usermod -aG docker $USER && newgrp docker

# 3. Start the stack
docker compose up -d

# 4. Fix cluster health (run this always)
./scripts/fix-cluster.sh

# 5. Generate Kibana token (REQUIRED on every fresh install)
./scripts/setup-token.sh

# 6. Set up Kibana
./scripts/setup-kibana.sh

# 7. Load detection rules
./scripts/setup-rules.sh

# 8. Build dashboards
./scripts/setup-dashboards.sh

# 9. Test detections
./scripts/test-detections.sh

# 10. Check everything
./scripts/mangekyou-status.sh
```
