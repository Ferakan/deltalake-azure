# Databricks notebook source
spark.conf.set("fs.azure.account.key.dpestorage42.blob.core.windows.net", dbutils.secrets.get(scope="storage_account", key="access_key"))

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE SCHEMA IF NOT EXISTS silver LOCATION "wasbs://silver@dpestorage42.blob.core.windows.net/";
# MAGIC CREATE SCHEMA IF NOT EXISTS gold LOCATION "wasbs://gold@dpestorage42.blob.core.windows.net/";
