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
    
  }
}

provider "azurerm" {
  features {

  }
}

provider "databricks" {
  # Configuration options
  #host = "https://${data.azurerm_databricks_workspace.databricks_data.workspace_url}/"
  # token = var.databricks_aadtoken
}

provider "random" {

}
