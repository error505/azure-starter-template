using Microsoft.Azure.Cosmos;
using Azure.Storage.Blobs;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;

[assembly: FunctionsStartup(typeof(AzureFunction.Startup))]

namespace AzureFunction
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            // Load configuration
            var configuration = builder.GetContext().Configuration;

            // Register CosmosClient
            string cosmosDbConnectionString = configuration["CosmosDBConnectionString"];
            builder.Services.AddSingleton(s => new CosmosClient(cosmosDbConnectionString));

            // Register BlobServiceClient
            string blobServiceConnectionString = configuration["AzureWebJobsStorage"];
            builder.Services.AddSingleton(s => new BlobServiceClient(blobServiceConnectionString));
        }
    }
}
