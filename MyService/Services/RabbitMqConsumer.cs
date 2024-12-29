using System.Text;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace MyService.Services
{
    public class RabbitMqConsumer
    {
        private readonly string _hostname = "rabbitmq-cont-app.wittydesert-16cb5ef0.germanywestcentral.azurecontainerapps.io"; // Matches the container hostname
        private readonly int _port = 5672;
        private readonly ILogger<RabbitMqConsumer> _logger;

        public RabbitMqConsumer(ILogger<RabbitMqConsumer> logger)
        {
            _logger = logger;
        }

        public void ReceiveMessages()
        {
            _logger.LogInformation($"Entered Receive Messages");

            var factory = new ConnectionFactory
            { 
                HostName = _hostname,
                Port = _port,
                UserName = "admin", 
                Password = "admin"
            };

            try
            {
                using var connection = factory.CreateConnection();
                using var channel = connection.CreateModel();

                var qName = "test-san-queue";
                channel.QueueDeclare(queue: qName,
                                     durable: true,
                                     exclusive: false,
                                     autoDelete: false,
                                     arguments: null);

                var consumer = new EventingBasicConsumer(channel);
                consumer.Received += (model, ea) =>
                {
                    var body = ea.Body.ToArray();
                    var message = Encoding.UTF8.GetString(body);
                    _logger.LogInformation($"Message received: {message}");
                };

                channel.BasicConsume(queue: qName, autoAck: true, consumer: consumer);
                _logger.LogInformation("RabbitMQ Consumer started, waiting for messages...");
                
                Console.ReadLine();
                // Keeps the application running while listening for messages
                // Task.Delay(-1).Wait(); // This replaces Console.ReadLine() for indefinite running
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error in receiving messages: {ex.Message}");
            }
        }
    }
}