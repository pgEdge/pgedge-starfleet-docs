# Installing Extensions

Before using an extension, you must install it in your Postgres database.
The list of available extensions may vary depending on the version of
Postgres installed.

!!! hint

    Use the `psql command` displayed on the `Application` tab of the
    `Connect` pane to connect with psql and query the extensions; see
    [Connecting with psql](../connecting/managed_psql.md) to find the pane and
    copy the command.

To find the list of extensions available, connect with a Postgres client
and query the `pg_available_extensions` view:

```sql
SELECT name, default_version, installed_version, comment
FROM pg_available_extensions
ORDER BY name;
```

This query returns every extension the Postgres server recognizes, along
with its default version, a short description, and its installed
version. `installed_version` is `NULL` for an extension that is
available but not installed.

To create an extension in your Postgres database, use the
[`CREATE EXTENSION`](https://www.postgresql.org/docs/current/sql-createextension.html)
command with a Postgres client such as psql. For example, the following
statement creates the `hstore` extension, making it available for use in
your database:

```sql
CREATE EXTENSION hstore;
```

## Choosing the Role to Install an Extension

The role required to install an extension varies by extension:

* an extension on the pgEdge privileged-extension allowlist installs
  as `admin` only, and `app` is refused; the extension is owned by
  `postgres` rather than by either role, which is what `\dx` shows
  afterward.
* an extension that Postgres itself marks trusted installs as either
  role, because `admin` is a member of `app`, and the role that runs
  the install owns the extension afterward.

See [Creating Database Objects](managed_roles.md#creating-database-objects)
for more on how role ownership works.

For example, the following table lists the installation role and
behavior for some popular extensions. This list is subject to change:

| Extension | Installation |
|---|---|
| `plpgsql` | No action required; installed on every database. |
| `pg_stat_statements` | No action required; installed on every database. |
| `pgaudit` | No action required; installed on every database. |
| `vector` | `CREATE EXTENSION vector` as `admin`. |
| `vchord_bm25` | `CREATE EXTENSION vchord_bm25` as `admin`. |
| `postgis` | `CREATE EXTENSION postgis` as `admin`. |
| `pg_cron` | `CREATE EXTENSION pg_cron` as `admin`. |
| `pgcrypto` | `CREATE EXTENSION pgcrypto` as either role. Prefer `app`. |
| `citext` | `CREATE EXTENSION citext` as either role. Prefer `app`. |
| `hstore` | `CREATE EXTENSION hstore` as either role. Prefer `app`. |
| `ltree` | `CREATE EXTENSION ltree` as either role. Prefer `app`. |
| `pg_trgm` | `CREATE EXTENSION pg_trgm` as either role. Prefer `app`. |

To install an extension that the table does not list, attempt the
installation and review the resulting message. A refused installation
attempt returns `Must be superuser to create this extension`; what
that means depends on the role that attempted the install:

* connected as `app`, the extension is either allowlisted or
  unavailable; try again as `admin`.
* connected as `admin` and refused again, the extension cannot be
  installed by any role on the database.

## Migration Considerations

Migrating a schema and its data onto pgEdge Starfleet raises two
considerations beyond a single extension install: the order in which you
connect to install extensions, and which role owns them afterward.

### Installing Extensions in Order

If a schema and data load needs both an allowlisted extension and a
trusted extension, install the allowlisted extension first:

1.  Connect as `admin` and install the allowlisted extensions the schema
    depends on.

2.  Connect as `app`, install the trusted ones, then load the schema and the
    data.

Loading a schema before its extensions exist causes the load to fail. See
[Loading Data into Your pgEdge Starfleet Database](managed_loading_data.md) for the
complete load sequence.

### Extension Ownership in Migrations

Most migration tools connect as `app`, so install trusted extensions such as
`pgcrypto` and `citext` as `app`, or let the migration's own
`CREATE EXTENSION IF NOT EXISTS` syntax manage the installation. Allowlisted
extensions are always owned by `postgres` regardless of who installs them,
so the role makes no difference to their ownership.

## Reference: Available Extensions

The following table lists every extension available on a pgEdge
Starfleet database, as returned by the `pg_available_extensions` query
described above. `Installed Version` is `-` for an extension that is
available but not installed. The list can change as pgEdge Starfleet
upgrades Postgres or updates the underlying extension set; query
`pg_available_extensions` yourself for the current list.

| Extension | Default Version | Installed Version | Description |
|---|---|---|---|
| `address_standardizer` | 3.6.4 | - | Used to parse an address into constituent elements. Generally used to support geocoding address normalization step. |
| `address_standardizer_data_us` | 3.6.4 | - | Address Standardizer US dataset example |
| `amcheck` | 1.4 | - | functions for verifying relation integrity |
| `autoinc` | 1.0 | - | functions for autoincrementing fields |
| `bloom` | 1.0 | - | bloom access method - signature file based index |
| `btree_gin` | 1.3 | - | support for indexing common datatypes in GIN |
| `btree_gist` | 1.7 | - | support for indexing common datatypes in GiST |
| `citext` | 1.6 | - | data type for case-insensitive character strings |
| `cube` | 1.5 | - | data type for multidimensional cubes |
| `dblink` | 1.2 | - | connect to other PostgreSQL databases from within a database |
| `dict_int` | 1.0 | - | text search dictionary template for integers |
| `dict_xsyn` | 1.0 | - | text search dictionary template for extended synonym processing |
| `earthdistance` | 1.2 | - | calculate great-circle distances on the surface of the Earth |
| `file_fdw` | 1.0 | - | foreign-data wrapper for flat file access |
| `fuzzystrmatch` | 1.2 | - | determine similarities and distance between strings |
| `hstore` | 1.8 | - | data type for storing sets of (key, value) pairs |
| `hstore_plperl` | 1.0 | - | transform between hstore and plperl |
| `hstore_plperlu` | 1.0 | - | transform between hstore and plperlu |
| `insert_username` | 1.0 | - | functions for tracking who changed a table |
| `intagg` | 1.1 | - | integer aggregator and enumerator (obsolete) |
| `intarray` | 1.5 | - | functions, operators, and index support for 1-D arrays of integers |
| `isn` | 1.2 | - | data types for international product numbering standards |
| `jsonb_plperl` | 1.0 | - | transform between jsonb and plperl |
| `jsonb_plperlu` | 1.0 | - | transform between jsonb and plperlu |
| `lo` | 1.1 | - | Large Object maintenance |
| `lolor` | 1.2.2 | - | Large Objects support for logical replication |
| `ltree` | 1.3 | - | data type for hierarchical tree-like structures |
| `moddatetime` | 1.0 | - | functions for tracking last modification time |
| `pageinspect` | 1.12 | - | inspect the contents of database pages at a low level |
| `pg_buffercache` | 1.5 | - | examine the shared buffer cache |
| `pg_cron` | 1.6 | - | Job scheduler for PostgreSQL |
| `pg_freespacemap` | 1.2 | - | examine the free space map (FSM) |
| `pg_prewarm` | 1.2 | - | prewarm relation data |
| `pg_stat_monitor` | 2.3 | - | The pg_stat_monitor is a PostgreSQL Query Performance Monitoring tool, based on PostgreSQL contrib module pg_stat_statements. pg_stat_monitor provides aggregated statistics, client information, plan details including plan, and histogram information. |
| `pg_stat_statements` | 1.11 | 1.11 | track planning and execution statistics of all SQL statements executed |
| `pg_surgery` | 1.0 | - | extension to perform surgery on a damaged relation |
| `pg_tokenizer` | 0.1.1 | - | pg_tokenizer |
| `pg_trgm` | 1.6 | - | text similarity measurement and index searching based on trigrams |
| `pg_visibility` | 1.2 | - | examine the visibility map (VM) and page-level visibility info |
| `pg_walinspect` | 1.1 | - | functions to inspect contents of PostgreSQL Write-Ahead Log |
| `pgaudit` | 17.1 | 17.1 | provides auditing functionality |
| `pgcrypto` | 1.3 | - | cryptographic functions |
| `pgedge_safesession` | 1.0 | - | Enforce read-only sessions for specified roles |
| `pgedge_vectorizer` | 1.1 | - | Asynchronous text chunking and vectorization for PostgreSQL |
| `pgmq` | 1.12.0 | - | A lightweight message queue. Like AWS SQS and RSMQ but on Postgres. |
| `pgrowlocks` | 1.2 | - | show row-level locking information |
| `pgstattuple` | 1.5 | - | show tuple-level statistics |
| `plpgsql` | 1.0 | 1.0 | PL/pgSQL procedural language |
| `postgis` | 3.6.4 | - | PostGIS geometry and geography spatial types and functions |
| `postgis_raster` | 3.6.4 | - | PostGIS raster types and functions |
| `postgis_sfcgal` | 3.6.4 | - | PostGIS SFCGAL functions |
| `postgis_tiger_geocoder` | 3.6.4 | - | PostGIS tiger geocoder and reverse geocoder |
| `postgis_topology` | 3.6.4 | - | PostGIS topology spatial types and functions |
| `postgres_fdw` | 1.1 | - | foreign-data wrapper for remote PostgreSQL servers |
| `refint` | 1.0 | - | functions for implementing referential integrity (obsolete) |
| `seg` | 1.4 | - | data type for representing line segments or floating-point intervals |
| `snowflake` | 2.6.0 | - | Snowflake style IDs for PostgreSQL |
| `spock` | 5.0.11 | - | PostgreSQL Logical Replication |
| `sslinfo` | 1.2 | - | information about SSL certificates |
| `system_stats` | 4.0 | - | EnterpriseDB system statistics for PostgreSQL |
| `tablefunc` | 1.0 | - | functions that manipulate whole tables, including crosstab |
| `tcn` | 1.0 | - | Triggered change notifications |
| `tsm_system_rows` | 1.0 | - | TABLESAMPLE method which accepts number of rows as a limit |
| `tsm_system_time` | 1.0 | - | TABLESAMPLE method which accepts time in milliseconds as a limit |
| `unaccent` | 1.1 | - | text search dictionary that removes accents |
| `uuid-ossp` | 1.1 | - | generate universally unique identifiers (UUIDs) |
| `vchord_bm25` | 0.2.2 | - | vchord_bm25: A postgresql extension for bm25 ranking algorithm |
| `vector` | 0.8.5 | - | vector data type and ivfflat and hnsw access methods |
| `vectorize` | 0.23.0 | - | The simplest way to do vector search on Postgres |
| `xml2` | 1.1 | - | XPath querying and XSLT |