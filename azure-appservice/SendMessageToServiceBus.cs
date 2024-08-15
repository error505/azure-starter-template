using System;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace YourNamespace.Controllers
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
        public async Task<IActionResult> SendMessage([FromBody] string messageContent)
        {
            try
            {
                await SendMessageToServiceBusAsync(messageContent);
                return Ok("Message sent to Service Bus topic successfully.");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        private async Task SendMessageToServiceBusAsync(string messageContent)
        {
            await using (var client = new ServiceBusClient(_serviceBusConnectionString))
            {
                ServiceBusSender sender = client.CreateSender(_topicName);

                ServiceBusMessage message = new ServiceBusMessage(Encoding.UTF8.GetBytes(messageContent));
                await sender.SendMessageAsync(message);
            }
        }
    }
}
