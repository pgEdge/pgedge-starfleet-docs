# Installing Extensions

This page documents the PostgreSQL extensions available on a pgEdge
Starfleet database, the built-in role required to install each extension,
and the error returned when an installation is rejected. 

## Installing an Extension

Extensions are installed with `CREATE EXTENSION` over a normal Postgres
connection. There is nothing to click in the console: its part is handing you
the right connection. The `Connect` pane on the database page displays a
`psql command` for each role that already includes `PGSSLMODE=require` and
fills the password in when you copy it.

See [Connecting with psql](../connecting/psql.md) for finding the pane
and copying the command for either role.

## Which Role Installs Which Extension

Neither `admin` nor `app` is a Postgres superuser, and which role an
extension needs depends on the extension:

* An extension on the pgEdge privileged-extension allowlist installs as
  `admin`, and `app` is refused. The installed extension ends up owned by
  `postgres` rather than by either role, which is what `\dx` shows
  afterwards.

* An extension that Postgres itself marks trusted installs as either role,
  because `admin` is a member of `app`. The role that runs the install owns
  the extension afterwards. See
  [Which Role Creates Objects](roles.md#which-role-creates-objects).

## The Extensions and How to Get Them

Connect as the named role and run the statement. Anything already installed
needs nothing at all.

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

`vector` and `vchord_bm25` are available on a fresh database but not
installed, so a schema that depends on either needs the `admin` connection
before the schema loads. For an extension the table does not list, try the
install and read the refusal.

## The Refusal Message

A refused install answers `Must be superuser to create this extension`. As
`app` that means the extension is either allowlisted or unavailable, so try
again as `admin`. An extension that answers the same way as `admin` cannot be
installed by any role on the database.

## Who Installs It Owns It

A trusted extension belongs to the role that installed it, and a migration
can only manage an extension its own role owns. Most migration tools connect
as `app`, so install trusted extensions such as `pgcrypto` and `citext` as
`app`, or let the migration's own `CREATE EXTENSION IF NOT EXISTS` line do
it. Allowlisted extensions always end up owned by `postgres` no matter who
installs them, so for those the role makes no difference to ownership.

## Installing in Order

A schema and data load that needs extensions from both halves of the table
needs the `admin` connection once, before anything else:

1. Connect as `admin` and install the allowlisted extensions the schema
   depends on.

2. Connect as `app`, install the trusted ones, then load the schema and the
   data.

Loading a schema before its extensions exist fails the same way loading it as
the wrong role does.

## Next Steps

* [Database Roles](roles.md) covers what each of the two roles can do
  beyond installing extensions.

* [Loading Data into Your pgEdge Starfleet Database](loading_data.md)
  covers the full load sequence and the `pg_restore` flag that half-succeeds.
