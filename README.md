# Azure Delta Lake

A personal project that aims to create a Delta Lake infrastructure using Azure and Databricks on the free tier plan.

## Index

- [1. Objectives](#1-objectives)
- [2. Architecture](#2-architecture)
- [3. Steps](#3-steps)
- [4. What could be improved?](#4-what-could-be-improved)
- [5. Sources](#5-sources)

## 1. Objectives
Creation of the infrastructure of a data lake in the Azure cloud by provisioning rousources with Terraform IaC.

Ingest Reddit topics data via API, ETL it into subsequent layers and then expose to BI and/or Data Viz tools.

## 2. Architecture
![project-architecture](./img/azure_diagram.png)



## 3. Steps

### 3.1 Terraform and Azure CLI
Install Terraform on the preffered OS following the instructions on this [documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

Install Azure CLI on your OS following the instructions on this [documentation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

You'll need an [Azure account](https://azure.microsoft.com/en-gb/free/search/) with credentials that allow you to create resources.

Once everything is installed, run the command `az login` and authorize with your account on the browser.

### 3.2 Creating Reddit App
Got to the [Reddit apps page](https://www.reddit.com/prefs/apps) and create a new app.

Give it a name, select the **script** option and complete the redirect uri with any that you want (can be http://localhost:8000).

Once it's created, copy the client_id (the one below the name of your app) and the secret. You'll need it for the deployment.

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