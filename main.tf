resource "random_string" "random" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg_databricks" {
  name     = "${var.rg_name}-${random_string.random.result}"
  location = var.rg_location
}

resource "azurerm_databricks_workspace" "workspace_databricks" {
  name                = "${var.databricks_name}-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg_databricks.name
  location            = azurerm_resource_group.rg_databricks.location
  sku                 = var.databricks_sku
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv_databricks" {
  name                = "${var.kv_name}-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg_databricks.name
  location            = azurerm_resource_group.rg_databricks.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Restore"]
    key_permissions    = ["Get", "List", "Create", "Delete"]
  }
}

resource "azurerm_key_vault_secret" "databricks_secret" {
  name = var.databricks_secret_name
  value = var.databricks_secret_value
  key_vault_id = azurerm_key_vault.kv_databricks.id
  depends_on = [ azurerm_key_vault.kv_databricks ]
}

data "azurerm_databricks_workspace" "name" {
  name = azurerm_databricks_workspace.workspace_databricks.name
  resource_group_name = azurerm_resource_group.rg_databricks.name
  //url = azurerm_databricks_workspace.workspace_databricks.workspace_url
}


resource "databricks_secret_scope" "databricks_secret" {
  name = "terraform-test-scope"
  initial_manage_principal = "users"
  keyvault_metadata {
    resource_id = azurerm_key_vault.kv_databricks.id
    dns_name = azurerm_key_vault.kv_databricks.vault_uri
  }
  depends_on = [ azurerm_databricks_workspace.workspace_databricks, azurerm_key_vault.kv_databricks ]
}