terraform {
  required_version = ">=0.12"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = var.subscription_id #d72a06ed-d984-410d-bd0d-af6a4ca4ceaa
  tenant_id       = var.tenant_id       #14cbd5a7-ec94-46ba-b314-cc0fc972a161
  client_id       = var.client_id       #3bb5c803-c989-44a1-8ca2-0c2832a3f580
  client_secret   = var.client_secret   #
}
