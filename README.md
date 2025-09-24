# Food Delivery Streaming Pipeline (CDC → Kafka → Flink → OpenSearch/Redis/Delta)

![Architecture](docs/architecture.jpg)

This repository showcases an end‑to‑end streaming data pipeline for a food‑delivery platform:
**PostgreSQL (OLTP) → Debezium CDC → Kafka → Flink SQL → OpenSearch & Redis**, with an optional
Delta Lake sink for offline analytics.

The goal is to keep **near‑real‑time materialized views** (e.g., `orders_summary` per status) in
OpenSearch for fast search/filters, and **online features** in Redis; while the original OLTP
database continues to serve writes.

---

## Stack

- **PostgreSQL** – Source OLTP (`fooddb`) with tables like `orders`, `catalog`, `delivery`.
- **Kafka** – Event backbone.
- **Debezium PostgreSQL** (Kafka Connect) – Change Data Capture from Postgres to Kafka.
- **Flink SQL** – Consumes Kafka topics, computes views/features, sinks to OpenSearch (and optionally Redis/Delta).
- **OpenSearch** – Search/analytics store for materialized views.
- **Redis** (optional) – Online feature store (ETA/dispatch features).
- **Delta Lake + S3** (optional) – Offline analytics sink (batch or micro‑batch).

---

## Folder Layout

```
.
├─ docker/                 # docker-compose.yml + service configs
├─ flink/
│  ├─ conf/                # Flink config
│  └─ sql/                 # Flink SQL jobs (e.g., 01_orders_summary.sql)
├─ scripts/                # Helper scripts
│  ├─ get_flink_jars.sh
│  ├─ register_connectors.sh
│  └─ sql_submit.sh
├─ consumers/              # (optional) example consumers (Redis, etc.)
├─ services/api/           # (optional) demo API
└─ docs/
   └─ architecture.jpg     # Architecture diagram
```

---

## Prerequisites

- **Docker** and **Docker Compose**
- **curl** (and optionally **jq**) on your host for quick checks
- **Git**

> **Windows users:** run commands in **WSL2** or Git Bash. If you see CRLF/LF warnings, it’s harmless; you can set `git config core.autocrlf true` if needed.

---

## Quick Start

### 1) Clone & prepare
```bash
git clone https://github.com/<your-username>/food-delivery-pipeline-latest.git
cd food-delivery-pipeline-latest
```

If you have an `.env` file under `docker/`, verify the passwords (e.g. `POSTGRES_PASSWORD`, `OS_PASS`).

### 2) Start the stack
```bash
cd docker
docker compose up -d
```

Wait a few seconds for all services to become ready.

### 3) (One-time) Download required Flink connector JARs
From the repo root:
```bash
bash scripts/get_flink_jars.sh
```

> The script places Kafka/OpenSearch/Redis connectors where the Flink SQL client can load them.

### 4) Register Kafka Connect connectors (Debezium + OpenSearch)
From the repo root:
```bash
bash scripts/register_connectors.sh
```

This script registers:
- **`pg-cdc`** – Debezium PostgreSQL CDC connector (source)
- **`os-views`** – OpenSearch sink connector for topic `views.orders_summary` (target index `views.orders_summary`)

> If you prefer HTTPS to OpenSearch with auth, adjust the script or use the provided `os-sink.json` template.

### 5) Submit Flink SQL job(s)
From the repo root:
```bash
bash scripts/sql_submit.sh
```
This submits the streaming job that aggregates order metrics per status (e.g., `delivered`, `cancelled`, `created`) and writes to the Kafka topic `views.orders_summary` which is then consumed by the OpenSearch sink.

---

## Verify the Pipeline

### Kafka Connect status
```bash
curl -s http://localhost:8083/connectors | jq .
curl -s http://localhost:8083/connectors/os-views/status | jq -r '.connector.state,.tasks[0].state'
```

### OpenSearch is up
```bash
curl -ksu admin:"$OS_PASS" https://localhost:9200 -I | head -n1
curl -ksu admin:"$OS_PASS" 'https://localhost:9200/_cat/indices?v'
```

You should see an index named `views.orders_summary`. To query:
```bash
curl -ksu admin:"$OS_PASS"   'https://localhost:9200/views.orders_summary/_search?size=10&pretty'
```

### Produce sample messages (optional)
```bash
docker compose exec -T connect bash -lc '
cat <<EOF | kafka-console-producer.sh --bootstrap-server kafka:9092   --topic views.orders_summary   --property parse.key=true --property key.separator=§
{"status":"delivered"}§{"status":"delivered","total_amount":157.24,"cnt":6}
{"status":"cancelled"}§{"status":"cancelled","total_amount":24.78,"cnt":3}
{"status":"created"}§{"status":"created","total_amount":61.68,"cnt":6}
EOF
'
```

### Reset consumer offsets (only when needed)
> Do this **only** when the sink connector is **paused** and you want it to re-read history.
```bash
# Pause connector
curl -s -X PUT http://localhost:8083/connectors/os-views/pause

# Reset offsets to earliest
docker compose exec -T connect bash -lc 'kafka-consumer-groups.sh --bootstrap-server kafka:9092  --group connect-os-views --reset-offsets --to-earliest  --topic views.orders_summary --execute'

# Resume connector
curl -s -X PUT http://localhost:8083/connectors/os-views/resume
```

---

## Tuning Notes

- **OpenSearch single-node:** set replicas to `0` to avoid `yellow` health on single-node dev:
```bash
curl -ksu admin:"$OS_PASS" -H 'Content-Type: application/json'   -X PUT 'https://localhost:9200/views.orders_summary/_settings'   -d '{"index":{"number_of_replicas":"0"}}'
```
- **Version conflicts:** if you set `key.ignore=false` and use upserts by document ID, consider
  `behavior.on.version.conflict=warn`.

---

## Tear Down
```bash
cd docker
docker compose down -v
```

---

## Roadmap

- Enrich features and write to **Redis** as an online feature store.
- Add **Delta Lake** sink job writing to S3 for offline analytics.
- Add Grafana dashboards & alerting for lag and connector health.

---

## License
Apache-2.0 license
