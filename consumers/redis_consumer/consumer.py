import json, os
from confluent_kafka import Consumer
import redis

bootstrap = os.getenv("KAFKA_BOOTSTRAP_SERVERS","kafka:9092")
topic = os.getenv("VIEWS_TOPIC","views.orders_summary")
r = redis.Redis(host=os.getenv("REDIS_HOST","redis"), port=6379, decode_responses=True)

c = Consumer({"bootstrap.servers": bootstrap,"group.id":"redis-consumer","auto.offset.reset":"earliest"})
c.subscribe([topic])
print("Redis consumer started")
while True:
    msg = c.poll(1.0)
    if not msg: continue
    if msg.error(): continue
    data = json.loads(msg.value().decode("utf-8"))
    key = f"fd:summary:{data['restaurant_id']}"
    r.hset(key, mapping={k:str(v) for k,v in data.items()})
