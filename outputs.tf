output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.dpe_databricks.workspace_url}/"
}