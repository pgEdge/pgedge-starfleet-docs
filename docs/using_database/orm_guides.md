# ORM and Framework Guides

Every ORM and web framework connects to a pgEdge Starfleet database the same
way: over a standard Postgres connection string. What differs by framework is
where it reads that string, why `sslmode=require` at the end of it matters,
and how a generated migration handles `CREATE EXTENSION`.

Nothing in a pgEdge Starfleet connection string is unique to pgEdge, so you
do not need an adapter, driver patch, or extra package to connect.

## Getting the Connection String

Use the connection string on the `Application` tab of your database's
`Connect` pane, which displays connection details for the `app` role. The
`Connect` pane also has an `Admin` tab, with credentials for the `admin`
role; later sections use it to install extensions `app` cannot. `app` owns
the database; since an object belongs to its creating role, a framework
connected as `app` owns every table its migrations create and can alter
or drop them later.

Each example that follows reads the connection string from `DATABASE_URL`; for
security, put it there via a secrets mechanism rather than an exported
shell variable. Single-quote the value if you write it into an env file,
since a password may contain `$`, and a double-quoted value is expanded by
the shell that sources the file.

Keep the whole string, including the options. The console always appends
`sslmode=require`, and a URI trimmed back to its host and database
silently drops that setting. pgEdge Starfleet hosts serve TLS with a
valid, CA-signed certificate, so `require` works from every client,
though you may prefer a stricter mode.

The console provides a URL, not discrete `PG*` values. A framework that
requires separate host, port, user, and password parameters (such as
Django) must split the string into its components, and the `Connect` pane
displays each part on its own row.

### Checking the String with psql

Using the `Connect` pane's `psql command` block is the quickest way to
test the string before implementing a framework. A row returned by a
[`SELECT version()`](https://www.postgresql.org/docs/current/functions-info.html#FUNCTIONS-INFO-VERSION)
query confirms that the host details resolve, the TLS handshake
completes, and the role can authenticate with the Postgres server. If a
framework fails when the psql check succeeds, the problem lies in its
own configuration rather than in the database. See
[Connecting with psql](../connecting/psql.md).

## Extensions in Migrations

Most ORM migrations include `CREATE EXTENSION IF NOT EXISTS pgcrypto`,
which on pgEdge Starfleet succeeds when run as `app`, and `app` then owns
the extension and can drop it in a later migration. The reverse is true
for `vector`, which only `admin` can install.

Neither role is a superuser. An extension Postgres marks trusted, such as
`pgcrypto`, `citext`, or `hstore`, installs as `app`. An extension on the
pgEdge allowlist, such as `vector`, `postgis`, or `pg_cron`, installs as
`admin` only, and `app` is refused with `Must be superuser to create this
extension`. See [Installing Extensions](extensions.md) for the full table,
refusal messages, and install order.

A migration run with the `Application` tab's string installs `pgcrypto`
successfully, since that string connects as `app`. A migration that also
needs an allowlisted extension such as `vector`, `postgis`, or `pg_cron`
fails, because `app` cannot install it; connect with the `Admin` tab's
credentials and install that extension manually first.

## Prisma

Prisma reads the URL from the `datasource` block in `schema.prisma`. By
default, that block already points at an environment variable:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

Set `DATABASE_URL` to the string the console provided. Prisma's default is
`sslmode=prefer`, which allows a plain-text connection when TLS is
unavailable, so the `sslmode=require` on the end of the console's string
keeps the connection encrypted.

The [Prisma PostgreSQL connector reference][prisma-pg] lists the other
arguments Prisma reads from the query string.

A Prisma migration that runs `CREATE EXTENSION pgcrypto` works against the
`Application` tab's string. A migration that runs `CREATE EXTENSION vector`
does not.

## Drizzle

Drizzle connects through the `pg` driver, which parses the URI itself, so the
string passes directly into the constructor:

```ts
import { drizzle } from 'drizzle-orm/node-postgres';

const db = drizzle(process.env.DATABASE_URL);
```

Drizzle Kit keeps its own copy of the connection string for migrations,
under `dbCredentials` in `drizzle.config.ts`:

```ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  dialect: 'postgresql',
  dbCredentials: { url: process.env.DATABASE_URL },
});
```

Both Drizzle and Drizzle Kit read the same variable, so one env file covers
the application and the migration tool, and both connect as `app`. The
[Drizzle Postgres guide][drizzle-pg] describes the driver alternatives.
A Drizzle migration containing `CREATE EXTENSION pgcrypto` works with that
shared `DATABASE_URL`. Connect with the `Admin` tab's credentials to
install an allowlisted extension first.

## Django

Django reads discrete parameters from the `DATABASES` setting rather than a
URL, so the string must be split or parsed. The split version reads the
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
constructor; the TLS setting therefore sits inside `OPTIONS` rather than
beside the host.

Keep the `sslmode` entry, because it is the split-parameter form of the
`sslmode=require` the console appends.

The alternative is dj-database-url, which parses a URI into the same
dictionary and reads `DATABASE_URL` by default:

```python
import dj_database_url

DATABASES = {"default": dj_database_url.config()}
```

The [Django databases reference][django-db] describes the remaining
`DATABASES` options Django's Postgres backend accepts. A Django migration
whose operations include `CREATE EXTENSION pgcrypto` runs as `app` and
succeeds. Connect with the `Admin` tab's credentials to install an
allowlisted extension first.

## Ruby on Rails

Active Record reads `DATABASE_URL` from the environment with no
configuration, so that variable and an empty `config/database.yml` are
enough to connect. A `url` key in the YAML takes precedence over the
variable.

Reading the variable through ERB binds one environment to one connection
without committing the string:

```yaml
production:
  url: <%= ENV['DATABASE_URL'] %>
```

The [Rails configuration guide][rails-db] describes how the two sources are
merged. A Rails migration that enables `pgcrypto` runs as `app` and succeeds.
A migration that enables an allowlisted extension does not, so connect
with the `Admin` tab's credentials and install it before running
`db:migrate`.

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
succeeds. Connect with the `Admin` tab's credentials to install an
allowlisted extension first.

## After a Password Rotation

An application's in-use connection string no longer functions when someone
selects `Rotate credentials` on the `Application` tab of the `Connect`
pane. The new password does not authenticate until the database returns
to `Available`, and the old one may still work in that window, so switch
the application over when the status displays `Available` rather than
immediately.

Rotating the `app` password also restarts the database's MCP and RAG
Servers; each server reads the password once at startup.

[prisma-pg]: https://www.prisma.io/docs/orm/overview/databases/postgresql
[drizzle-pg]: https://orm.drizzle.team/docs/get-started-postgresql
[django-db]: https://docs.djangoproject.com/en/stable/ref/databases/
[rails-db]: https://guides.rubyonrails.org/configuring.html#configuring-a-database
[alembic-tut]: https://alembic.sqlalchemy.org/en/latest/tutorial.html
