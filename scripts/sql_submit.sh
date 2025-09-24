#!/usr/bin/env bash
set -euo pipefail
docker compose -f docker/docker-compose.yml exec -T flink-jobmanager /opt/flink/bin/sql-client.sh -l /opt/flink/lib -f /opt/flink/sql/orders_summary.sql
