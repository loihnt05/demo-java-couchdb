#!/usr/bin/env bash
set -euo pipefail

COUCH_URL="${COUCH_URL:-http://localhost:5984}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
DB_NAME="${DB_NAME:-demo_multi_shape}"

request() {
  curl -sS -u "${COUCH_USER}:${COUCH_PASS}" "$@"
}

ensure_db() {
  request -X PUT "${COUCH_URL}/${DB_NAME}" >/dev/null || true
}

# Upsert keeps demo reruns deterministic without deleting the whole database.
upsert_doc() {
  local doc_id="$1"
  local body="$2"
  local existing rev payload

  existing="$(request "${COUCH_URL}/${DB_NAME}/${doc_id}")"
  rev="$(python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("_rev", ""))' <<<"${existing}" 2>/dev/null || true)"

  if [ -n "${rev}" ]; then
    payload="$(python3 -c 'import json,sys; b=json.loads(sys.argv[1]); b["_rev"]=sys.argv[2]; print(json.dumps(b,separators=(",",":")))' "${body}" "${rev}")"
  else
    payload="${body}"
  fi

  request -H "Content-Type: application/json" \
    -X PUT "${COUCH_URL}/${DB_NAME}/${doc_id}" \
    --data-binary "${payload}" >/dev/null
}

ensure_seed_docs() {
  upsert_doc "order_event_9001" '{"_id":"order_event_9001","type":"order_event","orderId":9001,"status":"created","amount":149.95,"currency":"USD","createdAt":"2026-03-30T10:00:00Z"}'
  upsert_doc "order_event_9002" '{"_id":"order_event_9002","type":"order_event","orderId":9002,"status":"created","amount":79.50,"currency":"USD","createdAt":"2026-03-30T10:45:00Z"}'
  upsert_doc "order_event_9003" '{"_id":"order_event_9003","type":"order_event","orderId":9003,"status":"paid","amount":219.00,"currency":"USD","createdAt":"2026-03-30T11:00:00Z"}'
}

ensure_index() {
  request -H "Content-Type: application/json" \
    -X POST "${COUCH_URL}/${DB_NAME}/_index" \
    --data-binary '{"index":{"fields":["type","status","createdAt"]},"name":"idx_type_status_createdAt","ddoc":"idx_type_status_createdAt","type":"json"}' >/dev/null

  request -H "Content-Type: application/json" \
    -X POST "${COUCH_URL}/${DB_NAME}/_index" \
    --data-binary '{"index":{"fields":["type","status"]},"name":"idx_type_status","ddoc":"idx_type_status","type":"json"}' >/dev/null
}

run_query() {
  local name="$1"
  local payload="$2"

  echo ""
  echo "== ${name} =="
  request -H "Content-Type: application/json" -X POST "${COUCH_URL}/${DB_NAME}/_find" --data-binary "${payload}" | \
    python3 -c 'import json,sys; data=json.load(sys.stdin); print(json.dumps(data, indent=2))'
}

echo "Running Mango JSON query demo on ${COUCH_URL}/${DB_NAME}"
ensure_db
ensure_seed_docs
ensure_index

run_query "Query 1: created order events (desc by createdAt)" '{"use_index":["idx_type_status_createdAt","idx_type_status_createdAt"],"selector":{"type":"order_event","status":"created","createdAt":{"$gte":null}},"sort":[{"createdAt":"desc"}],"fields":["_id","orderId","status","createdAt","amount"],"limit":10}'

run_query "Query 2: created events with createdAt >= 2026-03-30T10:30:00Z" '{"selector":{"type":"order_event","status":"created","createdAt":{"$gte":"2026-03-30T10:30:00Z"}},"sort":[{"createdAt":"asc"}],"fields":["_id","orderId","createdAt"],"limit":10}'

run_query "Query 3: multi-status using \$in" '{"selector":{"type":"order_event","status":{"$in":["created","paid"]}},"fields":["_id","status","amount"],"limit":20}'

echo ""
echo "Mango demo complete. Manual requests: demo/http/mango_query_demo.http"



