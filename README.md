# Azure Delta Lake

A personal project that aims to create a Delta Lakehouse platform using Azure and Databricks.

## Index

- [1. Objective](#1-objective)
- [2. Architecture](#2-architecture)
- [3. How it works?](#3-how-it-works)
- [4. What could be improved?](#4-what-could-be-improved)
- [5. Sources](#5-sources)

## 1. Objective


## 2. Architecture


## 3. How it works?


## 4. What could be improved?
Below are some ideas for improving the project.
- Partitioning the data on the containers. For example, in the Reddit data, the pathing would be something like this: 
```/silver/subreddit/post_creation_date/part0001-random-string.parquet```.

- Partition pruning on the ETL notebooks on Databricks to make the MERGE faster (without it Spark would scan the entire storage for each line it would update).


## 5. Sources
1. [Big Data Architecture on Azure](https://learn.microsoft.com/en-us/azure/architecture/solution-ideas/articles/azure-databricks-modern-analytics-architecture)

2. [Production-ize Databricks Notebooks](https://www.databricks.com/blog/2022/06/25/software-engineering-best-practices-with-databricks-notebooks.html)

3. [Data Integration with Databricks](https://medium.com/creative-data/data-integration-with-azure-databricks-f9ab3bb07dc)

4. [Connect to Storage Account from Databricks](https://docs.databricks.com/storage/azure-storage.html#language-Account%C2%A0key)

5. [CI/CD with Terraform](https://quileswest.medium.com/deploying-terraform-infrastructure-with-ci-cd-pipeline-34d5bb51689d)