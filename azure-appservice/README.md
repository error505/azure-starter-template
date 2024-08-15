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
