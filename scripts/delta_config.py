# Databricks notebook source
storageName = dbutils.secrets.get(scope="storage_account", key="storage_name")
spark.conf.set(f"fs.azure.account.key.{storageName}.blob.core.windows.net", dbutils.secrets.get(scope="storage_account", key="access_key"))

# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE SCHEMA IF NOT EXISTS silver LOCATION "wasbs://silver@${storageName}.blob.core.windows.net/";
# MAGIC CREATE SCHEMA IF NOT EXISTS gold LOCATION "wasbs://gold@${storageName}.blob.core.windows.net/";
