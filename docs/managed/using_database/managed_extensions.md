# Installing Supported Extensions on a pgEdge Starfleet Managed Database

You can add Postgres extensions to a pgEdge Starfleet Managed database
with psql, connected as `app` or `admin`, two of the database's built-in
roles. Four terms recur below:

- `app` owns the database. Your application connects with this role,
  and so do the migrations it runs.
- `admin` is another built-in role that installs the extensions `app`
  is not permitted to install. Neither role is a superuser.
- The tables below name every supported extension. Managed does not
  support an extension they omit.
- The `Connect` pane on the database page shows a connection string for
  each role. The `Application` tab holds the `app` string, and the
  `Admin` tab holds the `admin` string.

## Before You Start

In the console, open the database page by selecting the database name
under `Databases` in the navigation pane. The `Connect` pane sits below
the page header.

The database must show the `available` status. The database's IP
allowlist must also include the address of your machine, or psql
cannot reach the database.
[Controlling Network Access](managed_network_access.md) describes how
to add that address.

You need psql on the machine you connect from.
[Connecting with psql](../connecting/managed_psql.md) describes how to
install it.

## Finding the Supported Extensions

Three extensions are already installed on every Managed database:

| Extension | What it provides |
|---|---|
| plpgsql | PL/pgSQL, the default procedural language for functions. |
| pg_stat_statements | Statistics for executed queries, which both `app` and `admin` can read. |
| pgaudit | Audit logging. pgEdge configures it, and you install nothing. |

Install each extension in the next table as `app`. The extension then
belongs to `app`, so your migrations can later change or remove it.
Installed as `admin` instead, the extension belongs to `admin`, and a
migration running as `app` cannot change or remove it.

| Extension | What it provides |
|---|---|
| btree_gin | GIN index support for common scalar types. |
| btree_gist | GiST index support for common scalar types. |
| citext | A text type that compares without regard to case. |
| cube | A data type for multidimensional cubes. |
| dict_int | Full-text search handling for integer tokens. |
| fuzzystrmatch | Functions for string similarity and sound-alike matching. |
| hstore | A data type for sets of key and value pairs. |
| intarray | Operators and index support for integer arrays. |
| isn | Data types for ISBN, ISSN and other product numbering standards. |
| lo | A `lo` data type and a trigger that removes orphaned large objects. |
| ltree | A data type for labels arranged in a tree. |
| pg_trgm | Similarity search based on trigrams. |
| pgcrypto | Hashing and encryption functions. |
| pgmq | A message queue stored in Postgres tables. |
| seg | A data type for floating-point intervals and line segments. |
| tablefunc | Functions that return tables, including crosstab. |
| tcn | A trigger function that sends a notification when a table changes. |
| tsm_system_rows | A `TABLESAMPLE` method that stops after a set number of rows. |
| tsm_system_time | A `TABLESAMPLE` method that stops after a set time. |
| unaccent | A full-text search dictionary that removes accents. |
| uuid-ossp | Functions that generate UUIDs. |

Install each extension in the next table as `admin`. The extension then
belongs to `postgres`, and queries run as `app` still work with it:

| Extension | What it provides |
|---|---|
| vector | Vector types with distance operators, and HNSW and IVFFlat indexes. |
| postgis | Geometry and geography types with spatial functions. |
| postgis_raster | Raster support for PostGIS. |
| postgis_sfcgal | Advanced 2D and 3D geometry functions from the SFCGAL library. |
| postgis_topology | Topology types and functions for PostGIS. |
| postgis_tiger_geocoder | US address normalization for PostGIS. Install postgis and fuzzystrmatch first. |
| address_standardizer | Address parsing into its parts. Install address_standardizer_data_us with it. |
| address_standardizer_data_us | US rules and lexicons for address_standardizer. |
| pg_cron | Scheduled jobs, run in the database. |
| pg_tokenizer | Text tokenizers for full-text search. |
| vchord_bm25 | BM25 ranking and indexes for full-text search. A query needs `bm25_catalog` and `tokenizer_catalog` on the `search_path`. |

Every extension behaves the same way on Postgres 16, 17 and 18.

## Installing an Extension

Before you load a schema, install each extension that the schema
depends on. Otherwise the load fails when it reaches an object that
needs a missing extension.

1. On the `Connect` pane, select the `Application` tab.

2. Select the copy icon at the right end of the `Connection string` field.

    The copied string includes the `app` password, although the screen
    hides the password.

3. Install an extension that the `app` table names, replacing
   `<app-connection-string>` with the string you copied:

        psql "<app-connection-string>" \
            -c 'CREATE EXTENSION IF NOT EXISTS pgcrypto'

    psql prints `CREATE EXTENSION`. Never install pgmq with the `admin`
    string, because pgmq installed that way refuses `app` access to its
    queues.

4. Select the `Admin` tab, then select the copy icon at the right end of
   the `Connection string` field.

5. Install an extension that the `admin` table names, replacing
   `<admin-connection-string>` with the `admin` string:

        psql "<admin-connection-string>" \
            -c 'CREATE EXTENSION IF NOT EXISTS vector'

6. Confirm the owner of each installed extension:

        psql "<app-connection-string>" \
            -c 'SELECT extname, extowner::regrole FROM pg_extension'

    An extension from the `app` table shows `app`, and an extension
    from the `admin` table shows `postgres`. The psql `\dx` command
    lists extensions without their owners.

## Troubleshooting

Each of the following errors means psql refused the install and exited
with status 1.

### Install as `app` Fails with "Must be superuser"

psql prints `permission denied to create extension "<name>"` with the
hint `Must be superuser to create this extension`. `app` cannot
install that extension. Where the `admin` table names the extension,
install it with the `admin` string instead.

### Install as `admin` Fails with "Must be superuser"

psql prints the same message and hint while connected as `admin`. No
role on Managed has permission to install that extension. Take that
dependency out of the schema, then load the schema.

### Install Fails with "is not available"

psql prints `extension "<name>" is not available`. Managed does not
include that extension. Remove that extension from the schema before
you load it.

## Next Steps

[Loading Data into Your pgEdge Starfleet Database](managed_loading_data.md)
describes how to load a schema and its data after you install the
extensions the schema needs.
