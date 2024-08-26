using System;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration;

namespace AzureFunction.Functions
{
    public class ServiceBusMessageProcessor
    {
        private readonly CosmosClient _cosmosClient;
        private readonly BlobServiceClient _blobServiceClient;
        private readonly string _databaseId;
        private readonly string _containerId;
        private readonly string _blobContainerName;

        public ServiceBusMessageProcessor(CosmosClient cosmosClient, BlobServiceClient blobServiceClient, IConfiguration configuration)
        {
            _cosmosClient = cosmosClient;
            _blobServiceClient = blobServiceClient;

            // Load configuration variables
            _databaseId = configuration["CosmosDBDatabaseId"];
            _containerId = configuration["CosmosDBContainerId"];
            _blobContainerName = configuration["BlobContainerName"];
        }

        [FunctionName("ProcessServiceBusMessage")]
        public async Task Run(
            [ServiceBusTrigger("%ServiceBusTopicName%", "%ServiceBusSubscriptionName%", Connection = "ServiceBusConnectionString")] string mySbMsg,
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

            // Ensure the Cosmos DB container exists
            await _cosmosClient.GetDatabase(_databaseId).CreateContainerIfNotExistsAsync(new ContainerProperties(_containerId, "/MessageId"));

            dynamic document;

            try
            {
                // Try to deserialize the message into a dynamic object
                document = JsonConvert.DeserializeObject(message);
            }
            catch (JsonReaderException)
            {
                // If deserialization fails, create a simple document with the message as-is
                document = new
                {
                    MessageId = Guid.NewGuid().ToString(),
                    Content = message
                };
            }

            // Save the document to Cosmos DB with a partition key
            await container.CreateItemAsync(document, new PartitionKey(document.MessageId.ToString()));
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
    }
}
