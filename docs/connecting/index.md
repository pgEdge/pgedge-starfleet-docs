# Connecting to a pgEdge Starfleet Database

Any client that can negotiate a connection using libpq can connect to the
PostgreSQL database on pgEdge Starfleet, and this applies to custom clients as
well. Connections are made over TLS with a password. The connection string the
console hands you always carries `sslmode=require`, and Starfleet hosts serve
TLS with a certificate that verifies, so `require` works from every client and
a stricter mode is yours to add.

The pgAdmin walkthrough also sets
[gssencmode](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNECT-GSSENCMODE)
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
  command-line client distributed with PostgreSQL, and how to handle the
  password once you have it.
* [Connecting with pgAdmin](pgadmin.md) describes how to register your
  database as a server in the pgAdmin graphical client.

## While the Database Is Still Being Created

A database that is still being provisioned shows a provisioning message on
the `Connect` pane instead of connection details.

`Available` is the status to wait for, and every readiness check should compare
against it rather than against "not creating", because a database can report
`failed` or `degraded` without passing through `creating` again.

## Next Steps

* [Database Roles](../roles.md) covers what the `admin` and `app` roles can
  each do, and which one to connect as.
* [Installing Extensions](../managed/using/extensions.md) covers which role
  installs which extension, and what the refusal message means.
* [Loading Data into Your pgEdge Starfleet Database](../loading_data.md)
  covers loading a schema and its data with both roles, in order.
* [Rotating Database Credentials](../managed/using/rotate_credentials.md)
  covers replacing a password and the window during which neither password
  is a safe bet.
