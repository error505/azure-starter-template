# Azure App Service - Service Bus Message Sender

This Azure App Service hosts an API that sends messages to an Azure Service Bus topic. The service is designed to interact with backend components by sending messages that can be processed asynchronously.

## Features

- **Service Bus Integration**: Sends messages to a specified Service Bus topic.
- **Configurable**: The Service Bus connection string and topic name are configurable through the app's settings.
- **Simple API**: Provides an HTTP endpoint to trigger message sending.

## Endpoints

### POST /api/message/send

This endpoint accepts a message in the request body and sends it to the configured Service Bus topic.

**Request Example**:
```bash
curl -X POST "https://yourappservice.azurewebsites.net/api/message/send" -H "Content-Type: application/json" -d "\"Your message content\""
```

### Response:

200 OK: If the message is successfully sent.
500 Internal Server Error: If there is an issue with sending the message.

### Configuration
The following settings need to be configured in the App Service:

- **ServiceBusConnectionString**: The connection string for the Azure Service Bus namespace.
- **ServiceBusTopicName**: The name of the Service Bus topic to which messages will be sent.
- You can configure these settings in **appsettings.json** for local development or in the Azure Portal under the "Configuration" section for the deployed App Service.

Example Code
The core logic for sending messages to the Service Bus is found in the MessageController.cs file:
```csharp
private async Task SendMessageToServiceBusAsync(string messageContent)
{
    await using (var client = new ServiceBusClient(_serviceBusConnectionString))
    {
        ServiceBusSender sender = client.CreateSender(_topicName);
        ServiceBusMessage message = new ServiceBusMessage(Encoding.UTF8.GetBytes(messageContent));
        await sender.SendMessageAsync(message);
    }
}
```
This method creates a ServiceBusClient, sends a message using a ServiceBusSender, and handles the process asynchronously.

### Running the Service Locally

To run the service locally, follow these steps:
- **Build and run the project**:
```bash
dotnet run
```
The service will be available at https://localhost:5001/api/message/send.

### Deploying to Azure

To deploy the service to Azure App Service, use the following steps:

- **Create an Azure App Service using the Azure Portal or Azure CLI.**
- **Configure the application settings (ServiceBusConnectionString, ServiceBusTopicName).**
- **Deploy the code using Visual Studio, GitHub Actions, or Azure CLI.**

### License
This project is licensed under the MIT License - see the LICENSE file for details.
