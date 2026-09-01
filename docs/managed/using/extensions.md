# Installing Extensions

<!-- Measured 2026-08-31 and 2026-09-01 on PostgreSQL 18.4 on databases
     created those days: admin is a member of app and holds CREATE on the
     database, so trusted extensions install as either role. Extensions no
     role can install (dblink, file_fdw, postgres_fdw, amcheck as measured)
     are deliberately not listed. -->

This page covers which PostgreSQL extensions a pgEdge Starfleet database
carries, which of the database's built-in roles installs each one, and how to
read the refusal when an install is rejected. It is for anyone whose schema,
migration tool, or application depends on an extension.
<!-- M:230-231 -->
<!-- measured 2026-08-31 on PostgreSQL 18.4 -->

## Installing an Extension

Extensions are installed with `CREATE EXTENSION` over a normal Postgres
connection. There is nothing to click in the console: its part is handing you
the right connection. The `Connect` pane on the database page carries a
`psql command` for each role that already includes `PGSSLMODE=require` and
fills the password in when you copy it.
<!-- ui:src/components/databases/managed/details/ConnectCard.tsx -->
<!-- ui:src/utils/managedDatabase.ts buildManagedPsqlCommand -->

See [Connecting with psql](../../connecting/psql.md) for finding the pane
and copying the command for either role.

## Which Role Installs Which Extension

Neither `admin` nor `app` is a Postgres superuser, and which role an
extension needs depends on the extension:
<!-- M:135, measured 2026-08-31 -->

* An extension on the pgEdge privileged-extension allowlist installs as
  `admin`, and `app` is refused. The installed extension ends up owned by
  `postgres` rather than by either role, which is what `\dx` shows
  afterwards.
  <!-- M:211-216, re-measured 2026-08-31 -->

* An extension that Postgres itself marks trusted installs as either role,
  because `admin` is a member of `app`. The role that runs the install owns
  the extension afterwards. See
  [Which Role Creates Objects](../../roles.md#which-role-creates-objects).
  <!-- measured 2026-08-31 and 2026-09-01 -->

## The Extensions and How to Get Them

Connect as the named role and run the statement. Anything already installed
needs nothing at all.
<!-- measured 2026-08-31 on PostgreSQL 18.4: \dx on a fresh database, then
     every install attempted as both roles -->

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
<!-- M:233-234, re-measured 2026-08-31 -->
<!-- measured 2026-08-31 on PostgreSQL 18.4; there is no published allowlist
     to quote, so the table lists what the console credentials install -->

## The Refusal Message

A refused install answers `Must be superuser to create this extension`. As
`app` that means the extension is either allowlisted or unavailable, so try
again as `admin`. An extension that answers the same way as `admin` cannot be
installed by any role on the database.
<!-- measured 2026-08-31 and 2026-09-01: exact HINT text, both roles -->

## Who Installs It Owns It

A trusted extension belongs to the role that installed it, and a migration
can only manage an extension its own role owns. Most migration tools connect
as `app`, so install trusted extensions such as `pgcrypto` and `citext` as
`app`, or let the migration's own `CREATE EXTENSION IF NOT EXISTS` line do
it. Allowlisted extensions always end up owned by `postgres` no matter who
installs them, so for those the role makes no difference to ownership.
<!-- measured 2026-08-31: extowner is the installing role for trusted
     extensions, postgres for allowlisted ones -->

## Installing in Order

A schema and data load that needs extensions from both halves of the table
needs the `admin` connection once, before anything else:

1. Connect as `admin` and install the allowlisted extensions the schema
   depends on.

2. Connect as `app`, install the trusted ones, then load the schema and the
   data.

Loading a schema before its extensions exist fails the same way loading it as
the wrong role does.
<!-- M:244-246 -->

## Next Steps

* [Database Roles](../../roles.md) covers what each of the two roles can do
  beyond installing extensions.

* [Loading Data into Your pgEdge Starfleet Database](../../loading_data.md)
  covers the full load sequence and the `pg_restore` flag that half-succeeds.
