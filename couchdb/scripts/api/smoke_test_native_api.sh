#!/usr/bin/env bash
set -euo pipefail

COUCH_URL="${COUCH_URL:-http://localhost:5984}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
DB_NAME="${DB_NAME:-demo_multi_shape}"

echo "Checking CouchDB health..."
curl -sS "${COUCH_URL}/" | grep -q '"couchdb":"Welcome"'

echo "Checking database exists..."
curl -sS -u "${COUCH_USER}:${COUCH_PASS}" "${COUCH_URL}/${DB_NAME}" | grep -q '"db_name"'

echo "Checking seed documents are present..."
curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  "${COUCH_URL}/${DB_NAME}/_all_docs?include_docs=true" | grep -q "user_profile_001"

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X POST "${COUCH_URL}/${DB_NAME}/_find" \
  --data-binary '{"selector":{"type":"order_event","status":"created"},"limit":1}' | grep -q '"docs"'

echo "Smoke test passed: native API endpoints respond as expected."

