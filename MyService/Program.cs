using MyService.Services;

var builder = WebApplication.CreateBuilder(args);

// Add logging to the application
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

app.MapGet("/weatherforecast", () =>
    {
        var forecast = Enumerable.Range(1, 5).Select(index =>
                new WeatherForecast
                (
                    DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                    Random.Shared.Next(-20, 55),
                    summaries[Random.Shared.Next(summaries.Length)]
                ))
            .ToArray();
        return forecast;
    })
    .WithName("GetWeatherForecast")
    .WithOpenApi();

var consumer = new RabbitMqConsumer();
consumer.ReceiveMessages(); // Start the consumer to listen to RabbitMQ

// Start RabbitMQ producer to send messages
//var rabbitMqProducer = new RabbitMqProducer();
StartTimer(app.Services.GetRequiredService<ILogger<Program>>());

app.Run();

void StartTimer(ILogger logger)
{
    var timer = new System.Timers.Timer(30000); // 5 seconds interval
    timer.Elapsed += (sender, e) =>
    {
        logger.LogInformation("Main Timer: {time}", DateTime.Now);
        logger.LogInformation("Sending message: {Message}", "Hello from .NET Web API!" + DateTime.Now.ToString());
    };
    timer.AutoReset = true;
    timer.Enabled = true;
}

record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}