# CouchDB Native REST API (DB = API)

Fauxton UI: http://localhost:5984/_utils/

This repo demonstrates a native REST API where CouchDB endpoints are your application API.

## Quick start

1. Start CouchDB:

```bash
docker compose up -d
```

2. Bootstrap the DB API (database, security, design doc, indexes):

```bash
chmod +x scripts/bootstrap_native_api.sh scripts/insert_demo.sh scripts/smoke_test_native_api.sh
./scripts/bootstrap_native_api.sh
```

3. Seed demo documents:

```bash
./scripts/insert_demo.sh
```

`insert_demo.sh` preserves DB indexes/design docs by default. To force DB recreation: `RESET_DB=true ./scripts/insert_demo.sh` (then re-run bootstrap).

4. Run a smoke test:

```bash
./scripts/smoke_test_native_api.sh
```

## Native API endpoints

- Read by id: `GET /demo_multi_shape/user_profile_001`
- Query (Mango): `POST /demo_multi_shape/_find`
- View query: `GET /demo_multi_shape/_design/native_api/_view/order_events_by_status`
- Change feed: `GET /demo_multi_shape/_changes`

Example `curl` query:

```bash
curl -u admin:admin \
  -H "Content-Type: application/json" \
  -X POST "http://localhost:5984/demo_multi_shape/_find" \
  --data-binary '{"use_index":["idx_type_status_createdAt","idx_type_status_createdAt"],"selector":{"type":"order_event","status":"created","createdAt":{"$gte":null}},"sort":[{"createdAt":"desc"}],"limit":10}'
```

## Files added for native API mode

- `scripts/bootstrap_native_api.sh`: create DB API artifacts
- `scripts/smoke_test_native_api.sh`: basic end-to-end checks
- `scripts/api/rev_control_demo.sh`: shows optimistic concurrency using `_rev`
- `scripts/api/mango_query_demo.sh`: seeds docs and runs Mango JSON queries
- `demo/design/api_design_doc.json`: view definitions
- `demo/indexes/order_event_status_index.json`: Mango index
- `demo/security/security.json`: database security object
- `demo/http/native_api.http`: ready-to-run request collection
- `demo/http/revision_control_demo.http`: stale-write conflict + retry walkthrough
- `demo/http/mango_query_demo.http`: Mango query examples for `_find` and `_explain`

## Query demo with JSON (Mango)

This demo executes `_find` queries using JSON selectors, sort, projection, and range filters.

Run the scripted flow:

```bash
chmod +x scripts/api/mango_query_demo.sh
./scripts/api/mango_query_demo.sh
```

Manual requests are available in `demo/http/mango_query_demo.http`.

## Revision control demo (`_rev`)

This demo shows CouchDB optimistic concurrency:

1. Create a document and capture its `_rev`.
2. Update the document with the current `_rev` (success).
3. Reuse the stale `_rev` in another update (`409 conflict`).
4. Read latest `_rev` and retry update (success).

Run the scripted flow:

```bash
chmod +x scripts/api/rev_control_demo.sh
./scripts/api/rev_control_demo.sh
```

Manual request sequence is available in `demo/http/revision_control_demo.http`.

## Replication demo (couchdb1 -> couchdb2)

This demo replicates two documents from `localhost:5984` to `localhost:5985` using CouchDB `_replicate`.

1. Make scripts executable and start services:

```bash
chmod +x scripts/bootstrap_replication_demo.sh scripts/run_replication_demo.sh scripts/validate_replication_demo.sh
docker compose up -d
```

2. Prepare source/target databases and seed source:

```bash
./scripts/bootstrap_replication_demo.sh
```

3. Run one-shot replication:

```bash
./scripts/run_replication_demo.sh
```

The replication payload is executed by CouchDB node 1 and uses explicit Docker-network endpoints by default:

- source: `http://admin:admin@couchdb1:5984/demo_repl_source`
- target: `http://admin:admin@couchdb2:5984/demo_repl_target`

Override with `SOURCE_REPL_HOST` / `TARGET_REPL_HOST` if your topology differs.

4. Validate replicated documents on target node:

```bash
./scripts/validate_replication_demo.sh
```

Optional: set `CONTINUOUS=true` with `run_replication_demo.sh` for continuous replication.

Manual HTTP requests are in `demo/http/replication_demo.http`.

