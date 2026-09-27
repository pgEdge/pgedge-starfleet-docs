# Managing Database Roles

Every pgEdge Starfleet database comes with three roles you can connect as,
`admin`, `app` and `app_read_only`. They divide responsibilities by
function:

- `app` owns the database and everything your application builds.
- `admin` has the server-wide privileges an operator needs.
- `app_read_only` reads what `app` can read, and never writes.

No built-in role is a Postgres superuser. The `Connect` pane on the database
page displays a tab for each role, displaying the role's associated password.
Your pgEdge Starfleet database starts as a single database, owned by `app`. The
`admin` role exists to administer Postgres, including creating further roles
and databases on the same server.

`admin` can create roles beyond the built-in ones, for a human user, a
script, or a separate service. Create a role manager first, and create
every other role from it. A role manager is a role with `CREATEROLE`,
which `admin` creates:

```sql
CREATE ROLE rolemgr LOGIN CREATEROLE PASSWORD '<password>';
```

The role manager keeps control of the roles it creates. A credential
rotation removes `admin`'s ability to grant or drop a role that `admin`
created directly.

A new role cannot create objects in the `public` schema. To let a new role
use the application's tables, connect as `app` and grant the role the
privileges it needs with `GRANT`.

## The `app` Role

`app` owns the database; connect as `app` to create tables, load data, and
run your application and its migrations. `app` can also install most
supported extensions, such as `pgcrypto`, and owns each one it installs.
[Installing Supported Extensions on a pgEdge Starfleet Managed Database](managed_extensions.md)
lists which role installs each extension.

`app` is the recommended default role to own an application. The RAG
Server connects as `app_read_only`. The MCP Server connects as
`app_read_only` too, unless `Allow writes` is on, when it connects as
`app`. Either way, those servers can read whatever your migrations and
data imports add to the database.

`app` has no server-wide privilege: it cannot create roles or databases,
view other sessions, end another session, or install an extension such as
`vector` or `postgis`, which only `admin` can install.

`admin` can reduce the privileges available to `app`:

- revoke a privilege previously granted to `app`.
- reassign a table's owner away from `app`.
- restrict `app`'s access to a schema.

Because `app_read_only` inherits its access from `app`, revoking a
privilege from `app` also revokes it from the MCP and RAG Servers.

## The `admin` Role

`admin` exists to administer the database, not to build your schema; it
has the privileges a database administrator needs day-to-day, without the
superuser powers that could damage the database or reach the server it
runs on. `admin` can:

- read and change the data in every table, regardless of ownership.
- create roles and databases.
- view every session and its running query, and end any session.
- run `VACUUM`, `ANALYZE`, `REINDEX`, and similar maintenance on any table
  on Postgres 17 and 18, and on the tables `app` owns on Postgres 16.
- create logical replication subscriptions.
- install the supported extensions `app` cannot install, such as `vector`
  and `postgis`.

`admin` cannot read or write files on the server, run programs on it, or
become a superuser.

## The `app_read_only` Role

`app_read_only` reads every table `app` can read. The database refuses
every write from it, even after `SET ROLE app`, with an error such as
`cannot execute CREATE TABLE in a read-only session`. Connect as
`app_read_only` for reports, dashboards, or any client that must never
change data.

If the `Connect` pane shows no `Read-only` tab, the database has no
`app_read_only` role. On that database, the MCP and RAG Servers connect as
`app`.

## Creating Database Objects

Your connected application will run as `app`; create and own each
database object the application needs as `app`. A table created as
`admin` belongs to `admin` instead, and `app` has no access to it
unless explicitly granted.

`admin` is a member of `app`, so it can also create tables and schemas and
install the extensions `app` installs; anything it creates belongs to
`admin` rather than `app`. Perform schema work as `app` instead, so
application objects remain owned by `app`.

## Comparing Role Capabilities

The following table compares the three roles:

| Capability | `admin` | `app` | `app_read_only` |
|------------|---------|-------|-----------------|
| Create tables and schemas | Yes | Yes | No |
| Read data in any table | Yes | Tables it owns | Tables `app` can read |
| Insert, update, and delete in any table | Yes | Tables it owns | No |
| Create roles | Yes | No | No |
| Create databases | Yes | No | No |
| View other sessions and their queries | Yes | No | No |
| End another session | Yes | No | No |
| Run maintenance on any table | Yes, on Postgres 17 and 18; tables `app` owns on 16 | Tables it owns | No |
| Create logical replication subscriptions | Yes | No | No |
| Install extensions such as `pgcrypto` | Yes | Yes | No |
| Install extensions such as `vector` and `postgis` | Yes | No | No |
| Read or write files on the server | No | No | No |

