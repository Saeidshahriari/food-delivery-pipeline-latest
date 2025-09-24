#!/usr/bin/env bash
set -euo pipefail

if [ -f ./docker/.env ]; then source ./docker/.env; fi

sub() { sed -e "s#__OS_PASS__#${OS_PASS:-admin}#g" -e "s#__PG_PASS__#${PG_PASS:-password}#g"; }

echo ">> Apply pg-cdc"
curl -sS -X PUT http://localhost:8083/connectors/pg-cdc/config \
  -H 'Content-Type: application/json' \
  -d @<(cat connectors/pg-cdc.json | sub) | jq . || true

echo ">> Apply os-views"
curl -sS -X PUT http://localhost:8083/connectors/os-views/config \
  -H 'Content-Type: application/json' \
  -d @<(cat connectors/os-views.json | sub) | jq . || true
