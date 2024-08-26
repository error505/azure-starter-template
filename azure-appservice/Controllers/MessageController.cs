using System;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using azure_appservice;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;

namespace AppSerivce.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MessageController : ControllerBase
    {
        private readonly IConfiguration _configuration;
        private readonly string _serviceBusConnectionString;
        private readonly string _topicName;

        public MessageController(IConfiguration configuration)
        {
            _configuration = configuration;
            _serviceBusConnectionString = _configuration["ServiceBusConnectionString"];
            _topicName = _configuration["ServiceBusTopicName"];
        }

        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromBody] MessageRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.MessageContent))
            {
                return BadRequest("The messageContent field is required.");
            }

            try
            {
                await SendMessageToServiceBusAsync(request.MessageContent);
                return Ok("Message sent to Service Bus topic successfully.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        private async Task SendMessageToServiceBusAsync(string messageContent)
        {
            // Create the JSON object with MessageId and Content
            var messageObject = new
            {
                MessageId = Guid.NewGuid().ToString(), // Generate a unique MessageId
                Content = messageContent
            };

            // Serialize the object to JSON string
            string jsonMessage = JsonConvert.SerializeObject(messageObject);

            // Create a ServiceBusMessage with the JSON content
            ServiceBusMessage message = new ServiceBusMessage(Encoding.UTF8.GetBytes(jsonMessage));

            await using (var client = new ServiceBusClient(_serviceBusConnectionString))
            {
                ServiceBusSender sender = client.CreateSender(_topicName);
                await sender.SendMessageAsync(message);
            }
        }
    }
}
