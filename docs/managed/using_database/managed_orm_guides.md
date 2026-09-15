# ORM and Framework Guides

This page discusses how to connect an ORM or a web framework to a pgEdge
Starfleet database: where each one reads its Postgres URL, why the
`sslmode=require` on the end of the string matters, and what happens when a
generated migration runs `CREATE EXTENSION`.

Nothing in a pgEdge Starfleet connection string is unique to pgEdge, so no
adapter, driver patch, or extra package is required for connection.

## Getting the Connection String

The `Connect` pane on your database's page displays the connection
string. Use the `Application` tab, which displays connection details for
the `app` role. `app` owns the database, and an object belongs to the
role that created it, so a framework connected as `app` owns every table
its migrations create and can alter or drop them later.

For more information about the `Connect` pane, see
[The Connect Pane](../using_console/managed_console_overview.md#the-connect-pane).
For more information about default role permissions, see
[Managing Database Roles](managed_roles.md).

Every recipe below reads the connection string from `DATABASE_URL`. Put
the string there via a secrets mechanism rather than an exported shell
variable. Single-quote the value if you write it into an env file, since
a password may carry `$`, and a double-quoted value is expanded by the
shell that sources the file.

Keep the whole string, including its query string. The console always
appends `sslmode=require`, and a URI trimmed back to its host and database
silently drops that setting. Starfleet hosts serve TLS with a valid,
CA-signed certificate, so `require` works from every client, and you may
want to use a stricter mode instead.

The console provides a URL, not discrete `PG*` values. A framework that
wants separate host, port, user, and password parameters needs the
string split into components, and the `Connect` pane shows each part on
its own row. The Django section below uses the split form.

### Checking the String with psql

Using the `Connect` pane's `psql command` block is the quickest way to test the
string before implementing a framework. A row returned by a [`SELECT
version()`](https://www.postgresql.org/docs/current/functions-info.html#FUNCTIONS-INFO-VERSION)
query will let you know that the host details resolve, the TLS handshake
completes, and the role can authenticate with the Postgres server. A
framework that fails when the psql check succeeds is failing on its own
configuration rather than on the database. See
[Connecting with psql](../connecting/managed_psql.md).

## Extensions in Migrations

`CREATE EXTENSION IF NOT EXISTS pgcrypto` is what most ORM migrations ship,
and on pgEdge Starfleet it succeeds when run as `app`, which then owns
the extension and can drop it in a later migration. `vector` is the
other way around: only `admin` can install it.

Neither role is a superuser. An extension Postgres marks trusted, such as
`pgcrypto`, `citext`, or `hstore`, installs as `app`. An extension on the
pgEdge allowlist, such as `vector`, `postgis`, or `pg_cron`, installs as
`admin` only, and `app` is refused with `Must be superuser to create this
extension`. The full table, the refusal messages, and the install order are
in [Installing Extensions](managed_extensions.md).

A migration run with the `Application` tab's string installs `pgcrypto`
without trouble, because that string connects as the `app` role. A
migration that also needs an allowlisted extension such as `vector`,
`postgis`, or `pg_cron` fails, because `app` cannot install those.
Install those manually on the `Admin` tab before running the migration.

## Prisma

Prisma takes the URL from the datasource block in `schema.prisma`, and the
generated block already points at an environment variable:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

Set `DATABASE_URL` to the string the console provided. Prisma's own default is
`sslmode=prefer`, which accepts a plain-text connection when TLS is not
available, so the `sslmode=require` on the end of the console's string is what
holds the connection encrypted.

The [Prisma PostgreSQL connector reference][prisma-pg] lists the other
arguments Prisma reads from the query string.

A Prisma migration that runs `CREATE EXTENSION pgcrypto` works against the
`Application` tab's string. One that runs `CREATE EXTENSION vector` does not.

## Drizzle

Drizzle connects through the `pg` driver, which parses the URI itself, so the
string passes directly into the constructor:

```ts
import { drizzle } from 'drizzle-orm/node-postgres';

const db = drizzle(process.env.DATABASE_URL);
```

Drizzle Kit holds its own copy for migrations, under `dbCredentials` in
`drizzle.config.ts`:

```ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  dialect: 'postgresql',
  dbCredentials: { url: process.env.DATABASE_URL },
});
```

Both read the same variable, so one env file covers the application and the
migration tool, and both connect as `app`. The
[Drizzle Postgres guide][drizzle-pg] describes the driver alternatives.
A Drizzle migration carrying `CREATE EXTENSION pgcrypto` works using
that shared `DATABASE_URL`. An allowlisted extension has to be
installed on the `Admin` tab first.

## Django

Django reads discrete parameters from the `DATABASES` setting rather than a
URL, so the string has to be split or parsed. The split version reads the
parts of the console's string from the standard `PG*` environment variables,
which every libpq client also honors:

```python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ["PGDATABASE"],
        "USER": os.environ["PGUSER"],
        "PASSWORD": os.environ["PGPASSWORD"],
        "HOST": os.environ["PGHOST"],
        "PORT": os.environ["PGPORT"],
        "OPTIONS": {"sslmode": "require"},
    }
}
```

Django's Postgres backend passes `OPTIONS` to the driver's connection
constructor, which is why the TLS setting sits there rather than beside the
host.

Keep the `sslmode` entry, because it is the split-parameter form of the
`sslmode=require` the console appends.

The alternative is dj-database-url, which parses a URI into the same
dictionary and reads `DATABASE_URL` by default:

```python
import dj_database_url

DATABASES = {"default": dj_database_url.config()}
```

The [Django databases reference][django-db] describes what else the
backend accepts. A Django migration whose operations include
`CREATE EXTENSION pgcrypto` runs as `app` and succeeds. An allowlisted
extension needs the `Admin` tab first.

## Ruby on Rails

Active Record reads `DATABASE_URL` from the environment with no
configuration, so that variable and an empty `config/database.yml` are
enough to connect. A `url` key in the YAML takes precedence over the
variable.

Reading the variable through ERB pins one environment to one connection
without committing the string:

```yaml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

The [Rails configuration guide][rails-db] describes how the two sources are
merged. A Rails migration that enables `pgcrypto` runs as `app` and succeeds.
One that enables an allowlisted extension does not, so install that on the
`Admin` tab before running `db:migrate`.

## SQLAlchemy and Alembic

SQLAlchemy builds an engine from the URI directly:

```python
import os
from sqlalchemy import create_engine

engine = create_engine(os.environ["DATABASE_URL"])
```

Alembic reads the URL from the `sqlalchemy.url` key of `alembic.ini`, a file
most projects commit, and a live password does not belong in a committed file.

Set the value at run time from `env.py` instead:

```python
import os
from alembic import context

context.config.set_main_option(
    "sqlalchemy.url", os.environ["DATABASE_URL"])
```

The [Alembic tutorial][alembic-tut] describes the rest of that file. An
Alembic revision issuing `CREATE EXTENSION pgcrypto` runs as `app` and
succeeds. An allowlisted extension needs the `Admin` tab first.

## After a Password Rotation

A string an application already holds stops working when someone selects
`Rotate credentials` on the `Application` tab of the `Connect` pane. The
new password does not authenticate until the database returns to
`Available`, and the old one may still work in that window, so switch
the application over once the status reads `Available` rather than
immediately.

Rotating the `app` password also restarts the database's MCP and RAG
servers; each server reads the password once at startup.

## Next Steps

* [Connecting to a pgEdge Starfleet Database](../connecting/managed_index.md)
  describes connecting with psql, pgAdmin, and the AI DBA Workbench.
* [Managing Database Roles](managed_roles.md) describes the two roles.
* [Loading Data into Your pgEdge Starfleet Database](managed_loading_data.md)
  describes the first data load, which usually happens before the
  first migration.
* [Installing Extensions](managed_extensions.md) describes which role installs
  which extension and what the refusal message means.
* [Restoring from Backup](../using_console/managed_backups.md) describes
  restoring in place after a migration goes wrong.
* [Enabling and Using the MCP Server](../serving_ai_content/managed_mcp.md)
  describes the server that a rotation of `app` restarts.

[prisma-pg]: https://www.prisma.io/docs/orm/overview/databases/postgresql
[drizzle-pg]: https://orm.drizzle.team/docs/get-started-postgresql
[django-db]: https://docs.djangoproject.com/en/stable/ref/databases/
[rails-db]: https://guides.rubyonrails.org/configuring.html#configuring-a-database
[alembic-tut]: https://alembic.sqlalchemy.org/en/latest/tutorial.html
