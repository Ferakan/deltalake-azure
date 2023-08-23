resource "azurerm_resource_group" "dpe_rg" {
  name     = "dpe-rg"
  location = var.region
}

resource "azurerm_storage_account" "dpe_storage" {
  name                             = "${var.storage_name}"
  resource_group_name              = azurerm_resource_group.dpe_rg.name
  location                         = azurerm_resource_group.dpe_rg.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  account_kind                     = "StorageV2"
  cross_tenant_replication_enabled = false
  is_hns_enabled                   = true

  tags = {
    environment = "development"
  }
}

resource "azurerm_storage_container" "dpe_containers" {
  count                 = length(var.blob_prefix)
  name                  = "${var.blob_prefix[count.index]}"
  storage_account_name  = azurerm_storage_account.dpe_storage.name
  container_access_type = "container"
  
}

resource "azurerm_databricks_workspace" "dpe_databricks" {
  name                = "dpe-databricks"
  resource_group_name = azurerm_resource_group.dpe_rg.name
  location            = azurerm_resource_group.dpe_rg.location
  sku                 = "trial"

  tags = {
    environment = "development"
  }
}