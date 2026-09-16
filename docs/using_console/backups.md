# Restoring a pgEdge Starfleet Managed Database from a Backup

A restore replaces a pgEdge Starfleet Managed database's current data
with the contents of a backup you choose, in the console.
`hot` and `durable` name the two backup tiers. A `hot` backup stays
with the database and restores fastest. A `durable` backup goes to
separate object storage and restores slower. A restore runs in
place, so the database's identifier and the way you connect to it
stay the same.

## Before You Start

A restore is possible only when:

- The database is `Available`.
- The backup you restore from is `completed`.

Every step below begins in the `Backups` pane, on the page used to
manage that database. See
[Using the pgEdge Starfleet Console](console_overview.md) to reach
that page.

## Viewing Your Backups

The `Backups` pane shows every backup made from the database. Each
entry lists:

- The backup's ID.
- Its status, for example `completed`.
- A `hot` or `durable` tag.
- The backup's duration.
- The time since that backup ran.

![The Backups pane, listing entries by ID, status, tier tag, and
time](../images/sf_backups_page.png)

Both tiers run on a schedule the platform sets, with no tier to turn
on or off. A `hot` backup runs daily, stays with the database itself,
and restores fastest. A `durable` backup also runs daily, is kept
separately in object storage, and restores slower. The console
offers no control to trigger a backup outside that schedule, adjust
how long one is kept, or remove one.

The Activity Log page records the status and name of every task run
against the database, a restore included. A backup must finish
running before it becomes a valid restore point. Judge whether a
backup is ready from its own status in the `Backups` pane rather than
from its task within the Activity Log. A task there can read
`succeeded` while the backup itself still reads `pending`.

## Restoring a Database from a Backup

1. Select `Restore` next to the backup to restore from.

    The control stays disabled, with a tooltip stating why, until
    that backup reads `completed`. Selecting `Restore` opens the
    `Restore from backup` popup, which states the backup's date and
    time and warns that changes made after that point are lost. The
    popup also states that the database is briefly unavailable
    during the restore and keeps its name and connection details
    throughout.

    ![The Restore from backup popup, showing the backup's date, a
    data-loss warning, and Restore and Cancel
    controls](../images/sf_backups_restore.png)

2. Select `Restore` in the popup to confirm the restore, or `Cancel`
    to leave the database unchanged.

## Watching the Restore Progress

Once you confirm, a `Restore in progress` popup opens, showing a
progress bar and a checklist naming each step of the restore. A step
is marked done once the restore reaches it. The checklist can
include:

- `Configuring System`
- `Taking Pre-Restore Snapshot`
- `Provisioning Restored Database`
- `Waiting for Database`

A longer restore can report further steps, among them `Repointing
Backups`, `Cutting Over Connection`, and `Retiring Old Incarnation`.

![Progress bar and named steps shown while a restore
runs](../images/sf_backup_restoring.png)

While this runs, the database's status in the console reads
`Modifying`. The restore is asynchronous: the request returns
immediately and the work continues in the background. Wait for the
database to read `Available` before you connect to it.

The restore appears within the Activity Log as `restore-managed`.
See [Reviewing the Activity Log](activity_log.md) for the complete
list of task names and statuses.

## Understanding Pre-Restore Backups

A restore begins by taking a fresh `hot` backup that captures the
database before anything changes: a pre-restore backup. Taking that
backup is mandatory. The restore itself fails when the platform
cannot take that backup.

Any other backup already running can block a pre-restore backup.
The restore then fails too. That failure surfaces on the
restore's own task within the Activity Log, rather than as an error
on the original request. By then, the database already reads
`Modifying`, because the API accepted the restore before the
pre-restore attempt ran.

Nothing in the `Backups` pane sets a pre-restore backup apart from an
ordinary `hot` backup. The platform publishes no retention period for
that backup, and it can take roughly a minute to show up in the list.

Use a pre-restore backup to undo a mistake noticed shortly afterward.
Do not rely on that backup as a lasting restore point.

## Understanding a Restore

A restore runs in place. The database's identifier and the way you
connect to it stay the same throughout, so nothing that connects to
the database needs updating.

A restore overwrites the database's current contents with the
contents of the selected backup. Anything written after that backup
finished is gone once the restore completes.

## Backing Up After a Restore

A backup taken after the restore describes the restored database,
not the state the restore replaced.

A `durable` backup taken after the restore runs once the restored
database is available again. That backup records the new state, not
the state the restore replaced, and cannot undo the restore. Only a
pre-restore `hot` backup, taken before the restore ran, returns the
database to the state the restore replaced.

## Troubleshooting

### `Could not start the restore.` Appears

A red notification reading `Could not start the restore.` means the
API refused the restore request. The database was not `Available`,
or another operation was already running against it.

When the API sends its own message, the console displays that text.
Otherwise the console shows `Could not start the restore.` as its
standard message.

Wait for the database to read `Available`. Then repeat the restore.

### The Restore Control Is Disabled

The `Restore` control beside a backup stays disabled until that
backup reads `completed`. The tooltip on that control states the
reason. Choose a completed backup, or wait for the current one to
finish.
