# Azure Function - Service Bus Message Processor

This Azure Function reads messages from an Azure Service Bus topic, processes them, and stores the results in both Azure Cosmos DB and Azure Blob Storage.

## Features

- **Service Bus Integration**: Listens to messages from a specified Service Bus topic.
- **Cosmos DB Integration**: Saves processed messages to an Azure Cosmos DB container.
- **Blob Storage Integration**: Saves a confirmation text file to Azure Blob Storage after processing each message.
- **Scalable**: Built on the Azure Functions consumption plan, allowing for automatic scaling based on demand.

## Functionality

### Trigger

The function is triggered by messages arriving on a Service Bus topic. The trigger is configured in the `local.settings.json` or the Azure Function App settings.

### Processing

Upon receiving a message, the function performs the following actions:

1. **Save Message to Cosmos DB**: The message is stored in the specified Cosmos DB container.
2. **Save Confirmation to Blob Storage**: A confirmation text file is created in Azure Blob Storage.

### Example Code

Here is the core logic of the function:

```csharp
[FunctionName("ProcessServiceBusMessage")]
public async Task Run(
    [ServiceBusTrigger("YourTopicName", "YourSubscriptionName", Connection = "ServiceBusConnectionString")] string mySbMsg,
    ILogger log)
{
    log.LogInformation($"C# ServiceBus topic trigger function processed message: {mySbMsg}");

    // Save to Cosmos DB
    await SaveToCosmosDbAsync(mySbMsg);

    // Save confirmation to Blob Storage
    await SaveConfirmationToBlobAsync(mySbMsg);
}

private async Task SaveToCosmosDbAsync(string message)
{
    var container = _cosmosClient.GetContainer(_databaseId, _containerId);
    dynamic document = JsonConvert.DeserializeObject(message);
    await container.CreateItemAsync(document);
}

private async Task SaveConfirmationToBlobAsync(string message)
{
    BlobContainerClient containerClient = _blobServiceClient.GetBlobContainerClient(_blobContainerName);
    await containerClient.CreateIfNotExistsAsync();

    string blobName = $"{Guid.NewGuid()}.txt";
    BlobClient blobClient = containerClient.GetBlobClient(blobName);

    using (var stream = new MemoryStream(Encoding.UTF8.GetBytes("Processed message: " + message)))
    {
        await blobClient.UploadAsync(stream);
    }
}
```

### Configuration
The following settings need to be configured:

- **ServiceBusConnectionString**: Connection string for the Azure Service Bus.
- **CosmosDBConnectionString**: Connection string for Azure Cosmos DB.
- **AzureWebJobsStorage**: Connection string for Azure Blob Storage (used by the Function App for internal storage).
These settings can be configured in the local.settings.json for local development or in the Azure Function App settings for a deployed function.

### Running the Function Locally
To run the function locally:
``` bash
func start
```

### Deploying to Azure
To deploy the Azure Function to your Azure environment:

- **Create an Azure Function App using the Azure Portal or Azure CLI.**
- **Configure the application settings (ServiceBusConnectionString, CosmosDBConnectionString, AzureWebJobsStorage).**
- **Deploy the function code using Visual Studio, GitHub Actions, or Azure CLI.**
