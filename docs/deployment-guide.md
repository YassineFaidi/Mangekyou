# 👁️ Mangekyou — Deployment Guide

## Prerequisites

| Requirement | Minimum | Recommended |
|---|---|---|
| OS | Any Linux | Kali Linux 2024+ |
| RAM | 8GB | 16GB |
| Disk | 20GB | 50GB |
| Docker | 24.0+ | Latest |
| Docker Compose | v2.0+ | Latest |

## Step 1 — Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/mangekyou.git
cd mangekyou
```

## Step 2 — Prepare the Host

```bash
# Required for Elasticsearch
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

## Step 3 — Configure Environment

```bash
# Review and edit credentials if needed
cat .env
```

## Step 4 — Deploy the Stack

```bash
docker compose up -d
```

## Step 5 — Verify Deployment

```bash
./scripts/mangekyou-status.sh
```

All 5 containers should show UP and Elasticsearch should be GREEN.

## Step 6 — Initialise Kibana

```bash
./scripts/setup-kibana.sh
```

## Step 7 — Load Detection Rules

```bash
./scripts/setup-rules.sh
```

## Step 8 — Build Dashboards

```bash
./scripts/setup-dashboards.sh
```

## Step 9 — Test Detections

```bash
./scripts/test-detections.sh
```

## Step 10 — Access Kibana

Open http://localhost:5601
- Username: elastic
- Password: mangekyou_secret

## Troubleshooting

### Elasticsearch unhealthy
```bash
# Disable disk watermark (development only)
curl -X PUT -u elastic:mangekyou_secret   http://localhost:9200/_cluster/settings   -H "Content-Type: application/json"   -d '{"persistent": {"cluster.routing.allocation.disk.threshold_enabled": false}}'
```

### Kibana not starting
```bash
docker logs mangekyou-kibana --tail 30
```

### Filebeat permission error
```bash
sudo chown root:root filebeat/filebeat.yml
sudo chmod 644 filebeat/filebeat.yml
docker compose restart filebeat
```

### Full reset
```bash
docker compose down -v
docker compose up -d
```
