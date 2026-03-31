# Demo: CouchDB + Java

This repository contains two independent demos:

- `couchdb/`: CouchDB native REST API demo (DB = API), including Mango queries, `_rev` conflict handling, and replication.
- `java-demo/`: Java console demo for Student CRUD and Stream API (`filter`, `map`, `sorted`, `forEach`).

## Project Layout

```text
demo-jc/
  README.md
  couchdb/
  java-demo/
```

## Prerequisites

- Docker + Docker Compose (for `couchdb/` demo)
- Java 17+
- Maven 3.8+ (optional, but recommended for `java-demo/`)

## Quick Start: CouchDB Demo

From the repository root:

```bash
cd /home/loiancut/workspace/demo-jc/couchdb
docker compose up -d

chmod +x scripts/api/bootstrap_native_api.sh scripts/api/insert_demo.sh scripts/api/smoke_test_native_api.sh
./scripts/api/bootstrap_native_api.sh
./scripts/api/insert_demo.sh
./scripts/api/smoke_test_native_api.sh
```

Useful endpoints after startup:

- Fauxton UI: `http://localhost:5984/_utils/`
- CouchDB API base: `http://localhost:5984`

### Additional CouchDB Flows

Run Mango query demo:

```bash
cd /home/loiancut/workspace/demo-jc/couchdb
chmod +x scripts/api/mango_query_demo.sh
./scripts/api/mango_query_demo.sh
```

Run revision control (`_rev`) demo:

```bash
cd /home/loiancut/workspace/demo-jc/couchdb
chmod +x scripts/api/rev_control_demo.sh
./scripts/api/rev_control_demo.sh
```

Run replication demo (`couchdb1` -> `couchdb2`):

```bash
cd /home/loiancut/workspace/demo-jc/couchdb
chmod +x scripts/replica/bootstrap_replication_demo.sh scripts/replica/run_replication_demo.sh scripts/replica/validate_replication_demo.sh
./scripts/replica/bootstrap_replication_demo.sh
./scripts/replica/run_replication_demo.sh
./scripts/replica/validate_replication_demo.sh
```

## Quick Start: Java Demo

Using Maven:

```bash
cd /home/loiancut/workspace/demo-jc/java-demo
mvn -q test
mvn -q exec:java
```

Without Maven:

```bash
cd /home/loiancut/workspace/demo-jc/java-demo
mkdir -p out
javac -d out src/main/java/com/demo/student/*.java
java -cp out com.demo.student.Main
```

## Key Files

### CouchDB

- `couchdb/docker-compose.yml`
- `couchdb/demo/http/native_api.http`
- `couchdb/demo/http/mango_query_demo.http`
- `couchdb/demo/http/revision_control_demo.http`
- `couchdb/demo/http/replication_demo.http`

### Java

- `java-demo/src/main/java/com/demo/student/Main.java`
- `java-demo/src/main/java/com/demo/student/Student.java`
- `java-demo/src/main/java/com/demo/student/StudentService.java`
- `java-demo/src/test/java/com/demo/student/StudentServiceTest.java`

## Read More

- `couchdb/README.md`
- `java-demo/README.md`

