# Loading Data into Your pgEdge Starfleet Database

A pgEdge Starfleet database is a standard PostgreSQL database; you can
load data into it with any tool designed for use with Postgres over a
libpq connection. The sections below cover loading data with `psql`,
restoring from an existing Postgres database, and loading documents
for the RAG Server.

You should load schema and data as the `app` user (using the `Application`
tab credentials for your connection), so that every object is owned by the
role your application connects as. The `admin` user can insert data into
tables that already exist. For more information about each role, see
[Managing Database Roles](roles.md).

## Loading CSV Data with `\copy`

You can use psql's client-side `\copy` meta-command to load data from a CSV
file; `\copy` reads the file from your local machine and streams the data to
the server over your existing connection.

For example, to load a CSV file named `customers.csv` (with a header row of
`id`, `name`, `email`) into a new `public.customers` table:

1.  Connect with psql as `app` so you will have sufficient permissions to
    create a new table:

    ```bash
    PGSSLMODE=require psql -U app -h <your-domain> -p <your-port> -d <your-database>
    ```

    See [Connecting with psql](../connecting/psql.md) for detailed
    information about finding the ready-to-use `psql command` for your
    database.

2.  Create the target table on your database with a column for each field
    in your CSV file:

    ```sql
    CREATE TABLE public.customers (
        id    integer PRIMARY KEY,
        name  text,
        email text
    );
    ```

3.  Load the CSV file with `\copy`:

    ```sql
    \copy public.customers (id, name, email) FROM 'customers.csv' WITH (FORMAT csv, HEADER true)
    ```

4.  Verify that the data loaded:

    ```sql
    SELECT count(*) FROM public.customers;
    ```

If you are loading data into a table that already exists, you can
skip step 2 and connect as either `admin` or `app` in step 1. `\copy`
accepts the same options as the SQL
[`COPY`](https://www.postgresql.org/docs/current/sql-copy.html)
command; see the linked Postgres documentation for the complete list
of available options.

## Restoring from a pg_dump Backup

Moving an existing schema and its data onto pgEdge Starfleet requires both of
the database's built-in roles, in a fixed order.

Before you begin, gather:

* a database with an `available` status.
* the credentials on both the `Admin` tab and the `Application` tab of the
  database `Connect` pane.
* a backup of the source database, taken with `pg_dump`.
* `psql` and `pg_restore` from a PostgreSQL client installation.

!!! hint

    Copy the `psql command` from each tab rather than assembling one
    yourself. The `psql command` already includes the TLS setting as
    `PGSSLMODE=require` and fills in the password when copied. Keep both
    `psql command` values out of your shell history and out of any file
    you commit.

Create the dump on the source database with
[`pg_dump`](https://www.postgresql.org/docs/current/app-pgdump.html):

```bash
pg_dump --format=custom --file=mydata.dump "postgresql://user@oldhost:5432/olddb"
```

### Installing Extensions Before Restoring

Applications connect as `app`, and the `app` user owns the database and its
objects, such as tables, views, and foreign keys. If you restore a `pg_dump`
file as `admin` instead, `admin` will own the tables and other objects the
file creates, and your application will not have the correct access to them.

Extensions fall into two categories, based on which role can install them.
An extension on the pgEdge allowlist installs as `admin` only. An extension
Postgres itself marks trusted installs as `app`.

A load that needs both kinds of extension therefore requires both
connections, in this order:

1.  Connect with the `Admin` tab's details and install the allowlisted
    extensions the dump depends on, such as `vector`.

2.  Connect with the `Application` tab's details and install the trusted ones,
    such as `pgcrypto`.

3.  Still as `app`, load the schema.

4.  Still as `app`, load the data, in the passes described below.

Loading a schema before its dependent extensions exist fails on the first
object that needs one.

For more information about extension ownership, see
[Installing Extensions](extensions.md).

### Restoring the Schema's Dump File

Restoring a dump creates tables and other objects; you should connect as `app`,
using the connection string from the `Application` tab of the `Connect` pane:

```bash
pg_restore --schema-only --no-owner --no-acl --role=app \
  -d "postgresql://app@<your-domain>:<your-port>/<your-database>?sslmode=require" \
  mydata.dump
```

The `--no-owner` flag skips restoring the original ownership of dumped objects,
and `--role=app` assigns ownership of restored objects to `app` instead. This
is necessary because roles that existed on the source database (other than
`admin` and `app`) may not exist on your pgEdge Starfleet database.

Load the database schema as shown above, followed by data in separate passes.
A one-shot restore of both schema and data encounters the foreign-key problem
described next.

`pg_restore --disable-triggers` cannot work on pgEdge Starfleet.

!!! hint

    `ALTER TABLE ... DISABLE TRIGGER ALL` and the workaround `SET
    session_replication_role = replica` both require superuser privileges,
    which neither `admin` nor `app` has; every disable and re-enable statement
    therefore errors, so foreign keys remain enforced for the whole load.

    Because `pg_restore` loads tables in the dump's table-of-contents order
    rather than your `-t` flag order, a child table can load before its parent.
    Its `COPY` then aborts on the foreign-key violation, `pg_restore` continues
    with the remaining tables, and the run exits with status `1`: most tables
    are populated, but the child table is silently left empty.

### Loading the Data Parent-First

Before loading, determine your schema's foreign-key dependencies. Run one
`pg_restore` pass per dependency level, putting tables with no foreign key
between them in the same pass, so that a table's foreign keys are already
satisfied by the time its pass runs. In the following command examples,
`$APP_URL` contains the connection string from the `Application` tab, kept
in an environment variable so the password stays out of the argument list:

```bash
pg_restore -d "$APP_URL" --data-only --no-owner --no-acl \
    -t game_systems -t rulebook_sources dump.pgc
pg_restore -d "$APP_URL" --data-only --no-owner --no-acl \
    -t rulebook_sections dump.pgc
```

An alternative is to drop the foreign-key constraints as `app` (which
owns the underlying tables), load the data in one pass, and add the
constraints back afterward.

### Verifying the Data Load

Compare your row count against the source row count when the load finishes. A
`pg_restore` that exits with status `1` has still written every row that
did not error, so a partial success is not something you should treat as
complete.

Run the following `count` query as `app`, from the `psql command` on the
`Application` tab:

```sql
SELECT count(*) FROM rulebook_sections;
```

Then, compare each table against the source. Neither the exit code nor the
console status distinguishes a table left at zero rows from the tables
that loaded successfully.

## Loading Documents for the RAG Server

The methods above load structured, relational data into tables. If you are
loading unstructured documents (HTML, Markdown, or reStructuredText) to use
with a RAG Server, use `pgedge-docloader` instead. See
[Using the RAG Server](../serving_ai_content/rag.md#using-the-rag-server).
Since the docloader creates a `documents` table, configure the docloader
with the `app` user's connection details, not `admin`.

