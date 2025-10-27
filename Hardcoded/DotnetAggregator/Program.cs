using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapPost("/analyze", async ([FromBody] AggregatorRequest request) =>
{
    var requestString = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
    
    using var client = new HttpClient();
    var normalizerResponse = await client.PostAsync("http://normalizer:8080", requestString);
    var normalizerContent = await normalizerResponse.Content.ReadAsStringAsync();
    var normalized = JsonSerializer.Deserialize<ValueResponse>(normalizerContent)?.Value;

    var tokenizerResponse = await client.PostAsync("http://tokenizer:8080", requestString);
    var tokenizerContent = await tokenizerResponse.Content.ReadAsStringAsync();
    var tokens = JsonSerializer.Deserialize<ValueResponse>(tokenizerContent)?.Value;

    return new AggregatorResponse
    {
        Normalized = normalized,
        Tokens = tokens
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
    
    [JsonPropertyName("tokens")]
    public string Tokens { get; set; }
}