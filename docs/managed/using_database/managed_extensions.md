# Installing Extensions

This page documents the PostgreSQL extensions available on a pgEdge Starfleet
database, the built-in role required to install each extension, and the error
returned when an installation is rejected.

## Installing an Extension

Extensions are installed with `CREATE EXTENSION` over a normal Postgres
connection. There is nothing to click in the console; the console's only
role here is to provide the connection details you need. The `Connect`
pane on the database page displays a `psql command` for each role that
already includes `PGSSLMODE=require` and fills the password in when you
copy it.

See [Connecting with psql](../connecting/managed_psql.md) to find the pane and
copy the command for either role.

## Determining Which Role Installs Which Extension

Neither `admin` nor `app` is a Postgres superuser, and the required role varies
by extension:

* An extension on the pgEdge privileged-extension allowlist installs as
  `admin`, and `app` is refused. The installed extension ends up owned by
  `postgres` rather than by either role, which is what `\dx` shows afterwards.

* An extension that Postgres itself marks trusted installs as either role,
  because `admin` is a member of `app`. The role that runs the install owns the
  extension afterwards. See
  [Creating Database Objects](managed_roles.md#creating-database-objects).

## Installing Each Available Extension

Connect as the named role and run the statement. Anything already
installed requires no action. The following table shows how to install
each available extension:

| Extension | What to do |
|---|---|
| `plpgsql` | Nothing. Installed on every database. |
| `pg_stat_statements` | Nothing. Installed on every database. |
| `pgaudit` | Nothing. Installed on every database. |
| `vector` | `CREATE EXTENSION vector` as `admin`. |
| `vchord_bm25` | `CREATE EXTENSION vchord_bm25` as `admin`. |
| `postgis` | `CREATE EXTENSION postgis` as `admin`. |
| `pg_cron` | `CREATE EXTENSION pg_cron` as `admin`. |
| `pgcrypto` | `CREATE EXTENSION pgcrypto` as either role. Prefer `app`. |
| `citext` | `CREATE EXTENSION citext` as either role. Prefer `app`. |
| `hstore` | `CREATE EXTENSION hstore` as either role. Prefer `app`. |
| `ltree` | `CREATE EXTENSION ltree` as either role. Prefer `app`. |
| `pg_trgm` | `CREATE EXTENSION pg_trgm` as either role. Prefer `app`. |

`vector` and `vchord_bm25` are available on a newly created database but
not installed, so a schema that depends on either needs the `admin`
connection before the schema loads. For an extension the table does not
list, attempt the installation and review the resulting message.

## Understanding the Refusal Message

A refused installation attempt returns `Must be superuser to create this
extension`. When connected as `app`, that means the extension is either
allowlisted or unavailable, so try again as `admin`. An extension that
answers the same way as `admin` cannot be installed by any role on the
database.

## Understanding Extension Ownership

A trusted extension belongs to the role that installed it, and a migration can
only manage an extension its own role owns. Most migration tools connect as
`app`, so install trusted extensions such as `pgcrypto` and `citext` as `app`,
or let the migration's own `CREATE EXTENSION IF NOT EXISTS` line handle the
installation. Allowlisted extensions always end up owned by `postgres` no
matter who installs them, so the role makes no difference to their
ownership.

## Installing in Order

A schema and data load that needs extensions from both categories in the
table needs the `admin` connection once, before anything else:

1.  Connect as `admin` and install the allowlisted extensions the schema
    depends on.

2.  Connect as `app`, install the trusted ones, then load the schema and the
    data.

Loading a schema before its extensions exist fails in the same way as
loading it under the wrong role.

## Next Steps

* [Managing Database Roles](managed_roles.md) describes what each of
  the two roles can do beyond installing extensions.

* [Loading Data into Your pgEdge Starfleet Database](managed_loading_data.md)
  describes the full load sequence and the `pg_restore` flag that can
  leave the load silently incomplete.
