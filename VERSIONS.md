# Versions

Record the exact image tags you are running so others can reproduce.

| Component        | Image / Tag (from docker-compose.yml) | Notes |
|-----------------|----------------------------------------|-------|
| PostgreSQL      |                                        | logical decoding enabled |
| Debezium        |                                        | e.g. 3.2.2.Final |
| Kafka           |                                        | e.g. 4.0.0 |
| Kafka Connect   |                                        | same as Kafka |
| Flink           |                                        | e.g. 1.18.x |
| OpenSearch      |                                        | e.g. 2.x |
| Redis           |                                        | e.g. 7.x |
| Spark (optional)|                                        | e.g. 3.x |
