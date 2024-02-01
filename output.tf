
output "databricks_workspace_url" {
  value = data.azurerm_databricks_workspace.name.workspace_url
}


output "workspace_url" {
  value = azurerm_databricks_workspace.workspace_databricks.workspace_url
}