# Connecting to a pgEdge Starfleet Database

Any client that can negotiate a connection using libpq can connect to the
PostgreSQL database (port `5432`) on pgEdge Starfleet; this applies to custom
clients as well. All authenticating clients must:

* require an SSL connection.
* disable GSS encoding
  ([gssencmode](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNECT-GSSENCMODE)).
* use an SSH key when connecting.

The documentation includes instructions for installing and connecting with the following commonly used clients:

* [Connecting with the AI DBA Workbench](workbench.md) describes how to
  install the pgEdge AI DBA Workbench, then connect it to your database for
  monitoring, alerting, and AI-assisted diagnostics.
* [Connecting with psql](psql.md) describes how to connect with psql, the
  command-line client distributed with PostgreSQL.
* [Connecting with pgAdmin](pgadmin.md) describes how to register your
  database as a server in the pgAdmin graphical client.
