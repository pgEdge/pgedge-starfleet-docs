# Controlling Network Access

A pgEdge Starfleet Managed database accepts a connection only from an
address on its allowlist. The allowlist is a list of IP ranges that may
reach one endpoint. The database has an allowlist, and the MCP server
and RAG server each have their own. A range is a single IPv4 address or
a CIDR block, such as `198.51.100.0/24`. Each range can have a label,
such as `Office VPN`, which is shown in the console only.

## Understanding Allowlist States

An allowlist is in one of three states, and the console shows which:

| State | Who can connect | What the console shows |
|---|---|---|
| Closed | Nobody | `DENY ALL`, or `No IP addresses are allowed` on the `Connect` pane |
| Limited | Only addresses inside the listed ranges | The number of ranges, such as `2 ranges allowed` |
| Open | Every address on the internet | An `Entire internet` badge on the range |

A new database starts closed, unless you allow a range in the
`Network access` step of the create wizard. A new MCP server or RAG
server also starts closed, even when the database allows ranges.
An older database can be open, with the range `0.0.0.0/0`.

An open allowlist leaves the password as the only protection for the
endpoint. Add the ranges you connect from, and then remove the
`0.0.0.0/0` range.

## Understanding What Each Allowlist Covers

Each allowlist covers one endpoint, and adding a range to one never
changes another:

- The database allowlist covers connections to Postgres, from psql,
  pgAdmin, an application or any other client.
- The MCP server allowlist covers connections to the MCP server.
- The RAG server allowlist covers connections to the RAG server.

A branch gets its database allowlist when the branch is created. That
allowlist cannot be changed afterward.

## Adding a Range to an Allowlist

The database allowlist is on the database page. To add a range to the
database allowlist:

1. Select the database name in the navigation pane, on the left of the
   console.

2. In the `ALLOWED IP RANGES` list on the `Connect` pane, select
   `Add range`.

    When the list has no range, the `Label` and `IP address or CIDR
    block` fields are already shown below the list, so go to the next
    step.

    ![The Connect pane with two allowed ranges](../images/managed_allowlist_connect.png)

3. In the `Label` field, enter a name that says where the range is.

    The label is optional, and is up to 64 characters.

4. In the `IP address or CIDR block` field, enter the address or
   range.

    A single address, such as `203.0.113.10`, is saved as
    `203.0.113.10/32`.

5. Select `Add`.

While the change is applied, the database status reads `modifying`
and the list cannot be changed. The banner at the top of the page reads
`Network access update finished` when the change is complete. The change affects new
connections only, and connections that are already open stay open.

When the allowlist is closed, the `Connect` pane shows `Add my current
IP` with the address the console sees you connecting from. Select
`Add my current IP` to add that address as a range labeled `My laptop`.

![The Connect pane with no allowed ranges](../images/managed_allowlist_deny_all.png)

The address the console sees can differ from the address a server or
CI runner connects from. Add a range for each place that connects.

### Allowing Every Address

A range ending in `/0`, such as `0.0.0.0/0`, admits every address on
the internet. When you enter such a range, the form shows a warning,
and `Add` stays disabled until you select `I understand the risk`.

![The add form warning for a range that admits every address](../images/managed_allowlist_add.png)

### Adding a Range for the MCP Server or RAG Server

The MCP server and RAG server allowlists are on the `Services` page,
and a summary is on each server's card in the `AI Services` pane. When
a server allowlist has no range, the card shows two controls:

- Select `Add my IP` to add the address the console sees you
  connecting from, labeled `My IP`.
- Select `Range` to open the server's section of the `Services` page,
  and then select `Add a range`.

When the server allowlist has a range, select `Manage access` on the
card to open the `Services` page, where `Add range` works as it does
for the database.

![The AI Services pane with two servers that allow no ranges](../images/managed_ai_services_allowlist.png)

A change to a server allowlist is complete when the banner at the top of
the page reads `Service update finished`.

## Editing or Removing a Range

Each row in the `ALLOWED IP RANGES` list has an edit control and a
remove control:

- Select the edit control to change the label or the range, then
  select `Save`.
- Select the remove control to delete the range.

The console removes the range without asking for confirmation. When
you remove the last range, the allowlist is closed and nothing can
connect to that endpoint.

## Understanding Allowlist Limits

An allowlist accepts ranges within these limits:

- IPv4 only. The console refuses an IPv6 address.
- A prefix length from `/0` to `/32`.
- 50 ranges per allowlist.
- A label of up to 64 characters.
- No duplicate ranges. The console compares ranges in their saved
  form, so `10.0.0.1` and `10.0.0.1/32` are the same range.

The console saves a CIDR block at the start of its range. For example,
`10.1.2.3/8` is saved as `10.0.0.0/8`, which admits the same addresses.

An allowlist can be changed only while the database status is
`available`.

## Troubleshooting - When a Connection Is Refused

A connection from an address that no range admits is refused before
it reaches Postgres or the service.

### psql Reports `SSL error: unexpected eof while reading`

The database allowlist has no range for the address you connect from.
Postgres never receives the connection, so no password is checked. Add
a range for the address, and connect again after the banner reads
`Network access update finished`.

A message such as `password authentication failed` means the
connection reached Postgres. The allowlist is not the cause.

### An MCP Client or RAG Client Is Refused

When the database accepts connections but the MCP server or RAG server
refuses a client, the server allowlist has no range for the address the
client connects from. The database allowlist does not apply to the
server. Add a range for the address in the server's section of the
`Services` page.

### A Server Card Reads `Running, but unreachable — no ranges allowed.`

The server is running, and its allowlist is closed. Select `Add my IP`,
or select `Range` to add a range for another address.

### The Form Reports `IPv6 is not supported — this endpoint is reachable over IPv4 only`

The endpoint accepts IPv4 connections only. Enter the IPv4 address or
range you connect from. When your network uses IPv6 only, connect
through a network or VPN that has an IPv4 address.

### The Form Reports `Already allowed as <label>`

The range is already in the allowlist, under the label shown. The
console compares saved ranges, so a range written differently can
still match. Use the existing range, or edit it.

### The Form Reports `This list already holds the maximum of 50 ranges. Remove one to add another.`

The allowlist has 50 ranges. Remove a range, or replace several
single addresses with one CIDR block that covers them.

### The List Reads `Ranges can only be changed while the database is available`

The database is busy with another change, and its status is shown at
the end of the message. Wait until the status reads `available`, then
make the change.
