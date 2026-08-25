# Monitoring System Metrics

The `Metrics` pane on your database's management page displays live graphs of
current database activity, including `Transactions` (transactions per second)
and `Tuples returned` (rows returned per second).

![The Metrics page](../../images/sf_metrics_all.png)

The `Metrics` page displays detailed charts of your database's resource,
throughput, and storage activity. Select any chart to expand it for a closer
look.

## The Metrics Page Header

![The Metrics page header](../../images/sf_metrics_header.png)

The header displays the name and status of the current database, followed by
controls for the charts displayed below:

* Use the time-range buttons (`15m`, `1h`, `6h`, `24h`, `7d`, or `Custom`) to
  change the period displayed.
* Use the row of tabs below the time-range buttons to display metrics for
  `All` nodes in the database, or select an individual node's ID to display
  metrics for that node only.
* Toggle `Live` to enable or disable automatic updates; when `Live` is
  enabled, the header displays how long ago the charts were last updated.
  Select the refresh icon to update the charts immediately.

Below the header, a row of tiles summarizes the current `CPU`, `Memory`,
`Disk used`, `Active connections`, and `Transactions` values for the selected
time range, each with a small trend graph. If the database was unreachable for
any samples in the selected time range, a warning banner reports how many
samples were affected and when the database was most recently unavailable.

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
