#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

SOURCE_URL="${SOURCE_URL:-http://localhost:5984}"
TARGET_URL="${TARGET_URL:-http://localhost:5985}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
SOURCE_DB="${SOURCE_DB:-demo_repl_source}"
TARGET_DB="${TARGET_DB:-demo_repl_target}"
RESET_DB="${RESET_DB:-true}"

DOC1_PATH="${ROOT_DIR}/demo/docs/doc_user_profile.json"
DOC2_PATH="${ROOT_DIR}/demo/docs/doc_order_event.json"

if [ ! -f "${DOC1_PATH}" ] || [ ! -f "${DOC2_PATH}" ]; then
  echo "Document JSON files are missing under ${ROOT_DIR}/demo/docs"
  exit 1
fi

echo "Preparing replication demo"
echo "- Source: ${SOURCE_URL}/${SOURCE_DB}"
echo "- Target: ${TARGET_URL}/${TARGET_DB}"

if [ "${RESET_DB}" = "true" ]; then
  curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X DELETE "${SOURCE_URL}/${SOURCE_DB}" >/dev/null || true
  curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X DELETE "${TARGET_URL}/${TARGET_DB}" >/dev/null || true
fi

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X PUT "${SOURCE_URL}/${SOURCE_DB}" >/dev/null || true
curl -sS -u "${COUCH_USER}:${COUCH_PASS}" -X PUT "${TARGET_URL}/${TARGET_DB}" >/dev/null || true

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X PUT "${SOURCE_URL}/${SOURCE_DB}/user_profile_001" \
  --data-binary "@${DOC1_PATH}" >/dev/null

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X PUT "${SOURCE_URL}/${SOURCE_DB}/order_event_9001" \
  --data-binary "@${DOC2_PATH}" >/dev/null

echo "Seeded source DB with 2 docs."

