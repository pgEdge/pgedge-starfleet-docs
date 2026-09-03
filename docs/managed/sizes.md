# Selecting a Database Size

A managed database runs at one of three sizes. You select the size when you
create the database, and can move to a larger size as your needs change. The
size sets the compute, memory, storage and connection limits the database
adheres to.

The following table shows what each size provides:

| Size | vCPU | Memory | Storage | Connections |
|-------|------|--------|---------|-------------|
| Small | 1 | 2 GB | 25 GB | 20 |
| Large | 2 | 8 GB | 50 GB | 50 |
| XL | 4 | 16 GB | 150 GB | 100 |

`Connections` is the Postgres `max_connections` setting. Every client counts
against the value, including the MCP and RAG servers, which connect to the
database as `app` when enabled.

`Storage` is the disk space available to the database. Used space counts
against this value; the only way to increase the disk space is a size
upgrade.

The price of each size is displayed on the size step of the creation
wizard, in the `Upgrade size` popup, and on the `Plan & billing` pane of
the database console.

## Reading the Current Size

The database header displays a badge with the resource size, and the
`Plan & billing` pane displays the size alongside the price. The `CPU`,
`Memory`, `Storage` and `Conns` figures in the header are live readings of
current usage against the size's limits: `CPU` and `Memory` compare the
current load against their allotted capacity, `Storage` compares used
space against capacity, and `Conns` compares active connections against
the connection limit. The `Upgrade size` popup displays each size's
allocated resources.

## Changing the Allocated Size

Sizes can only be increased. `Upgrade size` on the `Actions` menu moves
the database to a larger size, and restarts the database when the new
size is applied. This option is available only while the database status
is `Available`. See
[Upgrading the Size Tier](../using_console/actions.md#upgrading-the-size-tier).

## Next Steps

* [Deploying a Managed Database](creating_managed.md) discusses using the
  create wizard.
* [Accessing Management Options with the Actions Menu](../using_console/actions.md)
  discusses upgrading your resources.
* [Monitoring System Metrics](../using_console/metrics.md) details the
  `CPU`, `Memory`, `Disk used` and `Active connections` charts which show the
  current resources in use.
