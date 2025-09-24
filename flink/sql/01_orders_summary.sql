CREATE TABLE orders (
  id BIGINT,
  user_id BIGINT,
  status STRING,
  total DECIMAL(10,2),
  restaurant_id BIGINT,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'kafka',
  'topic' = 'dbz2.public.orders',
  'properties.bootstrap.servers' = 'kafka:9092',
  'scan.startup.mode' = 'earliest-offset',
  'value.format' = 'debezium-json',
  'debezium-json.ignore-parse-errors' = 'true'
);

CREATE TABLE orders_summary (
  status STRING,
  cnt BIGINT,
  total_amount DECIMAL(10,2),
  PRIMARY KEY (status) NOT ENFORCED
) WITH (
  'connector' = 'upsert-kafka',
  'topic' = 'views.orders_summary',
  'properties.bootstrap.servers' = 'kafka:9092',
  'key.format' = 'json',
  'value.format' = 'json'
);

INSERT INTO orders_summary
SELECT
  status,
  COUNT(*) AS cnt,
  CAST(SUM(total) AS DECIMAL(10,2))
FROM orders
GROUP BY status;
