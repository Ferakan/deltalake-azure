# Databricks notebook source
from delta.tables import *
from pyspark.sql import functions as F
from pyspark.sql import Window as w
from pyspark.sql.types import *

import time

# COMMAND ----------

spark.conf.set("fs.azure.account.key.dpestorage42.blob.core.windows.net", dbutils.secrets.get(scope="storage_account", key="access_key"))

# COMMAND ----------

decay_factor = 45000
score_weight = 1.8
awards_weight = 15
comments_weight = 5
age_weight = 30000

# COMMAND ----------

trending_posts_df = spark.sql(f"""
    SELECT *,
        (score * {score_weight}) +
        (upvote_ratio * {score_weight}) +
        (total_awards_received * {awards_weight}) +
        (num_comments * {comments_weight}) +
        ({age_weight} * pow(2.71828, -1 *(UNIX_TIMESTAMP() - UNIX_TIMESTAMP(created_at)) / {decay_factor})) AS hotness_score
    FROM silver.posts
    WHERE created_at >= date_sub(current_date(), 3)
    ORDER BY hotness_score DESC
""")

# COMMAND ----------

(
    trending_posts_df
    .write
    .format('delta')
    .mode('overwrite')
    .saveAsTable('gold.trending_posts')
)