## Finding Each Role's Credentials

The `Connect` pane on the database page provides an `Admin` tab, an
`Application` tab and a `Read-only` tab. Each tab displays:

- a connection string.
- a ready-to-use psql command.
- the password for that role.
- a `Rotate credentials` button.

The RAG Server connects to the database as `app_read_only`, so it can read
but never change data. The MCP Server connects as `app_read_only` too,
unless `Allow writes` is on. With `Allow writes` on, it connects as `app`,
and can read and change any database objects owned by `app`.

## Rotating Database Credentials

Rotating a database role's password replaces it with a new one the platform
generates. The `Rotate credentials` button on the `Connect` pane triggers
rotation; for about ten seconds afterward, neither password is reliable.
Your account's only other credential, the API client secret, is replaced
rather than rotated, as described further below.

The `Connect` pane on a database's overview page has an `Admin` tab, an
`Application` tab and a `Read-only` tab. Each tab displays the connection
string, psql command, database name, domain, user, and password, with `Rotate
credentials` underneath. Rotating from this tab modifies the credentials of the
Postgres user named on it.

The button is disabled while the database is provisioning; the console
enables it only for a database that is `available` or `degraded`.

The button opens a `Rotate credentials` dialog naming the Postgres user, with
`Rotate credentials` and `Cancel`. For the `Application` and `Read-only`
roles, the dialog adds `Any AI services that connect as this role restart
to pick up the new password.`

Confirming does three things:

- the API accepts the change, starts the work, and moves the database
  state to `modifying`.
- a `rotate-password-managed` task appears in the Activity Log for
  this database.
- the console re-reads every per-role credential, so the `Connect`
  pane displays the new password rather than a stale one for any
  role.

The call returns no task ID; to find the task ID, paste the database
ID into the Activity Log's `Subject ID` filter. See
[Reviewing the Activity Log](../using_console/managed_activity_log.md).

A successful password update displays `Rotated the password for <user>.`

Wait until the database status returns to `available` before switching
anything over; the status badge on the database's overview page displays
database availability. Rotation
does not interrupt a session already connected, but any new connection
must use the new credentials, so update every client that uses the
rotated role.

!!! hint

    The MCP and RAG Servers read their role's password once, at startup.
    Rotating `app_read_only` restarts the RAG Server, and the MCP Server
    unless `Allow writes` is on. Rotating `app` restarts the MCP Server
    when `Allow writes` is on. Each restart causes a short gap in
    service. Your client configuration does not change.

    The updated password authenticates only when the database status
    returns to `available`; the old password may still work until then.

You can read or copy the new password from the `Password` field on the
`Connect` pane. The `Connection string` and `psql command` rows are
updated with the new password; copying a connection string provides a
working string without displaying the secret.

## Troubleshooting

- **`Could not rotate credentials. Please try again.`** appears when
  the database is busy with another operation. Waiting resolves this; a
  database already `modifying` from an earlier restore or resize
  refuses rotation for the same reason.

- **If no notification arrives**, do not select the button again. The
  database refuses a second rotation while the first is running.
  Instead, check the Activity Log: find the `rotate-password-managed`
  task and compare its `Updated at` against the current time, not its
  `Created at`. A rotation completes in seconds, so a task still
  running with an old `Updated at` has stalled; equal `Created at` and
  `Updated at` values mean it finished within the API's one-second
  resolution and is healthy.

- **A failed rotation** leaves the database `degraded`. The `Connect`
  pane shows the password that currently works. Select
  `Rotate credentials` again to retry the rotation.

    The REST API authenticates with an API client, managed on the
    `API Clients` tab under `Settings`; see
    [The API Clients Tab](../using_console/managed_settings.md#the-api-clients-tab).
    A client's secret is returned once, at creation, and cannot be
    fetched again; both the `Auth ID` and `Auth Secret` have copy
    buttons. Replacing one is a full swap, not a rotation, so the old
    credential keeps working until the new one is proven:

    1. Create the replacement client with `Create API Client`, and
       copy both values before closing the dialog.
    2. Point whatever uses the credential at the new pair.
    3. Confirm the new pair works.
    4. Only then delete the old client; a deleted client cannot be
       recovered, only replaced.
