#!/usr/bin/env bash
set -euo pipefail
mkdir -p flink/lib
curl -fsSL -o flink/lib/flink-sql-connector-kafka-3.4.0-1.20.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.4.0-1.20/flink-sql-connector-kafka-3.4.0-1.20.jar
curl -fsSL -o flink/lib/flink-json-1.20.2.jar https://repo1.maven.org/maven2/org/apache/flink/flink-json/1.20.2/flink-json-1.20.2.jar
curl -fsSL -o flink/lib/flink-sql-connector-elasticsearch7-3.1.0-1.20.jar https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch7/3.1.0-1.20/flink-sql-connector-elasticsearch7-3.1.0-1.20.jar
echo "Downloaded Flink connector jars to ./flink/lib"
