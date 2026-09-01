# Loading Data into Your pgEdge Starfleet Database

A pgEdge Starfleet database is a standard PostgreSQL database, so you can load
data into it with any tool that works with Postgres over a libpq connection.
On this page, we'll discuss loading data with `psql`, restoring from an
existing Postgres database, and loading documents for the RAG server.

Creating new tables requires the `app` user (the `Application` tab
credentials); either the `admin` or `app` user can insert data into tables
that already exist. For details, see the permissions table in
[Connecting with psql](connecting/psql.md).

## Loading CSV Data with `\copy`

Because pgEdge Starfleet is a managed service, you don't have access to the
database server's filesystem, so the server-side SQL `COPY ... FROM
'/path/to/file'` command isn't available. You can use the psql's client-side
`\copy` meta-command instead; it reads the file from your local machine and
streams the data to the server over your existing connection.

For example, to load a CSV file named `customers.csv` (with a header row of
`id`, `name`, `email`) into a new `public.customers` table:

1. Connect with psql as `app` so you'll have sufficient permissions to create
   a new table:

    ```bash
    PGSSLMODE=require psql -U app -h <your-domain> -p 5432 -d <your-database>
    ```
   See [Connecting with psql](connecting/psql.md) for
   directions about finding the ready-to-use `psql command` for your database.

2. Create the target table on your database with a column for each data block
   in your CSV file:

    ```sql
    CREATE TABLE public.customers (
        id    integer PRIMARY KEY,
        name  text,
        email text
    );
    ```

3. Load the CSV file with `\copy`:

    ```
    \copy public.customers (id, name, email) FROM 'customers.csv' WITH (FORMAT csv, HEADER true)
    ```

4. Verify the data loaded:

    ```sql
    SELECT count(*) FROM public.customers;
    ```

If you're loading into a table that already exists, you can skip step 2 and
connect as either `admin` or `app` in step 1. `\copy` accepts the same
options as the SQL `COPY` command; for the full list, see the Postgres
documentation for [COPY](https://www.postgresql.org/docs/current/sql-copy.html).

## Restoring from a pg_dump Backup

If you're migrating data from an existing Postgres database, use `pg_dump` on
the source database to create a dump file:

```bash
pg_dump --format=custom --file=mydata.dump "postgresql://user@oldhost:5432/olddb"
```

Then use `pg_restore` to load it into your pgEdge Starfleet database. Because
restoring a dump creates tables and other objects, connect as `app`, using the
connection string from the `Application` tab of the `Connect` pane:

```bash
pg_restore --no-owner --role=app \
  -d "postgresql://app@<your-domain>:5432/<your-database>?sslmode=require" \
  mydata.dump
```

`pg_dump` and `pg_restore` are ordinary Postgres clients, so the same
connection requirements described in
[Connecting to a pgEdge Starfleet Database](connecting/index.md) apply (SSL
required, GSS encoding disabled). The `--no-owner` flag skips restoring the
original ownership of dumped objects, and `--role=app` assigns ownership of
restored objects to `app` instead; the roles that existed on the source
database (other than `admin` and `app`) don't exist on your pgEdge Starfleet
database.

## Loading Documents for the RAG Server

The methods above load structured, relational data into tables. If you're
loading unstructured documents (HTML, Markdown, or reStructuredText) to use
with a RAG server, use `pgedge-docloader` instead; see
[Using the RAG Server](managed/using/services/rag.md#using-the-rag-server).
Because the docloader creates a `documents` table, configure it with the
`app` user's connection details, not `admin`.
