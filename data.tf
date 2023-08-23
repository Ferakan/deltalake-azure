data "databricks_current_user" "me" {
  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}

data "databricks_node_type" "smallest" {
  local_disk = true
  category   = "Standart_F4"
  depends_on = [azurerm_databricks_workspace.dpe_databricks]
}