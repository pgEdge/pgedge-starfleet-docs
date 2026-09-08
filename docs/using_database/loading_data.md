# Loading Data into Your pgEdge Starfleet Database

A pgEdge Starfleet database is a standard PostgreSQL database, so you can load
data into it with any tool that works with Postgres over a libpq connection.
This page discusses loading data with `psql`, restoring from an existing
Postgres database, and loading documents for the RAG server.

You should load schema and data as the `app` user (the `Application` tab
credentials), so that every object ends up owned by the role your application
connects as. The `admin` user can insert data into tables that already exist.
For what each role can do, see [Database Roles](roles.md).

## Loading CSV Data with `\copy`

Because pgEdge Starfleet is a managed service, you don't have access to the
database server's filesystem, so the server-side SQL
`COPY ... FROM '/path/to/file'` command isn't available. You can use psql's
client-side `\copy` meta-command instead; `\copy` reads the file from your
local machine and streams the data to the server over your existing connection.

For example, to load a CSV file named `customers.csv` (with a header row of
`id`, `name`, `email`) into a new `public.customers` table:

1.  Connect with psql as `app` so you'll have sufficient permissions to create
    a new table:

    ```bash
    PGSSLMODE=require psql -U app -h <your-domain> -p <your-port> -d <your-database>
    ```

    See [Connecting with psql](../connecting/psql.md) for directions about
    finding the ready-to-use `psql command` for your database.

2.  Create the target table on your database with a column for each data block
    in your CSV file:

    ```sql
    CREATE TABLE public.customers (
        id    integer PRIMARY KEY,
        name  text,
        email text
    );
    ```

3.  Load the CSV file with `\copy`:

    ```
    \copy public.customers (id, name, email) FROM 'customers.csv' WITH (FORMAT csv, HEADER true)
    ```

4.  Verify the data loaded:

    ```sql
    SELECT count(*) FROM public.customers;
    ```

If you're loading into a table that already exists, you can skip step 2 and
connect as either `admin` or `app` in step 1. `\copy` accepts the same options
as the SQL `COPY` command. For the complete list of available options, see the
Postgres documentation for
[COPY](https://www.postgresql.org/docs/current/sql-copy.html).

## Restoring from a pg_dump Backup

Moving an existing schema and its data onto pgEdge Starfleet takes both of the
database's built-in roles, in a fixed order.

### Gathering What You Need

Before you begin, gather the following:

* a database reporting `Available` in the console.
* both the `Admin` tab and the `Application` tab of its `Connect` pane, which
  give you two different users against the same host, port, and database.
* a dump of the source database, and `psql` and `pg_restore` from a PostgreSQL
  client installation.

Copy the `psql command` from each tab rather than assembling one; the
`psql command` already carries the TLS setting as `PGSSLMODE=require`, and it
fills the password in when you copy it.

Keep both out of your shell history and out of any file you commit.

Create the dump on the source database with `pg_dump`:

```bash
pg_dump --format=custom --file=mydata.dump "postgresql://user@oldhost:5432/olddb"
```

### Understanding Why the Order Matters

The `app` user owns the database, and an object belongs to the role that
created it, so a schema loaded as `admin` ends up owned by a role your
application never connects as.

Extensions fall into two categories, based on which role can install them: an
extension on the pgEdge allowlist installs as `admin` only, while an extension
Postgres itself marks trusted installs as `app`, which then owns it and can
drop it later.

A load that needs both kinds of extension therefore needs both connections, in
this order:

1.  Connect with the `Admin` tab's details and install the allowlisted
    extensions the dump depends on, such as `vector`.

2.  Connect with the `Application` tab's details and install the trusted ones,
    such as `pgcrypto`.

3.  Still as `app`, load the schema.

4.  Still as `app`, load the data, in the passes described below.

Loading a schema before the extensions it depends on exist fails on the first
object that needs one.

For which extension falls on which side, see
[Installing Extensions](extensions.md).

`pg_dump` and `pg_restore` are ordinary Postgres clients, so the same
connection requirements described in
[Connecting to a pgEdge Starfleet Database](../connecting/index.md) apply.

### Restoring the Schema

Because restoring a dump creates tables and other objects, connect as `app`,
using the connection string from the `Application` tab of the `Connect` pane:

```bash
pg_restore --schema-only --no-owner --no-acl --role=app \
  -d "postgresql://app@<your-domain>:<your-port>/<your-database>?sslmode=require" \
  mydata.dump
```

The `--no-owner` flag skips restoring the original ownership of dumped objects,
and `--role=app` assigns ownership of restored objects to `app` instead. The
roles that existed on the source database (other than `admin` and `app`) don't
exist on your pgEdge Starfleet database. The data passes below carry the same
`--no-owner` and `--no-acl` flags.

Load the schema on its own, as above, and the data in the separate passes
below. A one-shot restore of schema and data together runs into the foreign-key
problem described next.

### Avoid Using `--disable-triggers`

`pg_restore --disable-triggers` cannot work on pgEdge Starfleet.

The flag emits `ALTER TABLE ... DISABLE TRIGGER ALL`, which requires superuser
privileges. The usual workaround, `SET session_replication_role = replica`,
also requires superuser privileges. Since neither role on the database is a
Postgres superuser, every disable statement and every re-enable statement
errors. Foreign keys therefore stay enforced for the whole load.

`pg_restore` restores table data in the dump's table-of-contents order, not in
the order of the `-t` flags. A child table can therefore be loaded before its
parent, its `COPY` aborts on the foreign key, and `pg_restore` carries on with
the rest.

The result: `pg_restore` exits with status `1`, most tables are populated, and
one table is silently left empty.

### Loading the Data Parent-First

Run one `pg_restore` pass per level of the foreign-key graph, putting tables
with no foreign key between them in the same pass, so every key is satisfied as
its pass runs. `$APP_URL` holds the connection string from the `Application`
tab, kept in an environment variable so the password stays out of the argument
list:

```bash
pg_restore -d "$APP_URL" --data-only --no-owner --no-acl \
    -t game_systems -t rulebook_sources dump.pgc
pg_restore -d "$APP_URL" --data-only --no-owner --no-acl \
    -t rulebook_sections dump.pgc
```

The alternative is to drop the foreign-key constraints as `app`, which owns the
underlying tables, load in one pass, and add the constraints back afterwards.

### Checking the Row Counts Afterwards

Either way, count rows against the source when the load finishes. A
`pg_restore` that exits 1 has still written everything that did not error, so
"mostly succeeded" is not a result to act on.

Run the count as `app`, from the `psql command` on the `Application` tab:

```sql
SELECT count(*) FROM rulebook_sections;
```

Compare each table against the source. Neither the exit code nor the console
status reports a table left at zero rows beside tables that loaded.

## Loading Documents for the RAG Server

The methods above load structured, relational data into tables. If you're
loading unstructured documents (HTML, Markdown, or reStructuredText) to use
with a RAG server, use `pgedge-docloader` instead. See
[Using the RAG Server](../serving_ai_content/rag.md#using-the-rag-server).
Because the docloader creates a `documents` table, configure it with the `app`
user's connection details, not `admin`.
