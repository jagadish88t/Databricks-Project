terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.89.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.35.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }

  backend "azurerm" {
    tenant_id = ""
    client_id = ""
    client_secret = ""
    subscription_id = ""

    resource_group_name = "Terraformfiles"
    storage_account_name = "tfstatefileslearning"
    container_name = "terraformstatefiles"
    key = "databricks.tfstate"
  }
}

provider "azurerm" {
  features {

  }
}

provider "databricks" {
  # Configuration options
  host = "https://${data.azurerm_databricks_workspace.databricks_data.workspace_url}/"
  # token = var.databricks_aadtoken
}

provider "random" {

}
