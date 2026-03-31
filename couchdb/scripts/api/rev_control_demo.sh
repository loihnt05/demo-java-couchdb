#!/usr/bin/env bash
set -euo pipefail

COUCH_URL="${COUCH_URL:-http://localhost:5984}"
COUCH_USER="${COUCH_USER:-admin}"
COUCH_PASS="${COUCH_PASS:-admin}"
DB_NAME="${DB_NAME:-demo_multi_shape}"
DOC_ID="${DOC_ID:-rev_demo_001}"

request() {
  curl -sS -u "${COUCH_USER}:${COUCH_PASS}" "$@"
}

extract_json_field() {
  local json="$1"
  local field="$2"
  python3 -c 'import json,sys; data=json.load(sys.stdin); print(data.get(sys.argv[1], ""))' "${field}" <<<"${json}"
}

echo "Running _rev revision control demo against ${COUCH_URL}/${DB_NAME}/${DOC_ID}"

request -X PUT "${COUCH_URL}/${DB_NAME}" >/dev/null || true

create_resp="$(request -H "Content-Type: application/json" -X PUT "${COUCH_URL}/${DB_NAME}/${DOC_ID}" --data-binary '{"type":"rev_demo","step":1,"message":"initial write"}')"
rev1="$(extract_json_field "${create_resp}" rev)"

if [ -z "${rev1}" ]; then
  echo "Failed to create demo document. Response: ${create_resp}"
  exit 1
fi

echo "Created doc with _rev=${rev1}"

update_ok_resp="$(request -H "Content-Type: application/json" -X PUT "${COUCH_URL}/${DB_NAME}/${DOC_ID}?rev=${rev1}" --data-binary '{"type":"rev_demo","step":2,"message":"update with current _rev"}')"
rev2="$(extract_json_field "${update_ok_resp}" rev)"

if [ -z "${rev2}" ]; then
  echo "Expected successful update with current _rev. Response: ${update_ok_resp}"
  exit 1
fi

echo "Updated doc with current _rev, new _rev=${rev2}"

stale_body_file="$(mktemp)"
stale_status="$(curl -sS -o "${stale_body_file}" -w "%{http_code}" -u "${COUCH_USER}:${COUCH_PASS}" \
  -H "Content-Type: application/json" \
  -X PUT "${COUCH_URL}/${DB_NAME}/${DOC_ID}?rev=${rev1}" \
  --data-binary '{"type":"rev_demo","step":3,"message":"stale write should conflict"}')"

if [ "${stale_status}" != "409" ]; then
  stale_body="$(cat "${stale_body_file}")"
  rm -f "${stale_body_file}"
  echo "Expected 409 conflict for stale _rev, got ${stale_status}. Body: ${stale_body}"
  exit 1
fi

stale_body="$(cat "${stale_body_file}")"
rm -f "${stale_body_file}"

echo "Stale update returned 409 as expected: ${stale_body}"

latest_doc="$(request "${COUCH_URL}/${DB_NAME}/${DOC_ID}")"
latest_rev="$(extract_json_field "${latest_doc}" _rev)"

if [ -z "${latest_rev}" ]; then
  echo "Failed to read latest document revision. Response: ${latest_doc}"
  exit 1
fi

retry_resp="$(request -H "Content-Type: application/json" -X PUT "${COUCH_URL}/${DB_NAME}/${DOC_ID}?rev=${latest_rev}" --data-binary '{"type":"rev_demo","step":4,"message":"retry with fresh _rev succeeds"}')"
rev3="$(extract_json_field "${retry_resp}" rev)"

if [ -z "${rev3}" ]; then
  echo "Expected successful retry with latest _rev. Response: ${retry_resp}"
  exit 1
fi

echo "Retry with latest _rev succeeded, final _rev=${rev3}"
echo "Revision control demo complete."

