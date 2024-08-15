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

namespace YourNamespace.Functions
{
    public class ServiceBusMessageProcessor
    {
        private readonly CosmosClient _cosmosClient;
        private readonly BlobServiceClient _blobServiceClient;
        private readonly string _databaseId = "YourDatabaseId";
        private readonly string _containerId = "YourContainerId";
        private readonly string _blobContainerName = "messages";

        public ServiceBusMessageProcessor(CosmosClient cosmosClient, BlobServiceClient blobServiceClient)
        {
            _cosmosClient = cosmosClient;
            _blobServiceClient = blobServiceClient;
        }

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
    }
}
