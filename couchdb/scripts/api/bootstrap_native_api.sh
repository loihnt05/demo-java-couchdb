#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

COUCH_URL="${COUCH_URL:-http://localhost:5984}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
DB_NAME="${DB_NAME:-demo_multi_shape}"
RESET_DB="${RESET_DB:-true}"

SECURITY_PATH="${ROOT_DIR}/demo/security/security.json"
DESIGN_DOC_PATH="${ROOT_DIR}/demo/design/api_design_doc.json"
INDEX_PATH="${ROOT_DIR}/demo/indexes/order_event_status_index.json"

if [ ! -f "${SECURITY_PATH}" ] || [ ! -f "${DESIGN_DOC_PATH}" ] || [ ! -f "${INDEX_PATH}" ]; then
  echo "Missing API bootstrap files under ${ROOT_DIR}/demo"
  exit 1
fi

echo "Using CouchDB at ${COUCH_URL}"
echo "Bootstrapping native API database '${DB_NAME}'"

if [ "${RESET_DB}" = "true" ]; then
  curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X DELETE "${COUCH_URL}/${DB_NAME}" >/dev/null || true
fi

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X PUT "${COUCH_URL}/${DB_NAME}" >/dev/null || true

# Restrict DB members/admins at the database level for the demo API.
curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X PUT "${COUCH_URL}/${DB_NAME}/_security" \
  --data-binary "@${SECURITY_PATH}" >/dev/null

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X PUT "${COUCH_URL}/${DB_NAME}/_design/native_api" \
  --data-binary "@${DESIGN_DOC_PATH}" >/dev/null

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X POST "${COUCH_URL}/${DB_NAME}/_index" \
  --data-binary "@${INDEX_PATH}" >/dev/null

echo "Native DB API bootstrap complete."
echo "- DB: ${COUCH_URL}/${DB_NAME}"
echo "- View (by_type): ${COUCH_URL}/${DB_NAME}/_design/native_api/_view/by_type"
echo "- Query endpoint: ${COUCH_URL}/${DB_NAME}/_find"


