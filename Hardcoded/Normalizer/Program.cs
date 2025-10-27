using System.Text;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Mvc;
using Normalizer;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapPost("/", ([FromBody] NormalizerRequest request) =>
{
    var normalized = request.Text
        .Normalize(NormalizationForm.FormKC)
        .ToLower()
        .Trim();
    
    normalized = Regex.Replace(normalized, @"\s+", " ");
    normalized = normalized.RemoveDiacritics();
    
    return new NormalizerResponse(normalized);
}).WithName("Normalize");

app.Run();

public class NormalizerRequest
{
    [JsonPropertyName("text")]
    public string Text  { get; set; }
}

public class NormalizerResponse(string value)
{
    [JsonPropertyName("key")] 
    public string Key { get; set; } = "normalized";

    [JsonPropertyName("value")] 
    public string Value { get; set; } = value;

    [JsonPropertyName("cache_hit")] 
    public bool CacheHit { get; set; } = false;
}