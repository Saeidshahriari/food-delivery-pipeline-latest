import os, time, random, psycopg2
db_url = os.getenv("DATABASE_URL","postgresql://food:foodpass@localhost:5432/fooddb")
conn = psycopg2.connect(db_url); cur = conn.cursor()
cur.execute("CREATE TABLE IF NOT EXISTS orders (id BIGSERIAL PRIMARY KEY, user_id BIGINT, status TEXT, total NUMERIC(10,2), restaurant_id BIGINT);")
conn.commit()
statuses=["created","confirmed","delivered","cancelled"]
i=0
try:
    while True:
        cur.execute("INSERT INTO orders(user_id,status,total,restaurant_id) VALUES (%s,%s,%s,%s)",
                    (random.randint(1,1000), random.choice(statuses), round(random.uniform(10,80),2), random.randint(1,20)))
        conn.commit()
        i+=1
        if i%50==0: print("Inserted",i)
        time.sleep(0.3)
except KeyboardInterrupt:
    pass
finally:
    cur.close(); conn.close()
