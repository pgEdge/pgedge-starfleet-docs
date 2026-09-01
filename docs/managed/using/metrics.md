# Monitoring System Metrics

The `Metrics` pane on your database's management page displays live
graphs of current database activity, including `Transactions`
(transactions per second) and `Tuples returned` (rows returned per
second).

![The Metrics page](../../images/sf_metrics_all.png)

The `Metrics` page displays five headline tiles and nineteen charts,
grouped into `Resources`, `Throughput`, and `Storage and WAL`. Select
any chart to expand it for a closer look.
<!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->

## The Metrics Page Header

![The Metrics page header](../../images/sf_metrics_header.png)

The header displays the name and status of the current database,
followed by controls for the charts displayed below:

* Use the time-range buttons (`15m`, `1h`, `6h`, `24h`, `7d`, or
  `Custom`) to change the period displayed. The choice is remembered
  per database.
  <!-- ui:src/components/databases/managed/observability/timeWindows.ts -->
* Use the row of buttons below the time-range buttons to display
  metrics for `All` reporting instances, or select a single instance to
  display metrics for that one only. The primary is marked, and the row
  appears only when more than one instance reports.
  <!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->
* Toggle `Live` to enable or disable automatic updates. `Live` is on by
  default and refreshes on a cadence set by the time range. Applying a
  `Custom` range disables the `Live` control. When `Live` is
  enabled, the header displays how long ago the charts were last
  updated. Select the refresh icon to update the charts immediately.
  <!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->

Below the header, a row of tiles summarizes the current `CPU`,
`Memory`, `Disk used`, `Active connections`, and `Transactions` values,
each with a small trend graph. The tiles read from the primary
instance, falling back to whichever instance reported first when no
instance is yet marked primary.
<!-- ui:src/components/databases/managed/observability/StatTiles.tsx -->

If the database was unreachable for any samples in the selected time
range, a warning banner reports how many samples were affected and when
the database was most recently unavailable.
<!-- ui:src/components/databases/managed/observability/AvailabilityNotice.tsx -->

### How Often the Charts Refresh

Live refresh runs at a different cadence for each time range, because a
wider range moves more slowly. Wider ranges also average their points
into buckets to keep the line legible, and an expanded chart plots up
to 480 buckets whatever the range.
<!-- ui:src/components/databases/managed/observability/timeWindows.ts -->
<!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->
<!-- the endpoint returns raw samples, so the console buckets them -->

| Time range | Refresh | Points plotted |
|------------|---------|----------------|
| `15m` | Every 10 seconds | Every sample |
| `1h` | Every 30 seconds | Every sample |
| `6h` | Every 60 seconds | Averaged into 120 buckets |
| `24h` | Every 2 minutes | Averaged into 150 buckets |
| `7d` | Every 5 minutes | Averaged into 180 buckets |

## Levels and Rates

Every chart plots either a level or a rate.

A **level** plots the value as the database reported it. A blank means
the database published nothing for that sample.

A **rate** plots the change since the previous sample divided by the
seconds between the two. The first point of any rate series is always
blank, because there is no previous sample to subtract, and a sample
whose neighbour is missing is blank too. A counter that restarts at
zero, which happens when the container restarts, produces a negative
difference, which the console renders as one gap rather than as a
downward spike.
<!-- ui:src/components/databases/managed/observability/deriveSeries.ts -->

## Resource Charts - Reference

The `Resources` section displays charts that track the compute and
connection resources used by your database.

| Chart | Description | Source metric | Shape |
|-------|-------------|---------------|-------|
| CPU | The percentage of CPU used by the database. The axis is capped at 100. | `cpu_seconds_total` as a rate, against `cpu_quota` divided by `cpu_period` | Rate |
| Memory | The percentage of memory used by the database. The axis is capped at 100. | `memory_used_bytes` over `memory_limit_bytes` | Level |
| Active connections | The number of active client connections to the database. | `pg_stat_activity_active`, with the axis topped by `pg_settings_max_connections` | Level |
| Idle connections | The number of idle (inactive) client connections to the database. | `pg_stat_activity_idle`, same axis top | Level |
| Waiting connections | The number of connections waiting for a lock or other resource to become available. | `pg_stat_activity_waiting`, same axis top | Level |

<!-- ui:src/components/databases/managed/observability/deriveSeries.ts -->

Active, idle, and waiting are three separate charts of one number
apiece, not slices of a total. Read them together against the
connection limit the axis carries.

## Throughput Charts - Reference

The `Throughput` section displays charts that track the amount of
database activity, including transactions and row-level operations.

| Chart | Description | Source metric | Shape |
|-------|-------------|---------------|-------|
| Transactions | The number of transactions processed per second, counting commits and rollbacks together. | `pg_stat_database_xact_commit` and `pg_stat_database_xact_rollback`, each as a rate, added | Rate |
| Cache hit ratio | The percentage of reads served from the cache instead of disk. The axis is capped at 100 and its floor follows the data. | `pg_stat_database_blks_hit` and `pg_stat_database_blks_read` as rates, hits over the two added | Rate |
| Tuples returned | The number of rows returned by queries per second. | `pg_stat_database_tup_returned` | Rate |
| Tuples fetched | The number of rows fetched from the database per second. | `pg_stat_database_tup_fetched` | Rate |
| Tuples inserted | The number of rows inserted per second. | `pg_stat_database_tup_inserted` | Rate |
| Tuples updated | The number of rows updated per second. | `pg_stat_database_tup_updated` | Rate |
| Tuples deleted | The number of rows deleted per second. | `pg_stat_database_tup_deleted` | Rate |
| Network in | The amount of network traffic received by the database per second. | `network_receive_bytes_total` | Rate |
| Network out | The amount of network traffic sent by the database per second. | `network_transmit_bytes_total` | Rate |

