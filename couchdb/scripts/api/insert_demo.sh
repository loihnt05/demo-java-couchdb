#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

COUCH_URL="${COUCH_URL:-http://localhost:5984}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
DB_NAME="${DB_NAME:-demo_multi_shape}"
# Keep native API artifacts (indexes/design docs) unless caller explicitly asks to reset.
RESET_DB="${RESET_DB:-false}"

DOC1_PATH="${ROOT_DIR}/demo/docs/doc_user_profile.json"
DOC2_PATH="${ROOT_DIR}/demo/docs/doc_order_event.json"

if [ ! -f "${DOC1_PATH}" ] || [ ! -f "${DOC2_PATH}" ]; then
  echo "Document JSON files are missing under ${ROOT_DIR}/demo/docs"
  exit 1
fi

echo "Using CouchDB at ${COUCH_URL}"
echo "Preparing database '${DB_NAME}'"

if [ "${RESET_DB}" = "true" ]; then
  # Keep reruns deterministic by recreating the demo database.
  curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X DELETE "${COUCH_URL}/${DB_NAME}" >/dev/null || true
fi

# Create database if it does not already exist.
curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X PUT "${COUCH_URL}/${DB_NAME}" >/dev/null || true

echo "Inserting first document: $(basename "${DOC1_PATH}")"
curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X PUT "${COUCH_URL}/${DB_NAME}/user_profile_001" \
  --data-binary "@${DOC1_PATH}" | cat

echo
echo "Inserting second document: $(basename "${DOC2_PATH}")"
curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X PUT "${COUCH_URL}/${DB_NAME}/order_event_9001" \
  --data-binary "@${DOC2_PATH}" | cat

echo
echo "Done. Check all docs:"
echo "${COUCH_URL}/${DB_NAME}/_all_docs?include_docs=true"


