# Database Roles

Every pgEdge Starfleet database comes with two roles you can connect as,
`admin` and `app`; neither role is a Postgres superuser. They split the work
by job rather than by seniority: 

* `app` owns the database and everything your application builds.
* `admin` has the server-wide privileges an operator needs. 

The `Connect` pane on the database page displays a tab for each role, that
displays the password associated with the role.

Your pgEdge Starfleet database starts as a single database, owned by `app`.
The `admin` role exists to administer Postgres, including creating further
roles and databases on the same server.

## Understanding the `app` Role

`app` owns the database. Connect as `app` to create tables, load data, and
run your application and its migrations. `app` can also install the extensions
Postgres itself marks trusted, such as `pgcrypto`, and owns each one it
installs.

!!! hint

    Each Postgres object belongs to the role that creates the object; object
    ownership is managed after creation with the sql ALTER object_name
    command.

`app` is the sensible default role to own an application. The MCP and RAG servers
also connect as `app`, so whatever your migrations and data imports add to
the database, those servers can read.

`app` holds no server-wide privilege: it cannot create roles or databases,
cannot see what other sessions are running, cannot end another session, and
cannot install an extension on the pgEdge allowlist.

## Understanding the `admin` Role

`admin` is for administering the database rather than for building your
schema; it carries the privileges a database administrator needs day to
day, without the superuser powers that could damage the database or reach
the server it runs on. `admin` can:

* read and change the data in every table, whoever owns it.
* create roles and create databases.
* see every session and the query it is running, and end a session.
* run `VACUUM`, `ANALYZE`, `REINDEX`, and similar maintenance on any table.
* create logical replication subscriptions.
* install the extensions on the pgEdge allowlist, such as `vector`,
  `postgis`, and `pg_cron`.

`admin` cannot read or write files on the server, run programs on it, or
become a superuser.

## Creating Database Objects

An object belongs to the role that creates it, so you should create tables
and schemas as `app`. A table created as `admin` belongs to `admin`, and your
application, when connected as `app`, will not be able to alter or drop it.

`admin` is a member of `app`, so `admin` can also create tables and schemas
and install trusted extensions; anything it creates belongs to `admin`
rather than to `app`. Schema work should therefore be performed as `app`,
so that application objects remain owned by `app`.

## Comparing Role Capabilities

The following table compares the two roles:

| Capability | `admin` | `app` |
|------------|---------|-------|
| Create tables and schemas | Yes | Yes |
| Read data in any table | Yes | Tables it owns |
| Insert, update and delete in any table | Yes | Tables it owns |
| Create roles | Yes | No |
| Create databases | Yes | No |
| See other sessions and their queries | Yes | No |
| End another session | Yes | No |
| Run maintenance on any table | Yes | Tables it owns |
| Create logical replication subscriptions | Yes | No |
| Install trusted extensions | Yes | Yes |
| Install allowlisted extensions | Yes | No |
| Read or write files on the server | No | No |

## Finding Your Credentials

The `Connect` pane on the database page provides an `Admin` tab and an
`Application` tab. Each tab displays:

* a connection string.
* a ready-to-use psql command.
* the password for that role.
* a `Rotate credentials` button.

For details about reading and handling these credentials, see
[Connecting with psql](../connecting/psql.md). 

For details about replacing a password, see
[Rotating Database Credentials](../using_console/rotate_credentials.md).

The MCP and RAG servers connect to the database as `app`. As a result,
each server can read and change whatever `app` can, and rotating the
`app` password restarts both servers.

## Restricting the `app` Role

`admin` can reduce the privileges available to `app`. For example,
`admin` can:

* revoke a privilege previously granted to `app`.
* reassign the owner of a table away from `app`.
* restrict `app`'s access to a schema.

Postgres permits these actions, and the pgEdge Starfleet platform enforces
no additional restrictions to prevent or reverse them.

Because the MCP and RAG servers authenticate to the database as `app`,
revoking a privilege from `app` also revokes it from those servers.

## Next Steps

* [Installing Extensions](extensions.md) covers which role
  installs which extension and what the refusal message means.
* [Loading Data into Your pgEdge Starfleet Database](loading_data.md) covers
  the load order that uses both roles.
* [Connecting to a pgEdge Starfleet Database](../connecting/index.md) covers
  the clients and how each one takes the credentials.