<!-- ui:src/components/databases/managed/observability/deriveSeries.ts -->

`Cache hit ratio` is blank rather than zero when neither hits nor reads
moved between two samples, so an idle database shows gaps here rather
than a flat line.

## Storage and WAL Charts - Reference

The `Storage and WAL` section displays charts that track disk usage and
write-ahead log (WAL) activity for your database.

| Chart | Description | Source metric | Shape |
|-------|-------------|---------------|-------|
| Disk used | The percentage of allocated disk storage currently used. The axis is capped at 100. | `storage_used_bytes` over used plus `storage_available_bytes` | Level |
| Database size | The total size of the database. | `pg_database_size_bytes` | Level |
| Tables | The number of tables in the database. | `pg_database_table_count` | Level |
| WAL size | The size of the write-ahead log (WAL). | `pg_wal_size_bytes` | Level |
| WAL segments | The number of WAL segments currently retained. | `pg_wal_segments` | Level |

<!-- ui:src/components/databases/managed/observability/deriveSeries.ts -->

`Disk used` is storage in use as a share of storage in use plus storage
still available. `Database size` is the size of the Postgres database
itself, so the two do not match.
<!-- ui:src/components/databases/managed/observability/deriveSeries.ts -->

## How Far Behind the Charts Run

**The newest point on a chart runs 1 to 2 minutes behind the clock.**
The lag moves around inside that band rather than settling on one
figure. Samples are collected into buckets every 30 seconds, aligned to
the top and the half of each minute.
<!-- M:1733 --> <!-- M:1729 -->
<!-- newest sample 72 to 101 seconds behind the wall clock across -->
<!-- 21 measurements, oscillating rather than settling -->

A change you make now is not on the chart now, so wait out the lag
before concluding that a query, an index, or a restart had no effect.

## Minimum Time Range

A range shorter than the lag ends before any published sample exists,
so it holds nothing. One minute always comes back empty, ninety seconds
is unreliable, and two minutes holds only a sample or two.
<!-- M:1727 --> <!-- M:1735 --> <!-- M:1737 -->
<!-- M:1738 --> <!-- M:1764 -->
<!-- 1m empty on 21 of 21 attempts across two fixtures, below the -->
<!-- smallest lag seen; 90s returned rows on 5 of 10 attempts; 2m -->
<!-- always returned rows, holding 1 or 2 samples roughly half each -->
<!-- over 12 measurements, covering 19 to 48 seconds of published -->
<!-- data at 30s buckets and a 72 to 101 second lag -->

**Ask for three minutes or more.** A three-minute range holds a
handful of samples, and a wider one holds more.
<!-- M:1768 -->
<!-- 3m held 4 distinct samples, 5m held 8, 10m held 18 -->

The console's shortest time-range button is `15m`, so this bites only
through `Custom`. A custom range of a couple of minutes ending at now
is the shape that comes back empty, and the page then reads
`No metrics in this window`, which is the same message a database with
no metrics at all shows.
<!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->

## Charts With No Data

**A metric with no value anywhere in the time range is left out of the
response entirely rather than sent as blank.** The console renders no
chart for a metric it received no sample for, and nothing on the page
marks the absence. A narrow range therefore shows fewer charts than a
wide one, with no error and no note.
<!-- M:1749 --> <!-- M:1753 -->
<!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->
<!-- a range pinned on one partly-scraped bucket returned 29 and 34 -->
<!-- columns against the usual 36; the absent columns were the ones -->
<!-- a wider read showed as blank in that bucket, CPU and memory -->
<!-- among them, and the response carries nothing naming them -->

If a chart you expect is not on the page, widen the time range before
concluding anything about the database.

## Metrics During a Resize or Restore

A resize or a restore moves the database onto new infrastructure, and
both instances report for a while. During that handover, two samples
can share one timestamp, one per instance.
<!-- M:1639 -->

The console groups the samples by instance before it computes anything,
so a rate is never taken across the handover and the overlap is never
counted twice.
<!-- M:1656 -->
<!-- ui:src/components/databases/managed/observability/deriveSeries.ts -->

What you see is the instance filter appearing above the charts, with
one button per instance and the primary marked, and two lines on each
chart with a legend. The instance still coming up reports blanks for a
while, so its line starts sparse.
<!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->
<!-- M:1666 -->

Outside a resize or a restore, each chart carries a single line.
<!-- M:1660 -->
<!-- 17 captures at ranges from 15 minutes to 5 days held 29,821 -->
<!-- samples with no duplicated timestamp -->

## When the Page Shows a Message Instead of Charts

The page shows one of two messages in place of the charts:

* `Couldn't load metrics` means the read failed, and the panel carries a
  `Retry` button. Use it. If it keeps failing while the database is
  `Available`, the metrics store is the thing that is unwell rather than the
  database.
  <!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->
  <!-- ui:src/components/databases/managed/observability/ObservabilityStates.tsx -->
* `No metrics in this window` means the read succeeded and the time range
  held no samples. The hint under it names a database created moments ago,
  or an environment without observability, as the causes. Widen the time
  range. The newest sample runs 1 to 2 minutes behind the clock, so a custom
  range of a couple of minutes ending at now is empty, as
  [Minimum Time Range](#minimum-time-range) describes.
  <!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->
  <!-- M:1733 -->

The first is a failed request and the second is an empty range. A database
that cannot be read at all shows `Couldn't load this database. Please try
again shortly.` in place of the whole page instead.
<!-- ui:src/components/databases/managed/ManagedMetricsView.tsx -->

## Related Pages

* [Reviewing the Activity Log](../../activity_log.md) covers the resize
  and the restore that put two instances on the charts.
* [Restoring from Backup](backups.md) covers the restore itself.
