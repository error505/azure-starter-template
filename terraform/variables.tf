variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the resources will be created."
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account where the state will be stored."
}

variable "container_name" {
  type        = string
  description = "The name of the storage container to store the tfstate file."
}

variable "location" {
  type        = string
  description = "The location/region where the resources will be created."
}

variable "aad_client_id" {
  type        = string
  description = "Azure AD Application Client ID."
}