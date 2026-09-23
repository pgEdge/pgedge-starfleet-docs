# Using restish

restish is a command-line client for REST APIs; it reads an API's
OpenAPI file and builds one command per listed operation. The sections
below cover connecting restish to pgEdge Starfleet Managed Database
and running a command.

## Before You Start

To follow this page, you need an access token; see
[Generating an Access Token](managed_index.md#generating-an-access-token).

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

Each request needs a bearer token; set the profile to read it from
`PGEDGE_TOKEN` rather than storing it directly.

```bash
export PGEDGE_TOKEN="<access-token>"
restish api set managed \
  'profiles.default.auth: {type: bearer, params: {token: env:PGEDGE_TOKEN}}'
```

Because the token is short-lived, exporting it for the current shell
session is fine. Avoid keeping the token in a shell profile file.

The access token expires after the seconds given in `expires_in`.
Repeat the steps in
[Generating an Access Token](managed_index.md#generating-an-access-token) to
get a new token.

## Running a Command

Each command's name comes from its `operationId`. The following table
shows how an `operationId` maps to its restish command:

| operationId | Command |
|---|---|
| `ListManagedDatabases` | `list-managed-databases` |
| `GetManagedDatabase` | `get-managed-database` |
| `UpdateManagedDatabase` | `update-managed-database` |

List every database the token's client can reach:

```bash
restish managed list-managed-databases
```

## Updating a Database from a File

1. List your databases and note the `id` of the one to update:

    ```bash
    restish managed list-managed-databases
    ```

2. Write the fields to change to a file, named for the database.

    ```bash
    cat > orders-db.json <<'EOF'
    {
      "display_name": "Production Orders DB",
      "deletion_protection": true
    }
    EOF
    ```

    Any field left out of the file keeps its current value.

3. Apply the file against that database's `id`.

    ```bash
    restish managed update-managed-database <database-id> < orders-db.json
    ```
