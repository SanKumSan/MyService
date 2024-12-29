using System.Text;
using RabbitMQ.Client;

namespace MyService.Services
{
    public class RabbitMqProducer
    {
        private readonly string _hostname = "rabbitmq-cont-app.wittydesert-16cb5ef0.germanywestcentral.azurecontainerapps.io"; // Matches the container hostname
        private readonly int _port = 5672;

        public void SendMessage(string message)
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
            channel.QueueDeclare(queue: qName,
                                durable: true,
                                exclusive: false,
                                autoDelete: false,
                                arguments: null);

            var body = Encoding.UTF8.GetBytes(message);

            channel.BasicPublish(exchange: "", routingKey: qName, basicProperties: null, body: body);
        }
    }
}