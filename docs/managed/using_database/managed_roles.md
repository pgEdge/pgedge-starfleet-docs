# Managing Database Roles

Every pgEdge Starfleet database comes with two roles you can connect as,
`admin` and `app`; they divide responsibilities by function rather than by
privilege level:

- `app` owns the database and everything your application builds.
- `admin` has the server-wide privileges an operator needs.

Neither role is a Postgres superuser. The `Connect` pane on the database page
displays a tab for each role, displaying the role's associated password. Your
pgEdge Starfleet database starts as a single database, owned by `app`. The
`admin` role exists to administer Postgres, including creating further roles
and databases on the same server.

`admin` can create roles beyond `app` and `admin` themselves, for a human
user, a script, or a separate service. Ownership and permissions for those
roles follow standard Postgres semantics: if a role such as `alice` creates
a table meant for the application, a role with the right privileges
(`alice` or `admin`) can reassign ownership to `app` with
`ALTER TABLE ... OWNER TO app;`, or grant the needed privileges with
`GRANT`, so the application can use it. pgEdge Starfleet does not change
this behavior; it only adds the `admin` and `app` roles every database
starts with.

## The `app` Role

`app` owns the database; connect as `app` to create tables, load data, and
run your application and its migrations. `app` can also install most
supported extensions, such as `pgcrypto`, and owns each one it installs.
[Installing Supported Extensions on a pgEdge Starfleet Managed Database](managed_extensions.md)
lists which role installs each extension.

`app` is the recommended default role to own an application. The MCP and
RAG Servers also connect as `app`, so those servers can read whatever your
migrations and data imports add to the database.

`app` has no server-wide privilege: it cannot create roles or databases,
view other sessions, end another session, or install an extension such as
`vector` or `postgis`, which only `admin` can install.

`admin` can reduce the privileges available to `app`:

- revoke a privilege previously granted to `app`.
- reassign a table's owner away from `app`.
- restrict `app`'s access to a schema.

Because the MCP and RAG Servers authenticate as `app`, revoking a
privilege from `app` also revokes it from those servers.

## The `admin` Role

`admin` exists to administer the database, not to build your schema; it
has the privileges a database administrator needs day-to-day, without the
superuser powers that could damage the database or reach the server it
runs on. `admin` can:

- read and change the data in every table, regardless of ownership.
- create roles and databases.
- view every session and its running query, and end any session.
- run `VACUUM`, `ANALYZE`, `REINDEX`, and similar maintenance on any table.
- create logical replication subscriptions.
- install the supported extensions `app` cannot install, such as `vector`
  and `postgis`.

`admin` cannot read or write files on the server, run programs on it, or
become a superuser.

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

The following table compares the two roles:

| Capability | `admin` | `app` |
|------------|---------|-------|
| Create tables and schemas | Yes | Yes |
| Read data in any table | Yes | Tables it owns |
| Insert, update, and delete in any table | Yes | Tables it owns |
| Create roles | Yes | No |
| Create databases | Yes | No |
| View other sessions and their queries | Yes | No |
| End another session | Yes | No |
| Run maintenance on any table | Yes | Tables it owns |
| Create logical replication subscriptions | Yes | No |
| Install extensions such as `pgcrypto` | Yes | Yes |
| Install extensions such as `vector` and `postgis` | Yes | No |
| Read or write files on the server | No | No |

## Finding the `app` or `admin` Credentials

The `Connect` pane on the database page provides an `Admin` tab and an
`Application` tab. Each tab displays:

- a connection string.
- a ready-to-use psql command.
- the password for that role.
- a `Rotate credentials` button.

The MCP and RAG Servers connect to the database as `app`. As a result,
each server can read and change any database objects owned by `app`.

## Rotating Database Credentials

Rotating a database role's password replaces it with a new one the platform
generates. The `Rotate credentials` button on the `Connect` pane triggers
rotation; for about ten seconds afterward, neither password is reliable.
Your account's only other credential, the API client secret, is replaced
rather than rotated, as described further below.

The `Connect` pane on a database's overview page has an `Admin` tab and an
`Application` tab. Each tab displays the connection string, psql command,
database name, domain, user, and password, with `Rotate credentials`
underneath. Rotating from this tab modifies the credentials of the
Postgres user named on it.

The button is disabled while the database is provisioning; the console
enables it only for a database that is `available` or `degraded`. The API
allows a rotation only from databases in an `available` state, so a
`degraded` database can offer the button and still refuse the write.

The button opens a `Rotate credentials` dialog naming the Postgres user, with
`Rotate credentials` and `Cancel`. Rotating the `Application` role adds a note
about the MCP and RAG Servers restarting.

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

    The MCP Server reads the database's `app` password once, at startup.
    Changing the `app` role's password therefore restarts the database's
    MCP and RAG servers so they pick up the new password, causing a short
    gap in service. Your client configuration does not change.

    The updated password authenticates only when the database status
    returns to `available`; the old password may still work until then.

You can read or copy the new password from the `Password` field on the
`Connect` pane. The `Connection string` and `psql command` rows are
updated with the new password; copying a connection string provides a
working string without displaying the secret.

## Troubleshooting

- **`Could not rotate credentials. Please try again.`** appears, or
  the API's own message when it sends one, such as `rotating a
  password requires the database to be available; it is busy with
  another operation`. Waiting resolves this; a database already
  `modifying` from an earlier restore or resize refuses rotation for
  the same reason.

- **If no notification arrives**, do not select the button again; a
  rotation sends the new credential before confirming, so a repeat
  risks replacing a credential already in place. Instead, check the
  Activity Log: find the `rotate-password-managed` task and compare
  its `Updated at` against the current time, not its `Created at`. A
  rotation completes in seconds, so a task still running with an old
  `Updated at` has stalled; equal `Created at` and `Updated at` values
  mean it finished within the API's one-second resolution and is
  healthy.

- **A failed rotation** leaves the database `degraded`, with the new
  credential recorded but not applied; a `degraded` database refuses
  further rotations until recovered.

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
