# Database Sizes

A Managed database runs at one of three sizes. You choose the size when you
create the database, and you can move it up to a larger one later. The size
fixes the compute, memory, storage and connection limit the database runs
under.
<!-- API size list read 2026-09-01: small, large and xl, all active, no
     other size published -->

The following table shows what each size gives you:

| Size | vCPU | Memory | Storage | Connections |
|-------|------|--------|---------|-------------|
| Small | 1 | 2 GB | 25 GB | 20 |
| Large | 2 | 8 GB | 50 GB | 50 |
| XL | 4 | 16 GB | 150 GB | 100 |

<!-- cpu_limit, memory_limit, storage_size and
     postgres_settings.max_connections from the size list, 2026-09-01 -->
<!-- max_connections confirmed as 20 on two running Small databases -->

`Connections` is the Postgres `max_connections` setting. Every client counts
against it, including the MCP and RAG servers, which connect to the database
as `app` when they are enabled.
<!-- saas:internal/k8s/mcp.go --> <!-- saas:internal/k8s/rag.go -->

`Storage` is the disk the database has. Used space counts against it, and the
only way to grow it is a size upgrade.
<!-- ui:src/components/databases/managed/copy/managedCopy.ts -->

The price of each size is shown beside it on the size step of the create
wizard and in the `Upgrade size` popup, and the `Plan & billing` pane on the
database page shows the price of the size you are on.
<!-- ui:src/components/databases/managed/createFlow/steps/SizeStep.tsx -->
<!-- ui:src/components/databases/managed/ManagedUpgradeSize.tsx -->
<!-- ui:src/components/databases/managed/details/PlanBillingCard.tsx -->

## Reading the Current Size

The database header carries a badge naming the size, and the `Plan & billing`
pane names it beside its price. The `CPU`, `Memory`, `Storage` and `Conns`
figures in the header are live readings against the size's limits, so
`Storage` reads used against capacity and `Conns` reads active against the
connection limit. The `Upgrade size` popup lists each size's figures.
<!-- ui:src/components/databases/managed/details/DetailsHeader.tsx -->
<!-- ui:src/components/databases/managed/details/HealthStrip.tsx -->
<!-- ui:src/components/databases/managed/ManagedUpgradeSize.tsx -->

## Changing Size

Sizes only go up. `Upgrade size` on the `Actions` menu moves the database to a
larger size, and the database restarts while the new size is applied. It is
offered only while the database is `Available`. See
[Upgrading the Size Tier](using/actions.md#upgrading-the-size-tier).
<!-- ui:src/utils/managedDatabase.ts canResizeManagedDatabase -->
<!-- M:578 -->

## Next Steps

* [Deploying a Managed Database](creating_managed.md) covers the create
  wizard where the size is chosen.
* [Accessing Management Options with the Actions Menu](using/actions.md)
  covers the upgrade.
* [Monitoring System Metrics](using/metrics.md) covers the `CPU`, `Memory`,
  `Disk used` and `Active connections` charts that show how much of the size
  is in use.
