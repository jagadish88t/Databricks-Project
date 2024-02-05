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
    tenant_id = "4a1c61bf-11d9-4bcc-8493-2d40bb0e45b7"
    client_id = "e21fc4cc-3424-40d2-af2d-b86dc784e727"
    client_secret = "23K8Q~JEv6lrnUYHvXiyJtnIvHIDXZQRTIklybmb"
    subscription_id = "63bd2eef-d99c-4b36-a3b0-b89c12000aa7"
    #$tenantId = "4a1c61bf-11d9-4bcc-8493-2d40bb0e45b7"
    #$clientId = "e21fc4cc-3424-40d2-af2d-b86dc784e727"
    #$clientSecret = "23K8Q~JEv6lrnUYHvXiyJtnIvHIDXZQRTIklybmb"

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
