#!/usr/bin/env bash
set -euo pipefail

CONNECT_URL=${1:-http://localhost:8083}

echo "==> Checking available connector plugins..."
curl -sf "$CONNECT_URL/connector-plugins" | jq '.[].class' || true
echo

echo "==> Register / update Debezium Postgres (PUT /connectors/pg-cdc/config)"
curl -sf -X PUT "$CONNECT_URL/connectors/pg-cdc/config" \
  -H "Content-Type: application/json" \
  -d '{
    "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
    "database.hostname": "postgres",
    "database.port": "5432",
    "database.user": "food",
    "database.password": "foodpass",
    "database.dbname": "fooddb",
    "topic.prefix": "dbz",
    "publication.autocreate.mode": "filtered",
    "slot.name": "debezium",
    "plugin.name": "pgoutput",
    "tombstones.on.delete": "false",
    "decimal.handling.mode": "double",
    "snapshot.mode": "initial",
    "table.include.list": "public.orders,public.catalog"
  }' | jq .
echo

echo "==> Register / update OpenSearch sink (PUT /connectors/os-views/config)"
curl -sf -X PUT "$CONNECT_URL/connectors/os-views/config" \
  -H "Content-Type: application/json" \
  -d '{
    "connector.class": "io.aiven.kafka.connect.opensearch.OpensearchSinkConnector",
    "topics": "views.orders_summary",
    "connection.url": "http://opensearch:9200",
    "key.ignore": "true",
    "schema.ignore": "true",
    "behavior.on.null.values": "delete",
    "batch.size": "2000",
    "max.in.flight.requests": "5",
    "linger.ms": "1000",
    "flush.timeout.ms": "60000",
    "write.method": "index",
    "index": "orders-summary"
  }' | jq .
echo

echo "==> Done. Current connectors:"
curl -sf "$CONNECT_URL/connectors" | jq .
