# Monitoring System Metrics

The `Metrics` pane on your database's management page displays live
graphs of current database activity, including `Transactions`
(transactions per second) and `Tuples returned` (rows returned per
second).

![The Metrics page](../../images/sf_metrics_all.png)

The `Metrics` page displays five headline tiles and nineteen charts,
grouped into `Resources`, `Throughput`, and `Storage and WAL`. Select
any chart to expand it for a closer look.

## The Metrics Page Header

![The Metrics page header](../../images/sf_metrics_header.png)

The header displays the name and status of the current database,
followed by controls for the charts displayed below:

* Use the time-range buttons (`15m`, `1h`, `6h`, `24h`, `7d`, or
  `Custom`) to change the period displayed. The choice is remembered
  per database.

* Use the row of buttons below the time-range buttons to display
  metrics for `All` reporting instances, or select a single instance to
  display metrics for that one only. The primary is marked, and the row
  appears only when more than one instance reports.

* Toggle `Live` to enable or disable automatic updates. `Live` is on by
  default and refreshes on a cadence set by the time range. Applying a
  `Custom` range disables the `Live` control. When `Live` is
  enabled, the header displays how long ago the charts were last
  updated. Select the refresh icon to update the charts immediately.

Below the header, a row of tiles summarizes the current `CPU`,
`Memory`, `Disk used`, `Active connections`, and `Transactions` values,
each with a small trend graph. The tiles read from the primary
instance, falling back to whichever instance reported first when no
instance is yet marked primary.

If the database was unreachable for any samples in the selected time
range, a warning banner reports how many samples were affected and when
the database was most recently unavailable.

### How Often the Charts Refresh

Live refresh runs at a different cadence for each time range, because a
wider range moves more slowly. Wider ranges also average their points
into buckets to keep the line legible, and an expanded chart plots up
to 480 buckets whatever the range.

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

`Disk used` is storage in use as a share of storage in use plus storage
still available. `Database size` is the size of the Postgres database
itself, so the two do not match.

## How Far Behind the Charts Run

**The newest point on a chart runs 1 to 2 minutes behind the clock.**
The lag moves around inside that band rather than settling on one
figure. Samples are collected into buckets every 30 seconds, aligned to
the top and the half of each minute.

A change you make now is not on the chart now, so wait out the lag
before concluding that a query, an index, or a restart had no effect.

## Minimum Time Range

A range shorter than the lag ends before any published sample exists,
so it holds nothing. One minute always comes back empty, ninety seconds
is unreliable, and two minutes holds only a sample or two.

**Ask for three minutes or more.** A three-minute range holds a
handful of samples, and a wider one holds more.

The console's shortest time-range button is `15m`, so this bites only
through `Custom`. A custom range of a couple of minutes ending at now
is the shape that comes back empty, and the page then reads
`No metrics in this window`, which is the same message a database with
no metrics at all shows.

## Charts With No Data

**A metric with no value anywhere in the time range is left out of the
response entirely rather than sent as blank.** The console renders no
chart for a metric it received no sample for, and nothing on the page
marks the absence. A narrow range therefore shows fewer charts than a
wide one, with no error and no note.

If a chart you expect is not on the page, widen the time range before
concluding anything about the database.

## Metrics During a Resize or Restore

A resize or a restore moves the database onto new infrastructure, and
both instances report for a while. During that handover, two samples
can share one timestamp, one per instance.

The console groups the samples by instance before it computes anything,
so a rate is never taken across the handover and the overlap is never
counted twice.

What you see is the instance filter appearing above the charts, with
one button per instance and the primary marked, and two lines on each
chart with a legend. The instance still coming up reports blanks for a
while, so its line starts sparse.

Outside a resize or a restore, each chart carries a single line.

## When the Page Shows a Message Instead of Charts

The page shows one of two messages in place of the charts:

* `Couldn't load metrics` means the read failed, and the panel carries a
  `Retry` button. Use it. If it keeps failing while the database is
  `Available`, the metrics store is the thing that is unwell rather than the
  database.

* `No metrics in this window` means the read succeeded and the time range
  held no samples. The hint under it names a database created moments ago,
  or an environment without observability, as the causes. Widen the time
  range. The newest sample runs 1 to 2 minutes behind the clock, so a custom
  range of a couple of minutes ending at now is empty, as
  [Minimum Time Range](#minimum-time-range) describes.

The first is a failed request and the second is an empty range. A database
that cannot be read at all shows `Couldn't load this database. Please try
again shortly.` in place of the whole page instead.

## Related Pages

* [Reviewing the Activity Log](../../activity_log.md) covers the resize
  and the restore that put two instances on the charts.
* [Restoring from Backup](backups.md) covers the restore itself.
