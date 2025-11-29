using System.Net.WebSockets;
using System.Text;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel to listen on all interfaces for cloud deployment
var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// Get allowed origins from environment or use defaults
var allowedOrigins = Environment.GetEnvironmentVariable("ALLOWED_ORIGINS")?.Split(',') 
    ?? new[] { "http://localhost:3000", "http://localhost:5000", "*" };

// CORS configuration for cloud deployment
builder.Services.AddCors(opt =>
{
    opt.AddPolicy("ws", p =>
    {
        if (allowedOrigins.Contains("*"))
        {
            p.AllowAnyHeader()
             .AllowAnyMethod()
             .SetIsOriginAllowed(_ => true)
             .AllowCredentials();
        }
        else
        {
            p.AllowAnyHeader()
             .AllowAnyMethod()
             .AllowCredentials()
             .WithOrigins(allowedOrigins);
        }
    });
});

// Add health checks for cloud monitoring
builder.Services.AddHealthChecks();

var app = builder.Build();

app.UseCors("ws");

// Health check endpoint for load balancers and monitoring
app.MapHealthChecks("/health");

app.UseWebSockets(new WebSocketOptions
{
    KeepAliveInterval = TimeSpan.FromSeconds(30)
});

var clients = new HashSet<WebSocket>();
var clientLock = new object(); // Thread-safe client management

app.MapGet("/", () => new
{
    status = "running",
    service = "WebSocket Server",
    version = "1.0.0",
    endpoints = new { websocket = "/ws", health = "/health" }
});

app.Map("/ws", async context =>
{
    if (!context.WebSockets.IsWebSocketRequest)
    {
        context.Response.StatusCode = 400;
        return;
    }

    using var socket = await context.WebSockets.AcceptWebSocketAsync();
    
    lock (clientLock) { clients.Add(socket); }
    Console.WriteLine($"[{DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}] Client connected. Total clients: {clients.Count}");

    var buffer = new byte[8 * 1024];
    var ct = context.RequestAborted;

    try
    {
        while (!ct.IsCancellationRequested && socket.State == WebSocketState.Open)
        {
            var result = await socket.ReceiveAsync(buffer, ct);

            if (result.MessageType == WebSocketMessageType.Close)
                break;

            // Handle fragmented frames
            var ms = new MemoryStream();
            ms.Write(buffer, 0, result.Count);
            while (!result.EndOfMessage)
            {
                result = await socket.ReceiveAsync(buffer, ct);
                ms.Write(buffer, 0, result.Count);
            }
            var msg = Encoding.UTF8.GetString(ms.ToArray());

            var payload = new
            {
                type = "echo",
                text = msg,
                serverTime = DateTimeOffset.UtcNow
            };
            var bytes = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(payload));

            // Echo back to sender
            await socket.SendAsync(bytes, WebSocketMessageType.Text, true, ct);

            // Broadcast to other clients
            List<WebSocket> currentClients;
            lock (clientLock) { currentClients = clients.ToList(); }
            
            foreach (var c in currentClients)
            {
                if (c != socket && c.State == WebSocketState.Open)
                {
                    try
                    {
                        await c.SendAsync(bytes, WebSocketMessageType.Text, true, ct);
                    }
                    catch
                    {
                        // Remove dead connections
                        lock (clientLock) { clients.Remove(c); }
                    }
                }
            }
        }
    }
    finally
    {
        lock (clientLock) { clients.Remove(socket); }
        Console.WriteLine($"[{DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}] Client disconnected. Total clients: {clients.Count}");
        try { await socket.CloseAsync(WebSocketCloseStatus.NormalClosure, "bye", ct); } catch { /* ignore */ }
    }
});

Console.WriteLine($"WebSocket server starting on port {port}...");
app.Run();
