from fastapi import FastAPI
import os, psycopg2
from pydantic import BaseModel

DATABASE_URL = os.getenv("DATABASE_URL","postgresql://food:foodpass@postgres:5432/fooddb")
conn = psycopg2.connect(DATABASE_URL)
cur = conn.cursor()
cur.execute("CREATE TABLE IF NOT EXISTS catalog (id BIGSERIAL PRIMARY KEY, name TEXT, price NUMERIC(10,2));")
cur.execute("CREATE TABLE IF NOT EXISTS orders (id BIGSERIAL PRIMARY KEY, user_id BIGINT, status TEXT, total NUMERIC(10,2), restaurant_id BIGINT);")
conn.commit()

class OrderIn(BaseModel):
    user_id: int
    status: str = "created"
    total: float
    restaurant_id: int

app = FastAPI()

@app.get("/health")
def health(): return {"status":"ok"}

@app.get("/catalog")
def catalog():
    cur.execute("SELECT id,name,price FROM catalog ORDER BY id LIMIT 100;")
    return [{"id":r[0],"name":r[1],"price":float(r[2])} for r in cur.fetchall()]

@app.post("/orders")
def create(order: OrderIn):
    cur.execute("INSERT INTO orders(user_id,status,total,restaurant_id) VALUES(%s,%s,%s,%s) RETURNING id",
                (order.user_id,order.status,order.total,order.restaurant_id))
    oid = cur.fetchone()[0]; conn.commit(); return {"id":oid, **order.model_dump()}
