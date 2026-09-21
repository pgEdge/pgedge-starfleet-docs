# Using restish

restish is a command-line client for REST APIs. restish reads an
API's OpenAPI file. restish builds a command from each one. Connect
restish to the Managed API. Then run one command.

## Before You Start

An access token is required, from
[Generating an Access Token](index.md#generating-an-access-token).

## Connecting to the Managed API

1. Install restish:

    ```bash
    brew install restish
    ```

2. Confirm the install:

    ```bash
    restish --version
    ```

3. Connect restish to the Managed API:

    ```bash
    restish api connect managed https://api.pgedge.com \
      --spec https://api.pgedge.com/managed/v1/openapi.json
    ```

    This step saves a profile named `managed`.

## Authenticating restish

Each request needs a bearer token. Set the token as the profile's
auth. Read the token from an environment variable:

```bash
export PGEDGE_TOKEN="<access-token>"
restish api set managed \
  'profiles.default.auth: {type: bearer, params: {token: env:PGEDGE_TOKEN}}'
```

The access token expires after the seconds given in `expires_in`. A
new token needs the earlier steps again.

## Running a Command

Each command's name comes from its `operationId`:

| operationId | Command |
|---|---|
| `ListManagedDatabases` | `list-managed-databases` |
| `GetManagedDatabase` | `get-managed-database` |

List each database the token can reach:

```bash
restish managed list-managed-databases
```

## Next Steps

[Interactive Reference](reference.md) lists each operation the API
supports, with the `operationId` behind each one.
