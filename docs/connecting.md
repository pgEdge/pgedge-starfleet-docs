# Connecting to pgEdge Distributed PostgreSQL (pgEdge Starfleet)

Any client that can negotiate a connection using libpq can connect to the
PostgreSQL database (port `5432`) on pgEdge Starfleet; this applies to custom
clients as well. All authenticating clients must:

* require an SSL connection.
* disable GSS encoding
  ([gssencmode](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNECT-GSSENCMODE)).
* use an SSH key when connecting.

In this guide, we'll walk you through connecting with some commonly used
clients.

## Connecting with psql

To locate database-specific PSQL connection properties for your pgEdge
Starfleet PostgreSQL database, double-click a database name in the console
navigation panel or navigate to the database's main page in the console. Below
the header of the database page, the console displays the `Connect` pane; the
pane displays:

* an `Admin` tab with credentials for the `admin` user
* an `Application` tab with credentials for the `app` user

Each tab displays a `Connection string`, a ready-to-use `psql command`, and the
`Database name`, `Domain`, `User`, and `Password` values used to build them.

The two users have different permissions on the database:

| Capability | `admin` | `app` |
|------------|:-------:|:-----:|
| Create tables/objects in `public` | No | Yes |
| Read all data | Yes | Yes |
| Insert, update, delete data | Yes | Yes |
| Create databases | Yes | No |
| Create roles | Yes | No |
| View active sessions | Yes | No |
| Terminate backends | Yes | No |
| Run maintenance (vacuum, analyze) | Yes | No |
| Manage subscriptions | Yes | No |

!!! note

    To create tables or other schema objects, connect using the `Application`
    tab credentials (the `app` user). The `admin` user can read and write
    existing data, but cannot create new objects.

![Connecting to your database](images/sf_connecting.png)


### Using the psql Client

The psql client is distributed with PostgreSQL, and is available for download
at the Postgres website; for more information about psql, see the Postgres
documentation at: [psql](https://www.postgresql.org/docs/18/app-psql.html)

If you have already installed a copy of psql, connection is simple; each tab
of the `Connect` pane (`Admin` or `Application`) displays a ready-to-use psql
connection string. For example:

`PGSSLMODE=require PGPASSWORD=n7Im33AlyUIjh524d869vTU4 psql -U admin -h noticeably-guiding-kangaroo.use2.staging.pgedge.cloud -p 5432 -d acctg`

Select the copy icon next to the psql connection string to copy it, paste
it directly into a terminal window, and press `Return` to connect.

!!! hint

    The `PGSSLMODE=require` environment variable enforces the required SSL
    connection.

If you start psql with a graphical prompt or icon (rather than the command
line) you can use the individual values from the psql connection string to
authenticate:

* When prompted for a `Server [localhost]`, provide the host name from the
  connection string (the clause that ends with `.pgedge.cloud`) and press
  `Return`. In our example above, the host name is:
  `noticeably-guiding-kangaroo.use2.staging.pgedge.cloud`.
* When prompted for a `Database [postgres]`, provide the database name from the
  connection string and press `Return`. In our example, the database name is
  `acctg`.
* When prompted for a `Port [5432]`, enter `5432` and press `Return`.
* When prompted for a `Username [postgres]`, provide the `User` value from the
  `Connect` pane, and press `Return`. In our example, the user is `app`.
* When prompted for the `Password`, provide the `Password` value from the
  `Connect` pane.


### Installing psql and Connecting

To install psql on your local system, follow the platform-specific installation
and connection details for your server.

#### On a Mac

On a Mac, you can use `brew` to install psql at the command line. To install
psql, open a `Terminal` window and enter:

`brew install libpq`

When `brew` completes, use the following command to ensure that the version of
psql that you've just installed is the first version in your PATH:

`echo 'export PATH="/usr/local/opt/libpq/bin:$PATH"' >> ~/.zshrc`

Then, to connect to a pgEdge Starfleet database, use the copy button to
the right of the connection string in the `Connect` section to copy the
psql connection string of your database; then paste the string in the `Terminal`.

![Copying a Connection String](images/sf_copy_conn_string.png)

Press `Return` to connect to the server with the psql client.

#### On Linux

On a Linux system, install the `postgresql` package with your platform-specific
package manager; for example, on a Rocky Linux host, use `yum`:

`yum install postgresql`

This command installs psql in `/usr/bin/psql`. After installing, you can
connect to the database with the connection string provided by the pgEdge
console.

For detailed information about installing PostgreSQL packages on Linux, visit
the [PostgreSQL Downloads page](https://www.postgresql.org/download/).

#### On Windows

For detailed information about installing PostgreSQL on Windows, visit the
[PostgreSQL downloads page](https://www.postgresql.org/download/windows/).
After installing PostgreSQL, you can navigate through the Windows menu to open
the psql client.

## Connecting with pgAdmin

To use the pgAdmin client to manage your pgEdge Starfleet database and the
objects that reside on it, right-click on the `Servers` node in the pgAdmin
client, and select `Register`, then `Server` from the context menu.

![Accessing pgAdmin](images/sf_pgadmin_register_server.png)

The `Register - Server` dialog opens:

![The pgAdmin Register - Server dialog](images/sf_pgadmin_connection.png)

When prompted, provide authentication details on the pgAdmin `Connection` tab.
To find connection information for your database, highlight the database name
in the navigation panel, and review the `Connect to your database` pane shown
on the `Database` dialog:

* Provide the name shown in the `Domain` field that ends with `.pgedge.io` in
  the `Host name/address` field.

* Provide the name of your database in the `Maintenance database` field.

* Replace the default `Username` with `app` when connecting for the first
  time; the `app` user owns the database and can create tables and other
  objects. Use the `admin` user instead if you only need read/write access to
  existing data.

* Enter the password associated with the user in the `Password` field.

![The pgAdmin Parameters tab](images/sf_pgadmin_register_parameters.png)

Provide the following information on the `Parameters` tab:

* Use the drop-down to the right of `SSL mode` to select `require`.

* Use the `+` at the top of the parameter table to open a new row, and use the
  drop-down list in the `Name` field to select `GSS encmode`. Set the `Value`
  to `disable`.

Complete the other tabs in the `Register - Server` dialog specifying your
connection preferences, and select `Save`. The connection to your database is
added to the `Servers` node in the `Object Explorer` pane, and the pgAdmin
`Dashboard` displays current database activities.

![pgAdmin Connected](images/sf_pgadmin_connected.png)

For detailed information about using pgAdmin, you can review the pgAdmin
documentation at:
[https://www.pgadmin.org/docs/](https://www.pgadmin.org/docs/).


