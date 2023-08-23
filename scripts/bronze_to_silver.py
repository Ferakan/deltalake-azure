# Databricks notebook source
from delta.tables import *
from pyspark.sql import functions as F
from pyspark.sql import Window as w
from pyspark.sql.types import *

# COMMAND ----------

spark.conf.set("fs.azure.account.key.dpestorage42.blob.core.windows.net", dbutils.secrets.get(scope="storage_account", key="access_key"))

# COMMAND ----------

bronze_path = "wasbs://bronze@dpestorage42.blob.core.windows.net/"
silver_path = "wasbs://silver@dpestorage42.blob.core.windows.net/"

# COMMAND ----------

df = (
    spark
    .read
    .format("json")
    .option("path", bronze_path)
    .load()
)

# COMMAND ----------

df_silver = df.select(
    F.to_timestamp(F.from_unixtime("created_utc", "yyyy-MM-dd HH:mm:ss")).alias("created_at"),
    F.to_timestamp(F.from_unixtime("extracted_at", "yyyy-MM-dd HH:mm:ss")).alias("extracted_at"),
    "subreddit",
    "id",
    "title",
    "total_awards_received",
    "num_comments",
    "ups",
    "downs",
    "score",
    "upvote_ratio"
)


# COMMAND ----------

if DeltaTable.isDeltaTable(spark, f'{silver_path}posts'):
    print("Table found")

    delta_table = DeltaTable.forName(spark, 'silver.posts')

    (
        delta_table.alias('target') 
        .merge(
            df_silver.alias('updates'),
            """target.id = updates.id
            AND target.extracted_at <= updates.extracted_at"""
        ) 
        .whenMatchedUpdate(set =
            {
            "id": "updates.id",
            "extracted_at": "updates.extracted_at",
            "total_awards_received": "updates.total_awards_received",
            "num_comments": "updates.num_comments",
            "ups": "updates.ups",
            "downs": "updates.downs",
            "score": "updates.score",
            "upvote_ratio": "updates.upvote_ratio"
            }
        ) 
        .whenNotMatchedInsertAll() 
        .execute()
    )

    print("Table updated")

else:
    print("Table NOT found")

    (
        df_silver
        .write
        .format('delta')
        .saveAsTable('silver.posts')
    )

    print("Table created")
