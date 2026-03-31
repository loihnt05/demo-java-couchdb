#!/usr/bin/env bash
set -euo pipefail

SOURCE_URL="${SOURCE_URL:-http://localhost:5984}"
TARGET_URL="${TARGET_URL:-http://localhost:5985}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
SOURCE_DB="${SOURCE_DB:-demo_repl_source}"
TARGET_DB="${TARGET_DB:-demo_repl_target}"
CONTINUOUS="${CONTINUOUS:-false}"
SOURCE_REPL_HOST="${SOURCE_REPL_HOST:-couchdb1:5984}"
TARGET_REPL_HOST="${TARGET_REPL_HOST:-couchdb2:5984}"

SOURCE_REPL_SPEC="${SOURCE_REPL_SPEC:-http://${COUCH_USER}:${COUCH_PASS}@${SOURCE_REPL_HOST}/${SOURCE_DB}}"
TARGET_REPL_SPEC="${TARGET_REPL_SPEC:-http://${COUCH_USER}:${COUCH_PASS}@${TARGET_REPL_HOST}/${TARGET_DB}}"

echo "Running replication"
echo "- source spec: ${SOURCE_REPL_SPEC}"
echo "- target spec: ${TARGET_REPL_SPEC}"
echo "- source node API: ${SOURCE_URL}"
echo "- target node API (host check): ${TARGET_URL}"

auth_payload=$(cat <<JSON
{
  "source": "${SOURCE_REPL_SPEC}",
  "target": "${TARGET_REPL_SPEC}",
  "create_target": true,
  "continuous": ${CONTINUOUS}
}
JSON
)

curl -sS -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X POST "${SOURCE_URL}/_replicate" \
  --data-binary "${auth_payload}" | cat

echo



