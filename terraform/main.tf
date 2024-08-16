provider "azurerm" {
  features = {}
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the resources will be created."
}

variable "location" {
  type        = string
  description = "The location/region where the resources will be created."
}

variable "aad_client_id" {
  type        = string
  description = "Azure AD Application Client ID."
}

resource "azurerm_virtual_network" "vnet" {
  name                = "itdapp-prod-vnet01"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "subnet-web"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet-app"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "subnet-db"
    address_prefix = "10.0.3.0/24"
  }

  subnet {
    name           = "subnet-func"
    address_prefix = "10.0.4.0/24"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "itdapp-prod-nsg01"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_app_service_plan" "asp" {
  name                = "itdapp-prod-asp01"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FunctionApp"
  reserved            = false

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_application_insights" "appinsights" {
  name                = "itdapp-prod-appinsights01"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_key_vault" "keyvault" {
  name                = "itdapp-prod-keyvault01"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  soft_delete_enabled = true
  enabled_for_disk_encryption = true
  enabled_for_deployment = true
  enabled_for_template_deployment = true
}

resource "azurerm_servicebus_namespace" "servicebus" {
  name                = "itdapp-prod-sbnamespace"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku = "Standard"
}

resource "azurerm_servicebus_topic" "topic" {
  name                = "itdapp-prod-topic01"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.servicebus.name
}

resource "azurerm_app_service" "app" {
  name                = "itdapp-prod-app01"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    always_on = true
    https_only = true

    ip_restriction {
      ip_address = "192.168.1.0/24"
      action     = "Allow"
      name       = "AllowSubnet"
    }

    ip_restriction {
      ip_address = "0.0.0.0/0"
      action     = "Deny"
      name       = "DenyAll"
    }
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"   = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
    "SERVICE_BUS_CONNECTION_STRING"    = azurerm_servicebus_namespace.servicebus.default_primary_connection_string
    "KEY_VAULT_URI"                    = azurerm_key_vault.keyvault.vault_uri
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_app_service_auth_settings_v2" "authsettings" {
  name               = azurerm_app_service.app.name
  resource_group_name = var.resource_group_name

  global_validation {
    require_authentication = true
    unauthenticated_client_action = "RedirectToLoginPage"
  }

  platform {
    enabled = true
    runtime_version = "~3"
  }

  identity_providers {
    azure_active_directory {
      enabled = true

      registration {
        client_id = var.aad_client_id
        client_secret_setting_name = "AADClientSecret"
      }

      login {
        login_parameters = [
          "response_type=code id_token",
          "scope=openid profile email"
        ]
        disable_www_authenticate = false
      }
    }
  }
}

resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "itdapp-prod-cosmosdb01"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_static_site" "staticsite" {
  name                = "itdapp-prod-staticweb01"
  location            = var.location
  resource_group_name = var.resource_group_name

  repository_url      = "https://github.com/your-repo/your-remo.git"
  branch              = "main"
  repository_token    = "repo-token"
  app_location        = "/"
  api_location        = "api"
  output_location     = "build"
}

resource "azurerm_storage_account" "storage" {
  name                = "itdappprodstorage01"
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "functionapp" {
  name                = "itdapp-prod-function01"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id
  storage_account_name = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  app_settings = {
    "AzureWebJobsStorage"                = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.storage.name};AccountKey=${azurerm_storage_account.storage.primary_access_key};EndpointSuffix=${azurerm_storage_account.storage.primary_blob_host}"
    "FUNCTIONS_WORKER_RUNTIME"           = "dotnet"
    "SERVICE_BUS_CONNECTION_STRING"      = azurerm_servicebus_namespace.servicebus.default_primary_connection_string
    "COSMOS_DB_CONNECTION_STRING"        = azurerm_cosmosdb_account.cosmosdb.primary_master_key
    "APPINSIGHTS_INSTRUMENTATIONKEY"     = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsights.connection_string
  }

  identity {
    type = "SystemAssigned"
  }
}
