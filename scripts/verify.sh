#!/usr/bin/env bash
set -e
echo "Connectors:" && curl -s http://localhost:8083/connectors | jq .
echo "os-views status:" && curl -s http://localhost:8083/connectors/os-views/status | jq -r '.connector.state,.tasks[0].state' || true
