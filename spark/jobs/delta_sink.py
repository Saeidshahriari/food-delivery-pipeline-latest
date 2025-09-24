import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StructType, StructField, LongType, DoubleType, StringType

bootstrap = os.getenv("KAFKA_BOOTSTRAP_SERVERS","kafka:9092")
bucket = os.getenv("MINIO_BUCKET","datalake")

spark = SparkSession.builder.appName("orders-summary-delta-sink").getOrCreate()

schema = StructType([
    StructField("restaurant_id", LongType()),
    StructField("order_count", LongType()),
    StructField("revenue", DoubleType()),
    StructField("last_update", StringType())
])

df = (spark.readStream.format("kafka")
      .option("kafka.bootstrap.servers", bootstrap)
      .option("subscribe", "views.orders_summary")
      .option("startingOffsets", "earliest")
      .load())

parsed = df.select(from_json(col("value").cast("string"), schema).alias("v")).select("v.*")

delta_path = f"s3a://{bucket}/orders_summary"
query = (parsed.writeStream
         .format("delta")
         .outputMode("append")
         .option("checkpointLocation", f"{delta_path}/_checkpoints")
         .start(delta_path))

query.awaitTermination()
