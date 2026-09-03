# Connecting to a pgEdge Starfleet Database

Any client that can negotiate a connection using libpq can connect to the
PostgreSQL database on pgEdge Starfleet; this applies to custom clients as
well. Connections are made over TLS with password authentication. The connection
string the console displays always includes `sslmode=require`, and Starfleet
hosts serve TLS with a certificate that verifies, so `require` works from every
client and a stricter mode is yours to add.

On clients with optional GSS encoding  (as shown in the pgAdmin client), you
should set
[encoding](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNECT-GSSENCMODE)
to `disable`.

Every client connects as one of the database's two built-in roles, `admin` or
`app`. Which one to use depends on the job, and
[Database Roles](../roles.md) covers the split.

The documentation includes instructions for installing and connecting with
the following commonly used clients:

* [Connecting with the AI DBA Workbench](workbench.md) describes how to
  install the pgEdge AI DBA Workbench, then connect it to your database for
  monitoring, alerting, and AI-assisted diagnostics.
* [Connecting with psql](psql.md) describes how to connect with psql, the
  command-line client distributed with PostgreSQL, and how to manage the
  password.
* [Connecting with pgAdmin](pgadmin.md) describes how to register your
  database as a server in the pgAdmin graphical client.

## While the Database Is Still Being Created

A database that is still being provisioned displays a provisioning message on
the `Connect` pane instead of connection details.

!!! note

    Readiness checks must wait for the `Available` status, not merely the
    absence of `creating`. A database can transition directly to `failed`
    or `degraded` without returning to `creating` first, so comparing against
    `Available` is the only reliable way to confirm readiness.

## Next Steps

* [Database Roles](../roles.md) explains what the `admin` and `app` roles can
  each do, and which role to choose to accomplish tasks.
* [Installing Extensions](../managed/using/extensions.md) discusses which role
  installs which extension, and refusal messages.
* [Loading Data into Your pgEdge Starfleet Database](../loading_data.md)
  discusses loading a schema and its data with each role, in order.
* [Rotating Database Credentials](../managed/using/rotate_credentials.md)
  explains how to replace a password, and the window during which neither
  password is safe to use.
