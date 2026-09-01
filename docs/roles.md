# Database Roles

Every pgEdge Starfleet database comes with two roles you can connect as,
`admin` and `app`. Neither one is a Postgres superuser. They split the work by
job rather than by seniority: `app` owns the database and everything your
application builds in it, and `admin` holds the server-wide privileges an
operator needs. The `Connect` pane on the database page carries a tab for
each role, with its own password.

A Managed instance starts with one database, named by you when you create it
and owned by `app`. `admin` is there so you can administer Postgres the way
you would anywhere else, including creating further roles and databases on
the same instance.
<!-- platform: lead engineer's description, relayed by Ant 2026-09-01 -->
<!-- measured 2026-09-01: datdba is app, admin holds createrole and
     createdb -->
<!-- M:130-131 --> <!-- M:195-199 -->
<!-- measured 2026-09-01 on PostgreSQL 18.4 on a database created that
     day (antrolesprobe): rolsuper is false for both roles, datdba is app -->
<!-- ui:src/hooks/useDatabaseCredentials.tsx -->

## The app Role

`app` owns the database. Connect as `app` to create tables, load data, and run
your application and its migrations, so that every object belongs to the role
that alters and drops it later. `app` can also install the extensions Postgres
itself marks trusted, such as `pgcrypto`, and owns each one it installs.

`app` is the sensible default for an application. It is also the role the
MCP and RAG servers connect as, so whatever your migrations and data imports
add to the database as `app`, those servers can read.
<!-- platform: lead engineer's description, relayed by Ant 2026-09-01 -->
<!-- saas:internal/k8s/mcp.go --> <!-- saas:internal/k8s/rag.go -->
<!-- M:195-199 --> <!-- M:207-210 -->
<!-- measured 2026-09-01: app holds CREATE on the database and on public,
     is a member of pg_database_owner, installed and dropped pgcrypto -->
<!-- measured 2026-08-31: extowner is app for the five trusted extensions
     installed as app, probes/2026-08-31-admin-app-extensions -->

`app` holds no server-wide privilege. It cannot create roles or databases,
cannot see what other sessions are running, cannot end another session, and
cannot install an extension on the pgEdge allowlist.
<!-- measured 2026-09-01: rolcreaterole and rolcreatedb false, no predefined
     role memberships, vector refused with Must be superuser -->

## The admin Role

`admin` is for administering the database rather than for building your
schema. It carries the privileges a database administrator needs day to day,
without the superuser powers that could damage the database or reach the
server it runs on. `admin` can:

* read and change the data in every table, whoever owns it.
* create roles and create databases.
* see every session and the query it is running, and end a session.
* run `VACUUM`, `ANALYZE`, `REINDEX` and similar maintenance on any table.
* create logical replication subscriptions.
* install the extensions on the pgEdge allowlist, such as `vector`, `postgis`
  and `pg_cron`.

<!-- measured 2026-09-01 on both databases: rolcreaterole and rolcreatedb
     true, member of pg_read_all_data, pg_write_all_data, pg_monitor,
     pg_signal_backend, pg_maintain, pg_create_subscription, pg_checkpoint
     and pg_use_reserved_connections, with pg_read_server_files,
     pg_write_server_files and pg_execute_server_program all false -->
<!-- M:201-206 -->
<!-- measured 2026-08-31: vector, vchord_bm25, postgis and pg_cron all
     installed as admin, probes/2026-08-31-admin-app-extensions -->

`admin` cannot read or write files on the server, run programs on it, or
become a superuser.

## Which Role Creates Objects

An object belongs to the role that created it, so create tables and schemas
as `app`. A table created as `admin` belongs to `admin`, and your application,
connected as `app`, cannot alter or drop it.
<!-- M:197-199 -->
<!-- vendor:https://www.postgresql.org/docs/current/ddl-priv.html, only
     the owner or a superuser can alter or drop an object -->

`admin` is a member of `app`, so it can also create tables and schemas and
install trusted extensions. Anything it creates that way belongs to `admin`,
which is why the schema work still belongs on the `app` connection.
<!-- measured 2026-09-01: antrolesprobe, pg_auth_members shows admin as a
     member of app, and CREATE TABLE, CREATE SCHEMA and CREATE EXTENSION
     pgcrypto all succeeded as admin -->

## What Each Role Can Do

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

<!-- measured 2026-09-01, see the comments above for the catalog evidence.
     "Tables it owns" for app: no pg_read_all_data, pg_write_all_data or
     pg_maintain membership, so app reaches only what it owns or is
     granted, vendor:https://www.postgresql.org/docs/current/ddl-priv.html -->

## Where the Credentials Are

The `Connect` pane on the database page shows an `Admin` tab and an
`Application` tab. Each carries a connection string, a psql command and the
password for its role, and a `Rotate credentials` button.
[Connecting with psql](connecting/psql.md) covers reading them and handling
the password, and [Rotating Database Credentials](managed/using/rotate_credentials.md)
covers replacing one.
<!-- ui:src/components/databases/managed/details/ConnectCard.tsx -->

The MCP and RAG servers connect to the database as `app`, so a server can
read and change whatever `app` can, and rotating the `app` password restarts
both of them.
<!-- saas:internal/k8s/mcp.go --> <!-- saas:internal/k8s/rag.go -->
<!-- M:706-709 -->

## Restricting the app Role

`admin` can take things away from `app`: revoke a privilege, change the owner
of a table, or lock a schema down. Postgres allows it and the platform does
not step in. The MCP and RAG servers sit on the same permission boundary as
`app`, so whatever you take from `app` you take from them too.
<!-- platform: lead engineer's description, relayed by Ant 2026-09-01 -->

## Next Steps

* [Installing Extensions](managed/using/extensions.md) covers which role
  installs which extension and what the refusal message means.
* [Loading Data into Your pgEdge Starfleet Database](loading_data.md) covers
  the load order that uses both roles.
* [Connecting to a pgEdge Starfleet Database](connecting/index.md) covers
  the clients and how each one takes the credentials.
