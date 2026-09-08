# Connecting to a pgEdge Starfleet Database

Any client that can negotiate a connection using libpq can connect to the
PostgreSQL database on pgEdge Starfleet; this applies to custom clients as
well. Connections are made over TLS with password authentication. The connection
string the console displays always includes `sslmode=require`, and Starfleet
hosts serve TLS with a certificate that verifies, so `require` works from every
client, and you may add a stricter mode.

On clients with optional GSS encoding  (as shown in the pgAdmin client), you
should set
[encoding](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNECT-GSSENCMODE)
to `disable`.

Every client connects as one of the database's two built-in roles, `admin` or
`app`. Which one to use depends on the job, and
[Database Roles](../using_database/roles.md) describes the split.

The documentation includes instructions for installing and connecting with
the following commonly used clients:

* [Connecting with the AI DBA Workbench](workbench.md) describes how to
  install the pgEdge AI DBA Workbench, then connect it to your database for
  monitoring, alerting, and AI-assisted diagnostics.
* [Connecting with psql](psql.md) describes how to connect with psql, the
  command-line client distributed with PostgreSQL.
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

## Using Special Characters in URI Encoding

In URI syntax, reserved characters are used as structural delimiters:

  - `@` separates the user (user:password) from the host.
  - `:` separates the user from the password, and the host
    from the port.
  - `/` separates the host/port from the path (database name).
  - `?` starts the query-string parameters.

When Cloud encounters a password that contains special characters that are not
encoded properly, the characters will cause a loop of round-trips instead of
parsing into the correct connection string.

Cloud expects percent-encoding, like that used in the `Connection string`
URI; the `psql command` block is formatted to connect with the correct values.

If you read the password out of the `Password` field and assemble a URI
yourself, you must encode it yourself, using the correct grammar as noted in
[RFC 3986](https://www.rfc-editor.org/rfc/rfc3986).

!!! hint

    Make sure you copy the whole string: a URI trimmed back to its host and
    database could omit `sslmode=require`, preventing a connection.

### Managing a Password Safely

The connection string on your clipboard, connection strings built from your
password, and the `Password` field itself (when revealed) all contain a
working database password in clear text. Observe password-handling best
practices when using the password:

* Do not echo the connection string in a terminal. Scrollback outlives the
  session, and shell history files outlive the terminal.
* Do not pass the password as a command-line argument. Argument lists are
  visible in `ps` on a shared host.
* Ensure that your password is not written to application/CI log files. A
  job running under a shell trace writes the password into build output,
  which may be retained in an unsafe location.

!!! hint

    Supply the string to your application through a secrets mechanism
    rather than a shell variable. To retire a password, see
    [Rotating Database Credentials](../using_console/rotate_credentials.md).

## Next Steps

* [Database Roles](../using_database/roles.md) explains what the `admin` and `app` roles can
  each do, and which role to choose to accomplish tasks.
* [Installing Extensions](../using_database/extensions.md) discusses which role
  installs which extension, and refusal messages.
* [Loading Data into Your pgEdge Starfleet Database](../using_database/loading_data.md)
  discusses loading a schema and its data with each role, in order.
* [Rotating Database Credentials](../using_console/rotate_credentials.md)
  explains how to replace a password, and the window during which neither
  password is safe to use.
