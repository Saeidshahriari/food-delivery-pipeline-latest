-- SOURCE
CREATE TABLE orders (
  id BIGINT,
  user_id BIGINT,
  status STRING,
  -- total را STRING می‌گیریم چون Debezium آن را به‌صورت رشته می‌فرستد
  total STRING,
  restaurant_id BIGINT,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'kafka',
  'topic' = 'dbz_v2.public.orders',
  'properties.bootstrap.servers' = 'kafka:9092',
  'scan.startup.mode' = 'earliest-offset',
  'value.format' = 'debezium-json',
  'value.debezium-json.ignore-parse-errors' = 'true',
  'value.debezium-json.schema-include' = 'false'
);

-- SINK
CREATE TABLE orders_summary_v2 (
  status STRING,
  cnt BIGINT,
  total_amount DECIMAL(10,2),
  PRIMARY KEY (status) NOT ENFORCED
) WITH (
  'connector' = 'upsert-kafka',
  'topic' = 'views.orders_summary_v2',
  'properties.bootstrap.servers' = 'kafka:9092',
  'key.format' = 'json',
  'value.format' = 'json'
);

-- AGG
INSERT INTO orders_summary_v2
SELECT
  status,
  COUNT(*) AS cnt,
  CAST(SUM(CAST(total AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS total_amount
FROM orders
GROUP BY status;
