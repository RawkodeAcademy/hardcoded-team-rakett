using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapPost("/analyze", async ([FromBody] AggregatorRequest request) =>
{
    using var client = new HttpClient();

    var normalizerResponse = await client.PostAsync("http://normalizer:8080",
        new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json"));

    var normalizerContent = await normalizerResponse.Content.ReadAsStringAsync();
    var normalized = JsonSerializer.Deserialize<ValueResponse>(normalizerContent)?.Value;

    return new AggregatorResponse
    {
        Normalized = normalized
    };
});

app.Run();

public class AggregatorRequest
{
    [JsonPropertyName("text")]
    public string Text { get; set; }
}

public class ValueResponse
{
    [JsonPropertyName("value")]
    public string Value { get; set; }
}

public class AggregatorResponse
{
    [JsonPropertyName("normalized")]
    public string Normalized { get; set; }
}