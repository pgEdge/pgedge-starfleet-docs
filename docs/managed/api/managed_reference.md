# Interactive Reference

The Managed API publishes an OpenAPI file that lists every operation
it supports, rendered live below.

To try an operation here, you need an access token; see
[Generating an Access Token](managed_index.md#generating-an-access-token).
Select `Authorize`, then paste the token into the `AccessToken` field.

<!-- markdownlint-disable MD013 MD033 -->
<style>
  /* One known server, described above; the title/version/license
     block duplicates this page's own prose. Match product-ui's
     existing API docs embed, which hides the same three blocks. */
  #swagger-ui .info,
  #swagger-ui .servers-title,
  #swagger-ui .servers { display: none; }
  #swagger-ui .scheme-container {
    background: transparent;
    box-shadow: none;
    padding: 0;
  }
</style>

<div id="swagger-ui"></div>

<link rel="stylesheet" crossorigin href="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.33.0/swagger-ui.css" integrity="sha384-Ov4/wv3j2bmct8cDc5X4ngJZohVPzEmc6uDPH8WeljUxO5vtoykvMEfbu9Vh6RaW" />
<script src="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5.33.0/swagger-ui-bundle.js" crossorigin integrity="sha384-YDALVcy8kj8yltLBVi1vBiBAUqdxvus673gM8XKwiy6aDUJFXivF/KCufekjYbVf"></script>
<script>
  window.onload = () => {
    window.ui = SwaggerUIBundle({
      url: 'https://api.pgedge.com/managed/v1/openapi.json',
      dom_id: '#swagger-ui',
      presets: [SwaggerUIBundle.presets.apis],
    });
    // Follow this site's own toggle, which sets data-md-color-scheme
    // on <body> without a page reload; Swagger has no such listener.
    const syncTheme = () => {
      const dark = document.body.getAttribute('data-md-color-scheme') === 'slate';
      document.documentElement.classList.toggle('dark-mode', dark);
    };
    syncTheme();
    new MutationObserver(syncTheme).observe(document.body, {
      attributes: true,
      attributeFilter: ['data-md-color-scheme'],
    });
  };
</script>
