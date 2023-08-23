#CLUSTER
resource "databricks_cluster" "dpe_single_node" {
  cluster_name            = "DPE Single Node"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 30
  num_workers             = 0
  data_security_mode      = "NONE"

  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

# SECRETS
resource "databricks_secret_scope" "storage_account_ss" {
  name = "storage_account"

  depends_on = [azurerm_databricks_workspace.dpe_databricks]

}

resource "databricks_secret_scope" "reddit_ss" {
  name = "reddit"

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

resource "databricks_secret_acl" "storage_acl" {
  principal  = "users"
  permission = "READ"
  scope      = databricks_secret_scope.storage_account_ss.name

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

resource "databricks_secret_acl" "reddit_acl" {
  principal  = "users"
  permission = "READ"
  scope      = databricks_secret_scope.reddit_ss.name

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

resource "databricks_secret" "storage_name" {
  key = "storage_name"
  string_value = "${var.storage_name}"
  scope        = databricks_secret_scope.storage_account_ss.name

  depends_on = [
    azurerm_databricks_workspace.dpe_databricks,
    azurerm_storage_account.dpe_storage
  ]
}

resource "databricks_secret" "access_key_secret" {
  key = "access_key"
  string_value = azurerm_storage_account.dpe_storage.primary_access_key
  scope        = databricks_secret_scope.storage_account_ss.name

  depends_on = [
    azurerm_databricks_workspace.dpe_databricks,
    azurerm_storage_account.dpe_storage
  ]
}

resource "databricks_secret" "conn_string_secret" {
  key = "conn_string"
  string_value = azurerm_storage_account.dpe_storage.primary_connection_string
  scope        = databricks_secret_scope.storage_account_ss.name

  depends_on = [
    azurerm_databricks_workspace.dpe_databricks,
    azurerm_storage_account.dpe_storage
  ]
}

resource "databricks_secret" "reddit_client_id" {
  key = "client_id"
  string_value = var.reddit_client_id
  scope        = databricks_secret_scope.reddit_ss.name

  depends_on = [
    azurerm_databricks_workspace.dpe_databricks,
    azurerm_storage_account.dpe_storage
  ]
}

resource "databricks_secret" "reddit_client_secret" {
  key = "client_secret"
  string_value = var.reddit_client_secret
  scope        = databricks_secret_scope.reddit_ss.name

  depends_on = [
    azurerm_databricks_workspace.dpe_databricks,
    azurerm_storage_account.dpe_storage
  ]
}

# NOTEBOOKS
resource "databricks_notebook" "reddit_batch" {
  source = "../scripts/reddit_batch.py"
  path   = "/reddit_batch"

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

resource "databricks_notebook" "delta_config" {
  source = "../scripts/delta_config.py"
  path   = "/delta_config"

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

resource "databricks_notebook" "bronze_to_silver" {
  source = "../scripts/bronze_to_silver.py"
  path   = "/bronze_to_silver"

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

resource "databricks_notebook" "silver_to_gold" {
  source = "../scripts/silver_to_gold.py"
  path   = "/silver_to_gold"

  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

# WORKFLOW
resource "databricks_job" "dpe_workflow" {
  name = "Reddit pipeline"

  schedule {
    quartz_cron_expression = "0 0 1 * * ?"
    timezone_id            = "UTC"
  }

  task {
    task_key = "delta_config"

    existing_cluster_id = databricks_cluster.dpe_single_node.id

    notebook_task {
      notebook_path = databricks_notebook.delta_config.path
    }
  }

  task {
    task_key = "ingestion"

    depends_on {
      task_key = "delta_config"
    }

    existing_cluster_id = databricks_cluster.dpe_single_node.id

    notebook_task {
      notebook_path = databricks_notebook.reddit_batch.path
    }
  }

  task {
    task_key = "bronze_to_silver"
 
    depends_on {
      task_key = "ingestion"
    }

    existing_cluster_id = databricks_cluster.dpe_single_node.id

    notebook_task {
      notebook_path = databricks_notebook.bronze_to_silver.path
    }
  }

  task {
    task_key = "silver_to_gold"
    
    depends_on {
      task_key = "bronze_to_silver"
    }

    existing_cluster_id = databricks_cluster.dpe_single_node.id

    notebook_task {
      notebook_path = databricks_notebook.silver_to_gold.path
    }
  }

  depends_on = [
    databricks_cluster.dpe_single_node,
    databricks_notebook.delta_config,
    databricks_notebook.reddit_batch,
    databricks_notebook.bronze_to_silver,
    databricks_notebook.silver_to_gold
  ]
}