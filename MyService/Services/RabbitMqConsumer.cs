using System.Text;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace MyService.Services
{
    public class RabbitMqConsumer
    {
        private readonly string _hostname = "rabbitmq-cont-app.wittydesert-16cb5ef0.germanywestcentral.azurecontainerapps.io"; // Matches the container hostname
        private readonly int _port = 5672;

        public RabbitMqConsumer()
        {
        }

        public void ReceiveMessages()
        {
            var factory = new ConnectionFactory
            { 
                HostName = _hostname,
                Port = _port,
                UserName = "admin", 
                Password = "admin"
            };
            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            var qName = "test-san-queue";
            channel.QueueDeclare(queue: qName, durable: false, exclusive: false, autoDelete: false, arguments: null);

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                Console.WriteLine($"Message received: {message}");
            };

            channel.BasicConsume(queue: qName, autoAck: true, consumer: consumer);
            Console.ReadLine();
        }
    }
}