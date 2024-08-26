# Deploy Azure Resources Using Bicep and GitHub Actions

This repository contains a GitHub Action workflow that automatically deploys Azure resources defined in Bicep templates. This guide provides step-by-step instructions to configure the necessary Azure and GitHub settings.

## Prerequisites

Before you begin, ensure you have the following:

1. **Azure Subscription**: You must have an active Azure subscription.
2. **Bicep Templates**: Your Azure resources must be defined using Bicep templates.
3. **GitHub Repository**: A GitHub repository where your Bicep templates are stored.

## Steps to Set Up

### 1. Set Up Azure Service Principal

To allow GitHub Actions to deploy resources to Azure, you need to create a Service Principal and add it as a secret in your GitHub repository.

#### **1.1. Create a Service Principal**

Run the following commands in your terminal:

```bash
az login
az ad sp create-for-rbac --name "my-github-action-sp" --sdk-auth --role contributor --scopes /subscriptions/<your-subscription-id>
```

- Replace `<your-subscription-id>` with your actual Azure subscription ID.
- This command will output a JSON object containing the Service Principal credentials. Copy this output — you'll need it for the next step.

### 2. Add Secrets to Your GitHub Repository

1. Go to your GitHub repository.
2. Click on **Settings**.
3. In the left-hand menu, select **Secrets and variables** > **Actions** > **New repository secret**.
4. Add the following secrets:

| Secret Name             | Value Description                                                                                                          |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------|
| `AZURE_CREDENTIALS`      | The JSON output from the Service Principal creation command (`az ad sp create-for-rbac`).                                  |
| `AZURE_SUBSCRIPTION_ID`  | Your Azure subscription ID (this can also be included in the AZURE_CREDENTIALS JSON, but it's helpful to have separately). |
| `AZURE_RESOURCE_GROUP`   | The name of the resource group where the resources will be deployed.                                                       |
| `AZURE_AD_CLIENT_ID`               | The Azure client id from the my-github-action-sp service principal                                             |

### 3. Update the Bicep Templates

Ensure that your Bicep templates are configured correctly and are placed in the appropriate directory within your repository. Typically, these files are located in a folder named `bicep` or `infra`.

### 4. Update the GitHub Action Workflow

Make sure that the `.yml` file for the GitHub Action in your repository is configured as shown in this repository. You can find it under `.github/workflows/` and it should be named something like `deploy-bicep.yml`.

### 5. Push Changes to GitHub

Once your secrets are added and your workflow is configured:

1. Commit and push your code to the `main` branch (or the branch you configured in the workflow).
2. This will trigger the GitHub Action and deploy your Azure resources using the Bicep templates.

### 6. Monitor the Deployment

1. You can monitor the deployment process in the **Actions** tab of your GitHub repository.
2. Azure deployment logs will be available in the Azure Portal under the **Resource Group** > **Deployments** section.

### 7. Verify the Deployment

Once deployed, verify that your Azure resources have been successfully created:

1. Navigate to the Azure Portal.
2. Go to your Resource Group.
3. Confirm that all resources defined in your Bicep templates have been created as expected.

### 8. Troubleshooting

- **Authentication Issues**: Ensure that the Service Principal credentials are correct and that the necessary permissions have been granted.
- **Bicep Deployment Errors**: Review the deployment logs in the Azure Portal for specific error messages.
- **GitHub Action Failures**: Review the logs in the GitHub Actions tab to identify and resolve any issues.

### 9. Useful Links

- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Service Principal Documentation](https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows)