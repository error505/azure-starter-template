# GitHub Action for Deploying to Azure App Service

This folder contains the GitHub Action workflow file for deploying to an Azure App Service. The workflow file should be placed in the `.github/workflows/` directory with the name `azure-webapps-dotnet-core.yml`.

To use this GitHub Action, you need to create a service principal in Azure with the following commands:

```bash
az login
az ad sp create-for-rbac --name "my-github-action-sp" --sdk-auth --role contributor --scopes /subscriptions/<your-subscription-id>
```

All other secrets should be created in GitHub in order to be configured for your Azure Web App

This README explains that the workflow file for deploying to Azure App Service should be placed in the `.github/workflows/` directory with the name `azure-webapps-dotnet-core.yml`. It also provides the steps to create a service principal in Azure using the Azure CLI, and instructs the user to store the output as a GitHub Secret named `AZURE_CREDENTIALS`. This secret will be used by the GitHub Action to authenticate and deploy the application to the Azure App Service.
