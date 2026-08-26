# MCP Server

The `AI Services` pane on your database's management page displays icons you
can use to deploy available services on your database.

![The AI Services pane](../../../images/sf_services.png)

Select `Enable MCP` to deploy the server; once the service is deployed, select
the `Details` button to view details and manage it.

The
[pgEdge Postgres MCP server](https://docs.pgedge.com/pgedge-postgres-mcp-server/v1-0-0/)
acts as a gateway to your Postgres database; the server translates requests
into actual operations against your database.

!!! warning

    The MCP server provides LLMs with read access to your entire database
    schema and data. It should only be used for internal tools, developer
    workflows, or environments where all users are trusted.

## Enabling the MCP Server

To enable an MCP server, select `Enable MCP` on the `AI Services` pane of
your database's management page.

![Enabling the MCP server](../../../images/sf_enable_mcp.png)

When the `Enable MCP server` popup opens, select the features you wish to
enable:

- Enable `Generate embeddings` to expose a tool that lets the connected LLM
  request vector embeddings for text (e.g., to support semantic search over
  your database, via pgvector). It's optional, and requires you to configure
  embedding-provider credentials.

- Enable `Allow writes` to control whether the query_database tool can execute
  mutating SQL (INSERT/UPDATE/DELETE) in addition to read-only queries. Leaving
  it off keeps the LLM strictly read-only against your database (a much safer
  default); turning it on lets the LLM actually modify or delete rows, a
  higher-risk, explicit option.

When you're finished, select the `Enable MCP server` button to deploy the MCP
server.

![The deployed service](../../../images/sf_enable_mcp_deployed.png)

Once enabled, the MCP Server pane updates to display:

- A green `Running` indicator to let you know the server is enabled.
- A `Details` button that takes you to the Services window where you'll find
  information about connecting to MCP Clients.
- A `Disable` button that you can use to stop the MCP server.

![Disabling the MCP Server](../../../images/sf_mcp_confirm_disable.png)

Select the `Disable MCP Server` button to stop the MCP server.

## Reviewing MCP Server Details

Select the `Details` button on a running MCP Server to open the `Services`
page, which displays the server's status and configuration:

![MCP Server details](../../../images/sf_connect_to_mcp.png)

* `Access` shows whether the server is read-only or
  `READ-WRITE (INSERT / UPDATE / DELETE)`, based on the `Allow writes` setting
  chosen when the server was enabled.
* `Embeddings` shows the configured embedding provider and model (for
  example, `openai · text-embedding-3-small`), if `Generate embeddings` was
  enabled.
* `Bearer token` is the token used to authenticate MCP clients; select the eye
  icon to reveal it, or the copy icon to copy it.

Select `Configure` to change these settings, or `Disable` to stop the server.

## Connecting a Client to the MCP Server

The steps for connecting a client to the MCP server vary by client and
platform. The `Connect to MCP Clients` section (below the server details on
the `Services` page) displays ready-to-use connection details for several
popular clients:

- [Claude Code](https://code.claude.com/docs/en/overview)
- [Cursor](https://cursor.com/en-US/docs)
- [OpenAI Codex](https://openai.com/codex/)
- [Replit](https://docs.replit.com/getting-started/intro-replit)

Select a tab to view the client-specific configuration; for example, the
`Claude Code` tab displays JSON to add to `.mcp.json`:

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
guidance; for `Claude Code`, add the configuration to `.mcp.json` at your
project root, or merge it into your user or project MCP config. Remote
servers (like your pgEdge Starfleet MCP server) use `"type": "http"`.

## Example - Connecting the MCP Server to Claude Code

1. The information you'll need to connect the MCP Server to Claude Code is
   provided on the Services page. In the console, go to the `AI Services`
   pane, then select `Details` on your running MCP Server, or select
   `Services` in the navigation panel to navigate to `Services`.

2. Decide where the configuration should go:
      * At your project root, in a `.mcp.json` file scoped to that project
        (shareable with teammates via version control if desired). If you
        plan to commit this file, don't hardcode your bearer token in it;
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

5. When replacing the .json file contents, ensure that `<your-domain>/mcp/v1`
   and `<your-bearer-token>` are replaced with the real values.

6. Save the file.

7. Restart Claude Code, or start a new session in that project. Claude Code
   reads `.mcp.json` on startup, and typically prompts you to approve or
   trust the new MCP server the first time.

8. Verify the connection: run `/mcp` in Claude Code to confirm
   `pgedge-postgres` appears in the list of active MCP servers, then try a
   natural-language query against your database to confirm the tool works.

   The `/mcp` output shows `pgedge-postgres` as `connected`, along with the
   number of tools it exposes:

   ![The pgedge-postgres MCP server connected in Claude Code](../../../images/sf_mcp_server_list.png)

   Now, you can ask Claude Code to invoke SQL queries against your pgEdge Starfleet database:

   ![Claude Code calling the pgedge-postgres MCP server to create a table](../../../images/sf_mcp_call_to_pg.png)

   Connecting directly to the database with `psql` as `app` (the owner of
   the table) confirms that the changes made through the MCP server were
   applied to the underlying database:

   ![Querying the employees table with psql as the app user](../../../images/sf_mcp_call_pg_psql.png)

