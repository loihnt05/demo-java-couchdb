#!/usr/bin/env bash
set -euo pipefail

SOURCE_URL="${SOURCE_URL:-http://localhost:5984}"
TARGET_URL="${TARGET_URL:-http://localhost:5985}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
SOURCE_DB="${SOURCE_DB:-demo_repl_source}"
TARGET_DB="${TARGET_DB:-demo_repl_target}"

echo "Validating replication result..."

source_docs=$(curl -sS -u "${COUCH_USER}:${COUCH_PASS}" "${SOURCE_URL}/${SOURCE_DB}/_all_docs")
target_docs=$(curl -sS -u "${COUCH_USER}:${COUCH_PASS}" "${TARGET_URL}/${TARGET_DB}/_all_docs")

echo "Source IDs:"
echo "${source_docs}" | grep -o '"id":"[^"]*"' | cat

echo "Target IDs:"
echo "${target_docs}" | grep -o '"id":"[^"]*"' | cat

echo "Checking required documents..."
echo "${target_docs}" | grep -q '"id":"user_profile_001"'
echo "${target_docs}" | grep -q '"id":"order_event_9001"'

echo "Replication demo validated: target contains replicated docs."

