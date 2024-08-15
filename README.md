# Kickstart Azure Infrastructure Template

This repository contains an ARM template designed to kickstart a secure, scalable, and efficient infrastructure on Azure. The infrastructure includes a Static Web App, Azure App Service, Azure Function, Cosmos DB, Key Vault, Application Insights, and other essential components. This setup is designed with security, scalability, and monitoring in mind, making it an ideal starting point for production-grade applications.

## Features

- **Static Web App**: Serves static content with secure access through IP whitelisting and 2FA.
- **Azure App Service**: Hosts the main web application, secured with HTTPS only and Azure AD authentication.
- **Azure Function**: Handles backend processing with pay-as-you-go consumption plan, integrated with Service Bus and Cosmos DB.
- **Azure Cosmos DB**: Stores application data with session consistency and private endpoint access.
- **Azure Key Vault**: Manages secrets with secure access from the web app and function app.
- **Application Insights**: Provides monitoring and diagnostics for the App Service and Function App.
- **Network Security Groups (NSG)**: Applied to subnets for fine-grained access control.

## Infrastructure Diagram

### Overview Diagram

```mermaid
graph TD;
    User["User Accessing Web App"] -->|Whitelisted IP + 2FA| StaticWebApp["Static Web App: itdapp-prod-staticweb01"]
    StaticWebApp --> |HTTPS| WebApp["Azure App Service: itdapp-prod-app01"]
    WebApp --> |Secure Call| FunctionApp["Azure Function App: itdapp-prod-function01"]
    FunctionApp --> |Send Message| ServiceBus["Azure Service Bus Topic: itdapp-prod-sbnamespace"]
    FunctionApp --> |Write Data| CosmosDB["Azure Cosmos DB: itdapp-prod-cosmosdb01"]
    WebApp --> |Access Secrets| KeyVault["Azure Key Vault: itdapp-prod-keyvault01"]
    FunctionApp --> |Access Secrets| KeyVault
    CosmosDB --> |Data Storage| KeyVault
    FunctionApp --> |Monitoring| AppInsights["Azure Application Insights: itdapp-prod-appinsights01"]
    WebApp --> |Monitoring| AppInsights
    
    classDef azure fill:#0078D4,stroke:#ffffff,stroke-width:2px;
    class WebApp,FunctionApp,CosmosDB,ServiceBus,KeyVault,StaticWebApp,AppInsights azure;
```
![image](https://github.com/user-attachments/assets/2010f98b-c09b-4689-b64e-93e87308b9d4)


### Detailed Network and Security Diagram
```mermaid
graph TD
  A[User] --> |Internet Access| B[Static Web App: itdapp-prod-staticweb01]
  B --> |Whitelisted IP + 2FA| C[Azure App Service: itdapp-prod-app01]
  C --> |HTTPS Only| D[Azure Application Gateway: WAF Enabled]
  D --> |Web Tier Subnet| E[Azure Cosmos DB: itdapp-prod-cosmosdb01]
  C --> |Azure AD Authentication| F[App Insights: itdapp-prod-appinsights01]
  
  subgraph Web Security
    B --> |IP Restriction| G[NSG: Allow HTTP/HTTPS, Deny All Others]
    C --> |IP Restriction| H[NSG: Allow HTTP/HTTPS, Deny All Others]
  end

  subgraph Backend Security
    E --> |Private Endpoint| I[Private Subnet: No Public Access]
    E --> |Data Encryption| J[Azure Key Vault: itdapp-prod-keyvault01]
    J --> K[Audit Logs]
    C --> |Calls Function| O[Azure Function: itdapp-prod-function01]
    O --> P[Azure Service Bus: itdapp-prod-sbnamespace]
    O --> |Writes to| E
  end
  
  subgraph Network Security
    G --> L[Web Subnet: subnet-web]
    H --> M[App Subnet: subnet-app]
    E --> N[DB Subnet: subnet-db]
  end

  L -.-> |VNet Peering| N
  M -.-> |VNet Peering| N
```

![image](https://github.com/user-attachments/assets/39067d01-3f97-4c4d-bd65-48d74d9eb9ed)

### Detailed Explanation

#### 1. **Static Web App**
   - Serves static content, accessible only from whitelisted IP addresses and protected by 2FA.

#### 2. **Azure App Service**
   - Hosts the main web application. Secured with HTTPS and integrates with Azure AD for authentication.
   - Interacts with backend services like Azure Function and Cosmos DB.

#### 3. **Azure Function App**
   - Handles backend processing using a consumption plan. It processes messages from the Azure Service Bus and interacts with Cosmos DB for data storage.

#### 4. **Azure Cosmos DB**
   - Provides scalable, globally distributed database services with session consistency and secure access via private endpoints.

#### 5. **Azure Key Vault**
   - Manages sensitive information like connection strings and secrets, accessible only by the App Service and Function App.

#### 6. **Application Insights**
   - Integrated into both the Azure App Service and Azure Function App to provide real-time monitoring and diagnostics.

#### 7. **Network Security**
   - Network Security Groups (NSGs) are applied to control traffic at the subnet level, ensuring that only authorized traffic can access the resources.

## Getting Started

To deploy this template:

1. Clone this repository.
2. Customize the parameters in the ARM template if needed.
3. Deploy the template using Azure CLI, PowerShell, or the Azure Portal.

### Deployment Commands

Using Azure CLI:

```bash
az deployment group create --resource-group <your-resource-group> --template-file azuredeploy.json
```

Using PowerShell:
```bash
New-AzResourceGroupDeployment -ResourceGroupName <your-resource-group> -TemplateFile azuredeploy.json
```

### Contributing
If you'd like to contribute to this project, please submit a pull request or open an issue on GitHub.

### License
This project is licensed under the MIT License - see the LICENSE file for details.

