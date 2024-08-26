# GitHub Action for Deploying to Azure App Service

This folder contains the GitHub Action workflow file for deploying to an Azure App Service. The workflow file should be placed in the `.github/workflows/` directory with the name `azure-webapps-dotnet-core.yml`.

To use this GitHub Action, you need to create a service principal in Azure with the following commands:

```bash
az login
az ad sp create-for-rbac --name "my-github-action-sp" --sdk-auth --role contributor --scopes /subscriptions/<your-subscription-id>
```

All other secrets should be created in GitHub in order to be configured for your Azure Web App

This README explains that the workflow file for deploying to Azure App Service should be placed in the `.github/workflows/` directory with the name `azure-webapps-dotnet-core.yml`. It also provides the steps to create a service principal in Azure using the Azure CLI, and instructs the user to store the output as a GitHub Secret named `AZURE_CREDENTIALS`. This secret will be used by the GitHub Action to authenticate and deploy the application to the Azure App Service.

# Deploy ASP.NET Core App to Azure App Service Using GitHub Actions

This repository contains a GitHub Action workflow that automatically builds and deploys an ASP.NET Core web application to Azure App Service when changes are pushed to the `main` branch.

## Prerequisites

Before you begin, ensure that you have the following set up in Azure and GitHub:

### 1. Azure Setup

#### **1.1. Create an Azure App Service**
- In the Azure Portal, create a new App Service in your desired Resource Group and Region.

#### **1.2. Create a Storage Account**
- This is needed if your app requires Azure Storage (for example, if you're using Blob Storage).

#### **1.3. Create an Azure Service Bus**
- Set up a Service Bus namespace and create a topic and subscription.

### 2. Azure AD App Registration Setup

In order to enable authentication in your app, you'll need to set up an Azure Active Directory (AAD) App Registration.

#### **2.1. Create an App Registration**
1. Navigate to **Azure Active Directory** in the Azure Portal.
2. Under **App registrations**, click **New registration**.
3. Fill in the following:
   - **Name**: Choose a name for your app registration.
   - **Supported account types**: Choose the appropriate option based on your application needs.
   - **Redirect URI**: Add `https://your-app-name.azurewebsites.net/signin-oidc`.

4. Click **Register**.

#### **2.2. Configure API Permissions**
1. In your App Registration, go to **API permissions**.
2. Click **Add a permission** > **APIs my organization uses**.
3. Search for your API or Microsoft Graph, and select the permissions your app requires (e.g., `User.Read`).
4. Click **Grant admin consent** for the API permissions.

#### **2.3. Configure Expose an API**
1. Go to **Expose an API**.
2. Click **Set** under **Application ID URI** and set it to `api://<your-client-id>`.
3. Under **Scopes defined by this API**, click **Add a scope** and create a scope, such as `access_as_user`.
4. Under **Authorized client applications**, add your client app ID to allow it to access this API.

#### **2.4. Configure Certificates & Secrets**
1. Go to **Certificates & secrets**.
2. Under **Client secrets**, click **New client secret**.
3. Provide a description and set the expiry, then click **Add**.
4. Copy the value of the client secret — you'll need this for your GitHub secrets.

### 3. GitHub Setup

#### **3.1. Add Secrets to Your GitHub Repository**
- Go to your GitHub repository.
- Click on **Settings**.
- In the left-hand menu, select **Secrets and variables** > **Actions** > **New repository secret**.
- Add the following secrets:

| Secret Name                     | Value Description                                                                                                                                         |
|---------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `AZURE_CREDENTIALS`             | [Service Principal credentials](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows#use-the-azure-login-action-with-a-service-principal-secret) (JSON format) to authenticate with Azure. |
| `AZURE_APP_PUBLISH_PROFILE`     | The publish profile content from the Azure App Service.                                                                                                    |
| `ServiceBusConnectionString`    | Connection string for your Service Bus. Found in Service Bus > Shared access policies.                                                                      |
| `ServiceBusTopicName`           | The name of your Service Bus topic.                                                                                                                         |
| `AzureAd__Instance`             | Should be `https://login.microsoftonline.com/`.                                                                                                             |
| `AzureAd__Domain`               | Your Azure AD domain, e.g., `yourname.onmicrosoft.com`.                                                                                                     |
| `AzureAd__TenantId`             | The Tenant ID from your Azure AD App Registration.                                                                                                          |
| `AzureAd__ClientId`             | The Client ID from your Azure AD App Registration.                                                                                                          |
| `AzureAd__ClientSecret`         | The Client Secret from your Azure AD App Registration.                                                                                                      |
| `AzureAd__CallbackPath`         | Should be `/signin-oidc`.                                                                                                                                   |

### 4. Update the GitHub Action Workflow

Ensure that the `.yml` file for the GitHub Action in your repository is configured as shown in this repository. You can find it under `.github/workflows/` and it should be named something like `deploy-azure-app-service.yml`.

### 5. Push Changes to GitHub

Once your secrets are added and your workflow is configured:

1. Commit and push your code to the `main` branch (or the branch you configured in the workflow).
2. This will trigger the GitHub Action and deploy your ASP.NET Core application to the Azure App Service.

### 6. Monitor the Deployment

1. You can monitor the deployment process in the **Actions** tab of your GitHub repository.
2. Once the deployment is successful, your app should be live and accessible in Azure.

### 7. Testing Your Application

Once deployed, you can test your application:

1. Navigate to the URL of your Azure App Service.
2. Ensure it is running as expected and that authentication and Service Bus integration work as intended.

### 8. Troubleshooting

- **Authentication Issues**: Ensure that the Azure AD App Registration is correctly configured with the appropriate permissions and that the redirect URIs match.
- **Environment Variables Not Set**: Verify that all necessary environment variables are defined and correctly added to the GitHub secrets.
- **Build/Deployment Failures**: Review the logs in the GitHub Actions tab to identify and resolve any issues.

### 9. Useful Links

- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure AD App Registration Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
- [Azure Service Bus Documentation](https://docs.microsoft.com/en-us/azure/service-bus-messaging/)
- [ASP.NET Core Authentication with Azure AD](https://docs.microsoft.com/en-us/aspnet/core/security/authentication/azure-active-directory/)