# Using restish

restish is a command-line client for REST APIs; it reads an API's
OpenAPI file and builds a command for each operation the file
describes. This page walks you through connecting restish to the
Managed API, and running a command.

## Before You Start

To follow this page, you need an access token; see
[Generating an Access Token](index.md#generating-an-access-token).

## Connecting to the Managed API

Install restish and point it at the Managed API's OpenAPI file.

1. Install restish with Homebrew:

    ```bash
    brew install restish
    ```

    For other installation methods, see the restish
    [installation guide](https://rest.sh/docs/getting-started/install/).

2. Verify the installation:

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

Each request needs a bearer token. Configure the profile's
authentication to read the token from an environment variable, rather
than storing it in the profile directly:

```bash
export PGEDGE_TOKEN="<access-token>"
restish api set managed \
  'profiles.default.auth: {type: bearer, params: {token: env:PGEDGE_TOKEN}}'
```

Because the token is short-lived, exporting it for the current shell
session is reasonable; avoid persisting the token in a shell profile
file.

The access token expires after the number of seconds specified in
`expires_in`. Repeat the steps in
[Generating an Access Token](index.md#generating-an-access-token) to
get a new one.

## Running a Command

Each command's name comes from its `operationId`. For example:

| operationId | Command |
|---|---|
| `ListManagedDatabases` | `list-managed-databases` |
| `GetManagedDatabase` | `get-managed-database` |

List every database the token's client can reach:

```bash
restish managed list-managed-databases
```

## Next Steps

[Interactive Reference](reference.md) lists each operation the API
supports, with the `operationId` behind each one.
