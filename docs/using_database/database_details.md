# Managing Database Details

A pgEdge Starfleet Managed database exposes two properties that change
over its lifetime: its size and its status.

## Database Sizes

A Managed database runs at one of three sizes. You select the size
when creating the database and can move to a larger size as your
needs change. The size sets the compute, memory, storage, and
connection limits the database adheres to.

The following table shows what each size provides:

| Size | vCPU | Memory | Storage | Connections |
|-------|------|--------|---------|-------------|
| Small | 1 | 2 GB | 25 GB | 20 |
| Large | 2 | 8 GB | 50 GB | 50 |
| XL | 4 | 16 GB | 150 GB | 100 |

`Connections` is the number of simultaneous client connections included
at the selected size. Each connected client counts against the
`Connections` figure listed in the table, including the MCP and RAG
Servers.

!!! hint

    Querying the PostgreSQL
    [`max_connections`](https://www.postgresql.org/docs/current/runtime-config-connection.html#GUC-MAX-CONNECTIONS)
    parameter returns a higher value than the table shows, because Postgres
    reserves connections for the server and maintenance workers. 

`Storage` is the disk space available to the database. Used space counts
against this value; the only way to increase the disk space is a size
upgrade. Postgres keeps its write-ahead log on that same disk, and the
filesystem keeps its own bookkeeping there too. The space left for the
database's own data is therefore less than the storage figure.

Each size's price appears on the size step of the creation wizard, in the
`Upgrade size` popup, and on the `Plan & billing` pane of the database
console.

### Reading the Current Size

The database header displays a badge with the resource size, and the
`Plan & billing` pane displays the size alongside the price. The `CPU`,
`Memory`, `Storage`, and `Conns` figures in the header are live readings of
current usage against the size's limits:

* `CPU` and `Memory` compare the current load against their allotted
  capacity.
* `Storage` compares used space against capacity.
* `Conns` compares active connections against the connection limit.

The `Upgrade size` popup displays each size's allocated resources.

### Changing the Allocated Size

Allocated resource sizes can only be increased. Use the `Upgrade size`
option on the `Actions` menu to move the database to a larger size and
restart it when the new size takes effect. This option is available
only while the database status is `available`. See
[Upgrading the Size Tier](../using_console/actions.md#upgrading-the-size-tier).

## Database Statuses

The database status appears in the badge on the Databases list and on
the database header. The API publishes nine values; the following
table describes the meaning of each value and the tasks each status
allows:

| Status | Description | Notes |
|--------|--------------|--------------------|
| `creating` | The database is being provisioned and is not yet available. | None of the five tasks below are allowed, though deleting the database is allowed. |
| `available` | The database is ready for use. | All five tasks are allowed. |
| `modifying` | A restore, resize, services change, or credential rotation is in progress. | None of the five tasks are allowed. Deleting the database is allowed unless an unfinished billing provision blocks it; a resize can reopen that condition. |
| `deleting` | The database is being torn down. | No task is allowed, including another delete request. |
| `failed` | The most recent operation failed. This can result from a failed create, teardown, suspend, or resume, or from a restore that reported success without completing its cutover. The database record is retained in either case. | None of the five tasks are allowed. Deleting the database is allowed. |
| `degraded` | A resize that failed after the database was already running results in this status, as does a failed credential rotation. | None of the five tasks are allowed, regardless of what the console's buttons appear to permit. See the note below. |
| `suspending` | The database is being hibernated. | None of the five tasks are allowed. |
| `suspended` | The database is hibernated. | None of the five tasks are allowed. |
| `resuming` | The database is coming back from hibernation. | None of the five tasks are allowed. |

When performing a task or spinning up a new database, you should wait for the
`available` status rather than the mere absence of `creating`, because a
database can reach `failed` or `degraded` without passing through `creating`
again.

An unfamiliar status is not automatically an error. Treat anything
that is not `available` as a database that is not ready for the five
tasks.

The console treats the `available` and `degraded` statuses alike when
enabling `Rotate credentials`, the display-name edit, and deletion
protection. The API, however, admits the five tasks below only when
the database state is `available`, so an action offered on a
`degraded` database can still be refused. `Upgrade size` is the
exception: the console offers it only when the database is
`available`.

Five tasks are allowed only when the database is `available`, even
when it is already `modifying` because of an earlier change:

* Restoring from a backup
* Upgrading the size
* Changing a service, meaning enabling, configuring, or disabling the
  MCP Server or RAG Server
* Rotating credentials
* Taking a backup

Every other task has fewer restrictions. Editing the display name and
switching deletion protection do not lock the database and can
succeed while another task is in progress. Delete does not wait for a
restore to finish.

A task attempted from any status other than `available` is refused,
and the console displays the API's message. The message names the
status the API wanted rather than the one it found, so read the
current status from the status badge, wait for `available`, and try
again.

