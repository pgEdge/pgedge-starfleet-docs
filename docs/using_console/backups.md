# Restoring a pgEdge Starfleet Managed Database from a Backup

The `Backups` pane on a Managed database's management page lists the
backups taken of that database. Selecting the `Restore` button is the
one action on this page that changes the database.

This page uses three terms:

* A `hot` backup is the fastest backup to restore from.
* A `durable` backup is kept apart from the database's own storage, and
  is slower to restore.
* A restore replaces the current data of the database with the data in
  the backup you select.

This page has eight sections:

* [Before You Start](#before-you-start)
* [Reading the Backups Pane](#reading-the-backups-pane)
* [Checking the Backup and the Database Status](#checking-the-backup-and-the-database-status)
* [Restoring the Database](#restoring-the-database)
* [Finding the Pre-Restore Backup](#finding-the-pre-restore-backup)
* [Reading Backups Dated After a Restore](#reading-backups-dated-after-a-restore)
* [Troubleshooting](#troubleshooting)
* [Next Steps](#next-steps)

## Before You Start

Open the `Backups` pane on the database's management page, because
every step on this page starts there.

Collect two things before you start:

* The backup you want to restore from, read from the `Backups` pane.
* The database's status, which a restore needs to be `available`.

A backup already running also fails the restore, so check that no
backup of this database is in progress.

## Reading the Backups Pane

The `Backups` pane lists the backups taken of the database. Each backup
is either a `hot` backup or a `durable` backup.

A `hot` backup is taken daily on every database. A `durable` backup is
taken daily as well, but only on a database that has the durable tier
enabled for it.

Backups are taken on a schedule. The console has no button for taking a
backup, and you cannot delete a backup or change how long one is kept.

Each backup shows four values:

* The backup ID.
* A badge showing whether the backup is `hot` or `durable`.
* The backup status, for example `completed`.
* How long ago the backup was taken, and how long it took to run.

![The Backups pane on a database's management page](../images/sf_backups_page.png)

## Checking the Backup and the Database Status

A restore needs a `completed` backup and a database in status
`available`.

The `Restore` button is disabled on any backup whose status is not
`completed`, and the tooltip on the disabled button says so. The API
refuses a restore from any other backup.

A backup that is still running cannot be restored from. Read the
backup's status in the `Backups` pane rather than the outcome of its
task in the Activity Log. A `backup-managed` task can read `succeeded`
while the backup it produced is still `pending`.

The database itself has to be `available`. A restore is one of five
Managed writes allowed only from that status, so a restore is refused
against a database that is `creating`, `modifying`, `degraded`, or
already busy with an earlier write.

For the statuses and the task names, see
[Reviewing the Activity Log](activity_log.md).

## Restoring the Database

A restore replaces the current data of the database. The only way to
recover the replaced data is the `hot` backup the restore takes before
it starts.

Restore the database in four steps:

1.  Record the current time. Nothing marks the backup the restore
    takes before it starts, so the time you record here is the only
    way to tell that backup from the day's scheduled one.

2.  Select the `Restore` button to the right of the backup you want.
    The `Restore from backup` dialog opens.

    ![The Restore from backup dialog](../images/sf_backups_restore.png)

3.  Confirm that the dialog shows the date and time of the backup you
    want.

4.  The restore replaces every change written after that backup's time.
    Select `Restore` to confirm.

To close the dialog without restoring the database, select `Cancel`.

The dialog states that every change written after the backup's time is
lost. The dialog also states that the database keeps its name and
connection details, and is briefly unavailable while the restore runs.
The restore takes a `hot` backup of the current data first.

After you confirm, the `Restore in progress` dialog opens. The dialog
shows a progress bar and a list of restore steps, each checked off as
the step completes.

A restore reports these steps:

* `Configuring System`
* `Taking Pre-Restore Snapshot`
* `Provisioning Restored Database`
* `Waiting for Database`

![The Restore in progress dialog](../images/sf_backup_restoring.png)

The list shows the steps reported for the restore task, so a restore
can report more of them, including `Repointing Backups`, `Cutting Over
Connection`, and `Retiring Old Incarnation`.

The restore happens in place. The database keeps its ID and its
connection details, so nothing your application holds needs changing
afterwards. The restore replaces the current data, so anything written
since the backup was taken is no longer in the database.

The restore runs in the background. The console shows the database as
`Modifying` while the restore runs. Wait for `Available`.

In the Activity Log, the operation appears as `restore-managed`.

## Finding the Pre-Restore Backup

Before replacing anything, the restore takes a `hot` backup of the
database as it stands, so a restore run by mistake can itself be
undone. That step is mandatory.

When that backup cannot be taken, the restore fails rather than
proceeding. A backup already running fails the restore too.

The refusal arrives on the restore's task rather than as an error on
the request. The restore is already accepted and the database is
already `modifying`, so the Activity Log shows the refusal.

The pre-restore backup does not appear immediately. It appears in the
`Backups` pane within about a minute of the restore starting. Nothing
marks the backup as a pre-restore backup, because in the list it is
identical to any other `hot` backup.
Identify the pre-restore backup as the `hot` backup created at the time
you recorded before the restore.

Treat the pre-restore backup as a way to undo a mistake noticed shortly
afterwards, not as a backup you can rely on later.

## Reading Backups Dated After a Restore

On a database with durable backups, the restore also leaves a `durable`
backup, taken from the restored database once that database is running.
That backup records the state the restore produced, not the state the
restore replaced.

Backups dated after a restore describe the restored database. The only
way to recover the state the restore replaced is the pre-restore `hot`
backup.

## Troubleshooting

`Could not start the restore.` is a red notification meaning the API
refused the restore request. The message is the fallback text, and the
console shows the API's own message where the API sends one.

A restore needs the database `Available`, and only a `completed` backup
can be restored from. Wait for `Available`, then start the restore
again.

## Next Steps

[Reviewing the Activity Log](activity_log.md) describes the statuses
and the task names a restore moves through.
