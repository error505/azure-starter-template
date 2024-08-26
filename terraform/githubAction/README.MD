# Terraform Deployment with GitHub Actions

This project contains Terraform configuration to deploy resources to Azure. The Terraform state is managed remotely using an Azure Storage Account.

## Prerequisites

1. **Azure Subscription**: Ensure you have an Azure subscription.
2. **Azure CLI**: Install the Azure CLI tool.
3. **Terraform**: Install Terraform on your local machine.

## Setting Up the Terraform Backend

To store the Terraform state in Azure, follow these steps:

### Step 1: Create a Resource Group

```bash
az group create --name <tfstate-resource-group-name> --location <your-location>
```

### Step 2: Create a Storage Account

```bash
az storage account create --name <tfstate-storage-account-name> --resource-group <tfstate-resource-group-name> --location <your-location> --sku Standard_LRS
```

### Step 3: Create a Storage Container

```bash
az storage container create --name <tfstate-container-name> --account-name <tfstate-storage-account-name>
```

### Step 4: Update the `main.tf` File

Modify the `main.tf` file to include the Terraform backend configuration.

In your `main.tf`, update the backend configuration with the appropriate values:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "tfstate-resource-group-name"
    storage_account_name  = "tfstatestorageaccountname"
    container_name        = "tfstate-container-name"
    key                   = "terraform.tfstate"
  }
}
```

## GitHub Secrets Setup

Add the following secrets to your GitHub repository:

- `AZURE_CREDENTIALS`: Your Azure service principal credentials.
- `TF_STATE_STORAGE_ACCOUNT_NAME`: The name of your Azure Storage Account.
- `TF_STATE_CONTAINER_NAME`: The name of the container in the Storage Account.
- `TF_STATE_KEY`: The key (name) of the Terraform state file, e.g., `terraform.tfstate`.
- `TF_STATE_RESOURCE_GROUP_NAME`: The resource group where the Storage Account is located.

## Running the GitHub Action

The GitHub Action is triggered on every push to the `main` branch. You can also manually trigger it via the GitHub Actions tab.

## Terraform Workflow

1. **Initialize**: The Terraform backend is configured to store the state in Azure.
2. **Plan**: The changes are planned and reviewed.
3. **Apply**: The changes are applied to your Azure infrastructure.

## Resources

- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)