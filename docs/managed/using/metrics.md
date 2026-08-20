# Metrics

The `Metrics` pane on your database's management page displays live graphs of
current database activity, including `Transactions` (transactions per second)
and `Tuples returned` (rows returned per second).

![The Metrics pane](../../images/managed_metrics.png)

Select `Open metrics` (in the upper-right corner of the `Metrics` pane), or
select `Metrics` (below the database name) from the navigation pane, to open
the full `Metrics` page.

![The Metrics page](../../images/managed_metrics_all.png)

The `Metrics` page displays detailed charts of your database's resource,
throughput, and storage activity. Use the time-range buttons (`15m`, `1h`,
`6h`, `24h`, `7d`, or `Custom`) at the top of the page to change the period
displayed; toggle `Live` to enable or disable automatic updates. Select any
chart to expand it for a closer look.

## Resource Charts - Reference

The `Resources` section displays charts that track the compute and connection
resources used by your database.

| Chart | Description |
|-------|--------------|
| CPU | The percentage of CPU used by the database. |
| Memory | The percentage of memory used by the database. |
| Active connections | The number of active client connections to the database. |
| Idle connections | The number of idle (inactive) client connections to the database. |
| Waiting connections | The number of connections waiting for a lock or other resource to become available. |

## Throughput Charts - Reference

The `Throughput` section displays charts that track the volume of database
activity, including transactions and row-level operations.

| Chart | Description |
|-------|--------------|
| Transactions | The number of transactions processed per second. |
| Cache hit ratio | The percentage of reads served from the cache instead of disk. |
| Tuples returned | The number of rows returned by queries per second. |
| Tuples fetched | The number of rows fetched from the database per second. |
| Tuples inserted | The number of rows inserted per second. |
| Tuples updated | The number of rows updated per second. |
| Tuples deleted | The number of rows deleted per second. |
| Network in | The amount of network traffic received by the database per second. |
| Network out | The amount of network traffic sent by the database per second. |

## Storage and WAL Charts - Reference

The `Storage and WAL` section displays charts that track disk usage and
write-ahead log (WAL) activity for your database.

| Chart | Description |
|-------|--------------|
| Disk used | The percentage of allocated disk storage currently used. |
| Database size | The total size of the database. |
| Tables | The number of tables in the database. |
| WAL size | The size of the write-ahead log (WAL). |
| WAL segments | The number of WAL segments currently retained. |
