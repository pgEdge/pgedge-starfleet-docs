# Using the Database Console

When you create a pgEdge managed PostgreSQL database, the database name is
displayed in the tree control on the left side of the console when the
deployment completes.

![Displaying the currently deployed databases](../../images/managed_tree_control.png)

Select the database name to navigate to the database management page of the
console.

!!! hint

    If you're using a free trial, you can use the link at the top of the
    console to provide billing information for your database.


## The Database Header

![Database Header](../../images/managed_database_header.png)

The database header displays:

* The name of the database; next to the name, a dot indicates the status of the
  database:
    * A green dot indicates that the database is available for connections.
    * A blue dot indicates that the database is being created.
    * A red dot indicates that the database is not available.

* The CPU size of the database.
* The Memory used by the database.
* The amount of storage allocated to the database.
* The number of connections allocated for the database.

The `Actions` drop-down (on the right-hand side of the header) offers
management options for your database.

![The Actions menu](../../images/managed_actions_menu.png)

To change the name of your database, select `Edit Display Name` from the
`Actions` menu. When the `Change Display Name` popup opens, enter the new
database name in the `Display Name` field and select `Apply`.

![Changing the database name](../../images/managed_edit_display_name.png)

The `Enable deletion protection` option in the `Actions` drop-down works like a
toggle; select it once to enable protection, and a confirmation popup in the
lower-right corner of the window confirms that protection is enabled. To
disable deletion protection, select `Disable deletion protection` from the
menu.


## Connecting to your Database

Below the header, the console displays the `Connect` pane; the pane includes an
`Admin` tab with credentials that you can use to connect to the database as the
`admin` user (a database superuser), and an `Application` tab with credentials
that you can use to connect a client application to your database.

![Connecting to your database](../../images/managed_connecting.png)

For detailed information about:

* installing the psql client and connecting to the database, see
  [Connecting](../../connecting.md).
* Postgres SQL commands, see the
  [Postgres documentation](https://www.postgresql.org/docs/18/sql-commands.html).


## The AI Services Pane

![The AI Services pane](../../images/managed_services.png)

The `AI Services` pane displays icons you can use to deploy available services
on your Postgres database, including an MCP server and a RAG server. Select
`Enable MCP` or `Enable RAG` to add a service; once a service is deployed,
select its `Details` button to view connection details and manage it. For
detailed information about enabling, configuring, and connecting to these
services, see [Services](services/index.md).


## The Backups Pane

The `Backups` pane displays a list of the backups taken of your database; each
backup is either a `hot` backup (fast, short-term storage) or a `durable`
backup (longer-term, resilient storage).

![The Backups pane](../../images/managed_backups.png)

To review a complete list of available backups, select `View All` from the
right side of the console, across from the `Backups` label.

!!! hint

    You can also access the `Backups` page for your database by selecting
    `Backups` (below the database name) from the navigation pane on the left
    side of the console.

Each backup entry displays:

* The backup ID.
* A tag indicating whether the backup is a `hot` or `durable` backup.
* The backup status (for example, `completed`).
* How long ago the backup was taken.

Select the `Restore` button, to the right of a backup to restore the selected
backup; select `View all` (in the upper-right corner of the pane) to see the
complete list of backups. For detailed information about the `Backups` page,
see [Backups](backups.md).


## The Metrics Pane

The `Metrics` pane displays live graphs of current database activity, including
`Transactions` (transactions per second) and `Tuples returned` (rows returned
per second).

![The Metrics pane](../../images/managed_metrics.png)

Select `Open metrics` (in the upper-right corner of the `Metrics` pane) to see
detailed metrics for your database.

!!! hint

    You can also access the `Metrics` page for your database by selecting
    `Metrics` (below the database name) from the navigation pane on the left
    side of the console.

For detailed information about the `Metrics` page, see
[Metrics](metrics.md).


## The Logs Pane

The `Logs` pane displays the most recent entries from your database's log file;
each entry shows the timestamp, log level (for example, `LOG`), and message.

![The Logs pane](../../images/managed_logs.png)

Select `View logs` (in the upper-right corner of the pane) to see the complete,
searchable log for your database.

!!! hint

    You can also access the `Logs` page for your database by selecting
    `Logs` (below the database name) from the navigation pane on the left
    side of the console.


For detailed information about the `Logs` page, see [Logs](logs.md).


## Read Replicas and Branching

The `Primary` badge identifies the current database as a primary node.

![Read replicas and branching](../../images/managed_read_replicas_branching.png)

The `Read replicas & branching` pane previews upcoming functionality for
scaling read traffic with read replicas and spinning up copy-on-write branches
of your database. This functionality is still in development, and will remain
disabled until it becomes available.


## Summary Panes

The `Plan & billing` and `Details` panes display the size tier, billing status,
and configuration of your database.

![Summary panes](../../images/managed_summary.png)

### Plan and Billing

The `Plan & billing` pane displays the current size tier of your database and
the price you'll be billed after any free trial ends. Select `Upgrade size` to
change the size of your database.

### Details

The `Details` pane displays identifying and configuration information for your
database.

| Field | Description |
|-------|--------------|
| Database ID | The unique identifier for the database. |
| Region | The region in which the database is deployed. |
| Postgres | The Postgres version running on the database. |
| Storage | The amount of storage allocated to the database. |
| Network | Whether the database is publicly or privately accessible, and whether TLS is enabled. |
| Created | How long ago the database was created. |







