terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.61.0"
    }
    databricks = {
      source = "databricks/databricks"
      version = "1.5.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "databricks" {
  host = azurerm_databricks_workspace.dpe_databricks.workspace_url
}