provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name   = "var.resource_group_name"
    storage_account_name  = "var.storage-account-name"
    container_name        = "var.container-name"
    key                   = "terraform.tfstate"
  }
}