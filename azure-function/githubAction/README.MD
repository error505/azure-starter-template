# Azure Function Deployment with GitHub Actions

This repository contains a GitHub Action workflow to deploy an Azure Function App to Azure using GitHub Actions. This guide will walk you through the necessary steps to configure your Azure resources and GitHub repository.

## Prerequisites

Before you begin, you will need the following:
1. **Azure Subscription**: You must have an active Azure subscription.
2. **Azure Function App**: An Azure Function App created in the Azure Portal.
3. **Azure Cosmos DB**: A Cosmos DB account set up in the Azure Portal.
4. **Azure Service Bus**: A Service Bus namespace and a topic with a subscription created.
5. **GitHub Repository**: A GitHub repository where your Azure Function code is hosted.

## Steps to Set Up

### 1. Download the Publish Profile

1. Go to the [Azure Portal](https://portal.azure.com/).
2. Navigate to your Azure Function App.
3. In the left-hand menu, under **Deployment**, select **Get Publish Profile**.
4. This will download a `.publishsettings` file. Open this file in a text editor and copy its content.

### 2. Add Secrets to GitHub Repository

1. Go to your GitHub repository.
2. Click on **Settings**.
3. In the left-hand menu, select **Secrets and variables** > **Actions** > **New repository secret**.
4. Add the following secrets:

| Secret Name                       | Value Description                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------------|
| `AZURE_CREDENTIALS`               | The content of your `.publishsettings` file you downloaded.                        |
| `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`| The publish profile content from the Azure Function App (same as `AZURE_CREDENTIALS`). |
| `AZURE_WEBJOBS_STORAGE`           | Azure Storage connection string. Find it in the Storage Account > Access keys.      |
| `ServiceBusConnectionString`      | Connection string for your Service Bus. Found in Service Bus > Shared access policies. |
| `CosmosDBConnectionString`        | Connection string for Cosmos DB. Found in Cosmos DB > Keys.                        |
| `CosmosDBDatabaseId`              | The database ID for your Cosmos DB.                                                |
| `CosmosDBContainerId`             | The container ID within the database in Cosmos DB.                                 |
| `BlobContainerName`               | The name of your blob container in Azure Storage.                                  |
| `ServiceBusTopicName`             | The name of your Service Bus topic.                                                |
| `ServiceBusSubscriptionName`      | The name of your Service Bus subscription.                                         |

### 3. Update the GitHub Action Workflow

Ensure that the `.yml` file for the GitHub Action in your repository is configured as shown in this repository. You can find it under `.github/workflows/` and it should be named something like `deploy-azure-function.yml`.

### 4. Push Changes to GitHub

Once your secrets are added and your workflow is configured:

1. Commit and push your code to the `main` branch (or the branch you configured in the workflow).
2. This will trigger the GitHub Action and deploy your Azure Function to the Azure Function App.

### 5. Monitor the Deployment

1. You can monitor the deployment process in the **Actions** tab of your GitHub repository.
2. Once the deployment is successful, your Azure Function should be live and accessible in Azure.

### 6. Verify the Deployment

1. Go to the Azure Portal.
2. Navigate to your Azure Function App.
3. Check the **Logs** and **Application Settings** to verify that the environment variables are set correctly.

### 7. Testing Your Azure Function

Once deployed, you can test your Azure Function:

1. Navigate to the URL of your Azure Function App.
2. Ensure it is running as expected and processing messages from the Service Bus and interacting with Cosmos DB.
