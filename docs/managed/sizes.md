# Database Sizes

A Managed database runs at one of three sizes. You choose the size when you
create the database, and you can move it up to a larger one later. The size
fixes the compute, memory, storage and connection limit the database runs
under.

The following table shows what each size gives you:

| Size | vCPU | Memory | Storage | Connections |
|-------|------|--------|---------|-------------|
| Small | 1 | 2 GB | 25 GB | 20 |
| Large | 2 | 8 GB | 50 GB | 50 |
| XL | 4 | 16 GB | 150 GB | 100 |

`Connections` is the Postgres `max_connections` setting. Every client counts
against it, including the MCP and RAG servers, which connect to the database
as `app` when they are enabled.

`Storage` is the disk the database has. Used space counts against it, and the
only way to grow it is a size upgrade.

The price of each size is shown beside it on the size step of the create
wizard and in the `Upgrade size` popup, and the `Plan & billing` pane on the
database page shows the price of the size you are on.

## Reading the Current Size

The database header carries a badge naming the size, and the `Plan & billing`
pane names it beside its price. The `CPU`, `Memory`, `Storage` and `Conns`
figures in the header are live readings against the size's limits, so
`Storage` reads used against capacity and `Conns` reads active against the
connection limit. The `Upgrade size` popup lists each size's figures.

## Changing Size

Sizes only go up. `Upgrade size` on the `Actions` menu moves the database to a
larger size, and the database restarts while the new size is applied. It is
offered only while the database is `Available`. See
[Upgrading the Size Tier](using/actions.md#upgrading-the-size-tier).

## Next Steps

* [Deploying a Managed Database](creating_managed.md) covers the create
  wizard where the size is chosen.
* [Accessing Management Options with the Actions Menu](using/actions.md)
  covers the upgrade.
* [Monitoring System Metrics](using/metrics.md) covers the `CPU`, `Memory`,
  `Disk used` and `Active connections` charts that show how much of the size
  is in use.
