CREATE TABLE orders_cdc (
  before ROW<id BIGINT, user_id BIGINT, status STRING, total DOUBLE, restaurant_id BIGINT>,
  after ROW<id BIGINT, user_id BIGINT, status STRING, total DOUBLE, restaurant_id BIGINT>,
  `op` STRING METADATA FROM 'op' VIRTUAL,
  ts_ms TIMESTAMP_LTZ(3) METADATA FROM 'timestamp' VIRTUAL
) WITH (
  'connector' = 'kafka',
  'topic' = 'dbz.public.orders',
  'properties.bootstrap.servers' = 'kafka:9092',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'debezium-json'
);

CREATE VIEW orders AS
SELECT after.id AS id, after.user_id AS user_id, after.status AS status,
       after.total AS total, after.restaurant_id AS restaurant_id, ts_ms
FROM orders_cdc WHERE after IS NOT NULL;

CREATE VIEW order_summary AS
SELECT restaurant_id, COUNT(*) AS order_count, SUM(total) AS revenue,
       CAST(MAX(ts_ms) AS STRING) AS last_update
FROM orders GROUP BY restaurant_id;

CREATE TABLE orders_summary_kafka (
  restaurant_id BIGINT,
  order_count BIGINT,
  revenue DOUBLE,
  last_update STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'views.orders_summary',
  'properties.bootstrap.servers' = 'kafka:9092',
  'format' = 'json',
  'sink.partitioner' = 'fixed'
);

INSERT INTO orders_summary_kafka SELECT * FROM order_summary;
