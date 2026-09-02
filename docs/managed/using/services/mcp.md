# MCP Server

The `AI Services` pane on your database's management page displays icons you
can use to deploy available services on your database.

![The AI Services pane](../../../images/sf_services.png)

Select `Enable MCP` to deploy the server. Once the service is deployed, select
the `Details` button to view details and manage it.

The
[pgEdge Postgres MCP server](https://docs.pgedge.com/pgedge-postgres-mcp-server/v1-0-0/)
acts as a gateway to your Postgres database. The server translates requests
into actual operations against your database.

The server connects to the database as the `app` role, so even a read-only
server can read every table `app` can read.

!!! warning

    The MCP server provides LLMs with read access to your entire database
    schema and data. It should only be used for internal tools, developer
    workflows, or environments where all users are trusted.

## Enabling the MCP Server

To enable an MCP server, select `Enable MCP` on the `AI Services` pane of
your database's management page. The button is active only while the database
status is `Available`. On a database in any other status, hovering it shows
`Database not available`.

![Enabling the MCP server](../../../images/sf_enable_mcp.png)

When the `Enable MCP server` popup opens, select the features you wish to
enable. Both switches are optional and both start off, so submitting the form
unchanged gives you a read-only server with a bearer token the platform
generates for you.

- Enable `Generate embeddings` to expose the `generate_embedding` tool, which
  lets the connected LLM request vector embeddings for text (for example, to
  support semantic search over your database, via pgvector). It's optional,
  and requires you to select a provider and model and supply an API key for
  that provider.

- Enable `Allow writes` to control whether the `query_database` tool can
  execute mutating SQL (INSERT/UPDATE/DELETE) in addition to read-only
  queries. Leaving it off keeps the LLM strictly read-only against your
  database (a much safer default). Turning it on lets the LLM modify or delete
  rows, a higher-risk, explicit option. The switch is off by default and is
  labelled in red.

pgEdge Starfleet accepts two embedding providers, `OpenAI` and `Voyage`.
Self-hosted model serving has nowhere to run on a Starfleet database, so no
other provider is accepted.

The embedding API key is stored encrypted server-side. On a later edit, the
stored key stays in place only while the provider you select still matches the
one already stored. Switching provider asks for a new key.

When you're finished, select the `Enable MCP server` button to deploy the MCP
server.

![The deployed service](../../../images/sf_enable_mcp_deployed.png)

Enabling, configuring or disabling any service is a services write, so it
requires the database to be `Available`, and it appears in the Activity Log as
an `update-managed` task. Every services change shares that one task name, so
the Activity Log cannot tell an MCP change from a RAG change.

Once enabled, the MCP Server pane updates to display:

- A status badge. A `running` state reads `Running`. Every other state is
  shown as the raw value the API sent, in lower case, such as `failed` or
  `pending`.
- A `Details` button that takes you to the Services window where you'll find
  information about connecting to MCP Clients.
- A `Disable` button that you can use to stop the MCP server.

![Disabling the MCP Server](../../../images/sf_mcp_confirm_disable.png)

Select the `Disable MCP Server` button to stop the MCP server. Removing the
server does not change your client configuration, and every request from that
client fails once the server is gone. A removed endpoint keeps answering for a
few seconds before it stops. You can enable the server again later.

## Knowing When the Server Is Ready

`Running` means the deploy finished, not that the server answers. The endpoint
returns `503` for roughly fifteen to twenty seconds after the deploy
completes.

The `state` field is not a readiness signal at all. It reads `running` the
moment the deploy completes, whatever the server itself is doing.

Only `failed` is a reliable state. A `failed` badge calls for action, and the
Activity Log carries the reason. A `Running` badge proves nothing on its own.
Test readiness by connecting a client: point your editor at the endpoint, and
if it reports the server as unavailable, wait a few seconds and reconnect.

## Reviewing MCP Server Details

Select the `Details` button on a running MCP Server to open the `Services`
page, which displays the server's status and configuration:

![MCP Server details](../../../images/sf_connect_to_mcp.png)

* `Access` shows whether the server is read-only or
  `READ-WRITE (INSERT / UPDATE / DELETE)`, based on the `Allow writes` setting
  chosen when the server was enabled.
* `Embeddings` shows the configured embedding provider and model (for
  example, `openai · text-embedding-3-small`), or `Disabled` if
  `Generate embeddings` was not enabled.
* `Bearer token` is the token used to authenticate MCP clients. Select the eye
  icon to reveal it, or the copy icon to copy it. The token is the MCP
  server's own credential and is not the database password.

Select `Configure` to change these settings, or `Disable` to stop the server.
The `Configure` button reopens the same form, and a change to one field leaves
the others as they are.

The connection endpoint appears in the `Connect to MCP Clients` panel only
once the server reports `Running`. It is the database's own domain with
`/mcp/v1` on the end. Until then the panel reads "Connection details appear
here once the MCP server is running." The endpoint carries no port in the
ordinary case, because a Starfleet service is reached over HTTPS on port 443.

## Connecting a Client to the MCP Server

The steps for connecting a client to the MCP server vary by client and
platform. The `Connect to MCP Clients` section (below the server details on
the `Services` page) displays ready-to-use connection details for four
clients:

- [Claude Code](https://code.claude.com/docs/en/overview) shows a JSON block
  with `"type": "http"`, the endpoint as its URL and an `Authorization`
  header carrying the bearer token. Add it to `.mcp.json` at your project
  root, or merge it into your user or project MCP config.
- [Cursor](https://cursor.com/en-US/docs) shows the same JSON without the
  `type` field. Add it to `.cursor/mcp.json` in the repository for one
  project, or to `~/.cursor/mcp.json` to make the server available
  everywhere.
- [OpenAI Codex](https://openai.com/codex/) shows a TOML block declaring an
  `mcp_servers.pgedge_postgres` table with the endpoint as its URL, and an
  `mcp_servers.pgedge_postgres.http_headers` sub-table carrying the
  `Authorization` header. Append it to `~/.codex/config.toml`. The header
  block embeds the token directly, so it works however Codex is launched.
- [Replit](https://docs.replit.com/getting-started/intro-replit) has no file
  to edit. The panel shows four values to copy one at a time: a display name
  of `pgEdge Postgres`, the MCP Server URL, a custom header name of
  `Authorization`, and its value, which is the word `Bearer` followed by the
  token. In Replit these go under Integrations, then MCP Servers, then Add
  MCP server, and the flow ends at Test and Save.

Select a client button to view the client-specific configuration. In the
displayed block the token is masked until you reveal it with the eye icon, but
the copy icon always copies the real token, revealed or not. For example, the
`Claude Code` button displays JSON to add to `.mcp.json`:

```json
{
  "mcpServers": {
    "pgedge-postgres": {
      "type": "http",
      "url": "https://<your-domain>/mcp/v1",
      "headers": {
        "Authorization": "Bearer <your-bearer-token>"
      }
    }
  }
}
```

Select the copy icon (in the upper-right corner of the code block) to copy
the configuration. A hint below the code block gives client-specific setup
guidance. For `Claude Code`, add the configuration to `.mcp.json` at your
project root, or merge it into your user or project MCP config. Remote
servers (like your pgEdge Starfleet MCP server) use `"type": "http"`.

### Connecting Another Client

The panel carries a block for those four clients and no others, so there is no
ready-made block for VS Code, or for any other client not named above.

The server speaks streamable HTTP at the endpoint itself and authenticates on
the `Authorization` header as a bearer token. Any client that takes a URL and
a header can use the same two values the panel shows.

## When the Services Page Shows an Error

`Unable to load services` appears as a red panel on the `Services` page,
with the body `We could not load this database. Refresh the page to try
again.` Refresh. The MCP and RAG servers keep running while the console
cannot read them, so this is a console read failure rather than an outage of
the services themselves.

`Failed to update MCP server.` is a red notification meaning a services
change was refused. It is the fallback text, shown when the API sends no
message of its own. A services change needs the database `Available`, and
every services change writes one `update-managed` task, so the Activity Log
carries the attempt whether it succeeded or not.

## Example - Connecting the MCP Server to Claude Code

1. The information you'll need to connect the MCP Server to Claude Code is
   provided on the Services page. In the console, go to the `AI Services`
   pane, then select `Details` on your running MCP Server, or select
   `Services` in the navigation panel to navigate to `Services`.

2. Decide where the configuration should go:
      * At your project root, in a `.mcp.json` file scoped to that project
        (shareable with teammates via version control if desired). If you
        plan to commit this file, don't hardcode your bearer token in it.
        Claude Code supports `${VAR}` environment-variable expansion in
        `.mcp.json` values, so you can reference an environment variable
        instead (for example, `"Authorization": "Bearer ${PGEDGE_MCP_TOKEN}"`)
        and set the real token outside the file.
      * Or merged into your user-level Claude Code configuration, to make
        the server available across all your projects.

3. Open the `.mcp.json` file (project or user-level) if it already exists,
   or create a new one. If you are creating a new file, you need only include
   the snippet provided on the `Claude Code` tab of the `Services` pane.

   If you already have an `mcp.json` file that lists other MCP servers under
   `mcpServers`, take care to not overwrite them.

4. Add the `pgedge-postgres` entry. If the file is new, paste the whole
   block:

    ```json
    {
      "mcpServers": {
        "pgedge-postgres": {
          "type": "http",
          "url": "https://<your-domain>/mcp/v1",
          "headers": {
            "Authorization": "Bearer <your-bearer-token>"
          }
        }
      }
    }
    ```

    If `mcpServers` already has other entries, add the `"pgedge-postgres":
    { ... }` key alongside them, inside the existing object.

5. When replacing the .json file contents, make sure that
   `<your-domain>/mcp/v1` and `<your-bearer-token>` are replaced with the
   real values.

6. Save the file.

7. Restart Claude Code, or start a new session in that project. Claude Code
   reads `.mcp.json` on startup, and typically prompts you to approve or
   trust the new MCP server the first time.

8. Verify the connection: run `/mcp` in Claude Code to confirm
   `pgedge-postgres` appears in the list of active MCP servers, then try a
   natural-language query against your database to confirm the tool works.

    If the client reports the server as unavailable, the deploy may have
    finished moments earlier. Wait a few seconds and reconnect.

   The `/mcp` output shows `pgedge-postgres` as `connected`, along with the
   number of tools it exposes:

   ![The pgedge-postgres MCP server connected in Claude Code](../../../images/sf_mcp_server_list.png)

   Now, you can ask Claude Code to invoke SQL queries against your pgEdge
   Starfleet database:

   ![Claude Code calling the pgedge-postgres MCP server to create a table](../../../images/sf_mcp_call_to_pg.png)

   Connecting directly to the database with `psql` as `app` (the owner of
   the table) confirms that the changes made through the MCP server were
   applied to the underlying database:

   ![Querying the employees table with psql as the app user](../../../images/sf_mcp_call_pg_psql.png)

## Prompt Injection

An agent that reads your data can be steered by the text in that data.
Anything the agent reads is text arriving in its context, and text in a row
can read as an instruction rather than as data. A support ticket, a user
profile, a product description or a comment field can carry wording aimed at
the agent rather than at a person, and the agent has no reliable way to tell
the difference.

For this server:

- Keep `Allow writes` off unless you need it. An agent that cannot write
  cannot be talked into writing.
- Turn it off again when the task that needed it is done. The `Configure`
  button changes the one switch.
- Treat a write-enabled agent as a user holding the `app` role's privileges,
  not as a tool. Give it a database whose data you would hand to an untrusted
  client.
- Read what the agent proposes before approving it, in a client that shows
  tool calls before running them.
- Be most careful on tables that hold text other people wrote. Data you
  authored carries less of this risk than data your users submitted.

## Rotating the app Password Restarts the Server

The MCP server reads the database's `app` password once, at startup. Rotating
the `app` role therefore ends by restarting the database's MCP and RAG
servers so they pick up the new password, which means a short gap in service.
Your client configuration does not change, because the bearer token is the MCP
server's own credential rather than the database password.

The rotated password authenticates only once the database status returns to
`Available`, and the old password may still work until then.

