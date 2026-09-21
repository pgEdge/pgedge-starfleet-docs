# Interactive Reference

The Managed API publishes an OpenAPI file that lists every operation
the API supports, read live below.

An access token is required to try an operation here, from
[Generating an Access Token](index.md#generating-an-access-token).
Select **Authorize** and paste the token in.

<div id="swagger-ui"></div>

<link rel="stylesheet" crossorigin href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.33.0/swagger-ui.css" integrity="sha384-Ov4/wv3j2bmct8cDc5X4ngJZohVPzEmc6uDPH8WeljUxO5vtoykvMEfbu9Vh6RaW" />
<script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.33.0/swagger-ui-bundle.js" crossorigin integrity="sha384-YDALVcy8kj8yltLBVi1vBiBAUqdxvus673gM8XKwiy6aDUJFXivF/KCufekjYbVf"></script>
<script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.33.0/swagger-ui-standalone-preset.js" crossorigin integrity="sha384-My2aDM4r2Mbm3ybHcubKm9O9U8FEjvF/O5nGvE9YK5dzqOTbWEKa79RPJ1krdMaF"></script>
<script>
  window.onload = () => {
    window.ui = SwaggerUIBundle({
      url: 'https://api.pgedge.com/managed/v1/openapi.json',
      dom_id: '#swagger-ui',
      presets: [
        SwaggerUIBundle.presets.apis,
        SwaggerUIStandalonePreset
      ],
      layout: 'StandaloneLayout',
    });
  };
</script>
