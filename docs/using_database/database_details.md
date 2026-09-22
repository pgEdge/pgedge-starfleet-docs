# Managing Database Details

This page describes two properties of a Managed database: its size, and
its status.

## Database Sizes

A managed database runs at one of three sizes. You select the size when you
create the database, and can move to a larger size as your needs change. The
size sets the compute, memory, storage, and connection limits the
database adheres to.

The following table shows what each size provides:

| Size | vCPU | Memory | Storage | Connections |
|-------|------|--------|---------|-------------|
| Small | 1 | 2 GB | 25 GB | 20 |
| Large | 2 | 8 GB | 50 GB | 50 |
| XL | 4 | 16 GB | 150 GB | 100 |

`Connections` is the Postgres `max_connections` setting. Every client counts
against the value, including the MCP and RAG Servers, which connect to the
database as `app` when enabled.

`Storage` is the disk space available to the database. Used space counts
against this value; the only way to increase the disk space is a size
upgrade.

The price of each size is displayed on the size step of the creation
wizard, in the `Upgrade size` popup, and on the `Plan & billing` pane of
the database console.

### Reading the Current Size

The database header displays a badge with the resource size, and the
`Plan & billing` pane displays the size alongside the price. The `CPU`,
`Memory`, `Storage`, and `Conns` figures in the header are live readings of
current usage against the size's limits: `CPU` and `Memory` compare the
current load against their allotted capacity, `Storage` compares used
space against capacity, and `Conns` compares active connections against
the connection limit. The `Upgrade size` popup displays each size's
allocated resources.

### Changing the Allocated Size

Sizes can only be increased. `Upgrade size` on the `Actions` menu moves
the database to a larger size, and restarts the database when the new
size is applied. This option is available only while the database status
is `Available`. See
[Upgrading the Size Tier](../using_console/actions.md#upgrading-the-size-tier).

## Database Statuses

The status is the badge on the Databases list and on the database
header. The API publishes nine values. The following table describes
the meaning of each value and the writes each one admits:

| Status | Description | Admissible Writes |
|--------|--------------|--------------------|
| `creating` | Being provisioned. Not yet usable. | None of the five writes below. Delete is admissible. |
| `available` | Ready. The only status every write is admissible from. | All of them. |
| `modifying` | A restore, resize, services change, or credential rotation is in flight. | None of the five. Delete is admissible unless a billing provision is unfinished, which a resize reopens. |
| `deleting` | Being torn down. | None, including delete. |
| `failed` | The last operation failed. That covers a create, a teardown, a suspend or resume, or a restore that reported success without a committed cutover. The database record is kept either way. | None of the five. Delete is admissible. |
| `degraded` | A resize failed after the database was already running. A failed credential rotation lands here too. | None of the five, whatever the console's buttons allow. See the note below. |
| `suspending` | Being hibernated. | None of the five. |
| `suspended` | Hibernated. | None of the five. |
| `resuming` | Coming back from hibernation. | None of the five. |

`available` is the one to wait for. Check against it rather than
against the mere absence of `creating`, because a database can reach
`failed` or `degraded` without passing through `creating` again.

The Managed database pages provide no control to suspend or resume a
database; only a banner appears on a database that is already
suspended. The last three statuses are listed because a database
suspended by some other means still reports them.

A status you do not recognize is not automatically an error. Treat
anything that is not `available` as a database that is not ready for
the five writes.

### A `degraded` Database Shows Its Action Buttons Enabled

The console treats `available` and `degraded` alike for `Rotate
credentials`, the display-name edit, and deletion protection. The API,
however, admits the five writes below only from `available`, so an
action offered on a `degraded` database can still be refused. `Upgrade
size` is the exception; the console already gates it, offering it only
from `available`.

### The Five Writes That Need Available

Five operations are admissible only from `available`, including when
the database is already `modifying` because of an earlier change:

* Restore from a backup
* Upgrade size
* Any services change, meaning enabling, configuring, or disabling the
  MCP Server or RAG Server
* Rotate credentials
* Take a backup

Every other operation has fewer restrictions. Editing the display name
and switching deletion protection take no hold on the database and
succeed while another operation is in progress. Delete does not wait
for a restore to finish.

A write attempted from any other status is refused, and the console
displays the API's message where it sends one. The message names the
status the API wanted rather than the one it found, so read the current
status from the status badge, wait for `available`, and try again.

## Next Steps

These pages cover related tasks that build on database details.

* [Deploying a Managed Database](../managed/creating_managed.md)
  describes using the create wizard.
* [Accessing Management Options with the Actions Menu](../using_console/actions.md)
  describes upgrading your resources.
* [Monitoring System Metrics](../using_console/metrics.md) details the
  `CPU`, `Memory`, `Disk used`, and `Active connections` charts that show
  the current resources in use.
* [Reviewing the Activity Log](../using_console/activity_log.md) describes
  the task names a status change moves through.
