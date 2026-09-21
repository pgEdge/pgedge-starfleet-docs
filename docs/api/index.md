# Using the Managed API

pgEdge Starfleet Managed has a REST API for databases, backups, and
other resources. Every request needs a bearer token, in JSON Web
Token (JWT) format. Create a token below, then send one request with
it. [Interactive Reference](reference.md) lists every operation
the API supports. [Using restish](restish.md) covers a command-line
client built for this API.

## Generating an Access Token

An API client has an ID and a secret. The account API trades them for
an access token.

1. Select `Settings` in the navigation pane, then select the
   `API Clients` tab.
2. Select `Create API Client`.
3. Type a name for the client in the `API Client Name` field, then
   select `Create`.
4. Copy the `Auth ID` and `Auth Secret` values now shown on screen.
   The `Auth Secret` value does not appear again after you select
   `Close`.
5. Trade the ID and secret for an access token:

    ```bash
    curl -X POST https://api.pgedge.com/account/v1/oauth/token \
      -H "Content-Type: application/json" \
      -d '{
        "client_id": "<auth-id>",
        "client_secret": "<auth-secret>",
        "grant_type": "client_credentials"
      }'
    ```

    The response holds the new token in `access_token`. The response
    also holds the token's lifetime, in seconds, in `expires_in`, and
    its type in `token_type`.

## Making a Request

Add the access token to each request as a bearer token, against the
Managed API base URL, `https://api.pgedge.com`. List every database
the token's client can reach:

```bash
curl https://api.pgedge.com/managed/v1/databases \
  -H "Authorization: Bearer <access-token>"
```

A working request returns a JSON array of database objects.

## Next Steps

The following pages cover the rest of the Managed API:

* [Interactive Reference](reference.md) lists every field and
  operation the Managed API supports.
* [Using restish](restish.md) covers a command-line client built from
  the API description.
