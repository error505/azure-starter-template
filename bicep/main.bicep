param aadClientId string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'itdapp-prod-vnet01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-web'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'subnet-app'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'subnet-db'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
      {
        name: 'subnet-func'
        properties: {
          addressPrefix: '10.0.4.0/24'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'itdapp-prod-nsg01'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'AllowHTTP'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'AllowHTTPS'
        properties: {
          priority: 1100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          priority: 2000
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource asp 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'itdapp-prod-asp01'
  location: resourceGroup().location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource func 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'itdapp-prod-aspfunc01'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'itdapp-prod-appinsights01'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'itdapp-prod-keyvault02'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
  }
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'itdapp-prod-sbnamespace'
  location: 'westeurope'
  sku: {
    name: 'Standard'
  }
  properties: {}
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
  parent: serviceBusNamespace
  name: 'itdapp-prod-topic01'
  properties: {}
}

resource webApp 'Microsoft.Web/sites@2021-01-15' = {
  name: 'itdapp-prod-app01'
  location: resourceGroup().location
  properties: {
    serverFarmId: asp.id
    httpsOnly: true
    siteConfig: {
      ipSecurityRestrictions: [
        {
          ipAddress: '192.168.1.0/24'
          action: 'Allow'
          tag: 'Default'
          priority: 100
          name: 'AllowSubnet'
        }
        {
          ipAddress: '0.0.0.0/0'
          action: 'Deny'
          priority: 200
          name: 'DenyAll'
        }
      ]
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'SERVICE_BUS_CONNECTION_STRING'
          value: listKeys(serviceBusNamespace.name, 'RootManageSharedAccessKey').primaryConnectionString
        }
        {
          name: 'KEY_VAULT_URI'
          value: keyVault.properties.vaultUri
        }
      ]
    }
  }
}

resource appAuthConfig 'Microsoft.Web/sites/config@2021-01-15' = {
  parent: webApp
  name: 'authsettingsV2'
  properties: {
    platform: {
      enabled: true
      runtimeVersion: '~3'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: aadClientId
          clientSecretSettingName: 'AADClientSecret'
        }
        login: {
          loginParameters: [
            'response_type=code id_token'
            'scope=openid profile email'
          ]
          disableWWWAuthenticate: false
        }
      }
    }
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
    }
    login: {
      preserveUrlFragmentsForLogins: true
    }
  }
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: 'itdapp-prod-cosmosdb01'
  location: resourceGroup().location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: resourceGroup().location
        failoverPriority: 0
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
  }
}

resource staticWebApp 'Microsoft.Web/staticSites@2021-02-01' = {
  name: 'itdapp-prod-staticweb01'
  location: 'westeurope'
  properties: {
    repositoryUrl: 'https://github.com/your-repo/your-repo.git'
    branch: 'main'
    repositoryToken: 'repo-token'
  }
  sku: {
    name: 'Free'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: 'itdappprodstorage01'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: 'itdapp-prod-function01'
  location: resourceGroup().location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: func.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'SERVICE_BUS_CONNECTION_STRING'
          value: listKeys(serviceBusNamespace.id, 'RootManageSharedAccessKey').primaryConnectionString
        }
        {
          name: 'COSMOS_DB_CONNECTION_STRING'
          value: cosmosDb.listKeys().primaryMasterKey
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
