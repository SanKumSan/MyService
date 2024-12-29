using MyService.Services;

var builder = WebApplication.CreateBuilder(args);

// Add logging to the application
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// Register services in the DI container
builder.Services.AddSingleton<RabbitMqConsumer>();

// Add services to the container
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Start RabbitMQ consumer to listen for messages
var rabbitMqConsumer = app.Services.GetRequiredService<RabbitMqConsumer>();
rabbitMqConsumer.ReceiveMessages(); // Start the consumer to listen to RabbitMQ

// Start RabbitMQ producer to send messages
var rabbitMqProducer = new RabbitMqProducer();
StartTimer(app.Services.GetRequiredService<ILogger<Program>>());

app.Run();

void StartTimer(ILogger logger)
{
    var timer = new System.Timers.Timer(30000); // 30 seconds interval
    timer.Elapsed += (sender, e) =>
    {
        logger.LogInformation("Main Timer: {time}", DateTime.Now);
        var msg = "Sending message: Hello from .NET Web API!" + DateTime.Now.ToString();
        rabbitMqProducer.SendMessage(msg);
        logger.LogInformation("Sending message: {Message}", msg);
    };
    timer.AutoReset = true;
    timer.Enabled = true;
}

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}
