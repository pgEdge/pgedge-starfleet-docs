# Restoring from Backup

The `Backups` pane on your database's management page lists the backups
taken of your database. Each backup is either a `hot` backup, the
fastest to restore from, or a `durable` backup, kept apart from the
database's own storage and slower to restore.

A `hot` backup is taken daily on every database. A `durable` backup is
taken daily as well, but only on a database that has the durable tier
enabled for it.

Backups are taken on a schedule. The console has no button for taking
one, and you cannot delete a backup or change how long one is kept.

Each backup entry displays:

* The backup ID.
* A tag indicating whether the backup is a `hot` or `durable` backup.
* The backup status (for example, `completed`).
* How long ago the backup was taken, and how long it took to run.

![The Backups page](../images/sf_backups_page.png)

## Only Completed Backups Can Be Restored

The `Restore` button is disabled on any backup whose status is not
`completed`, and the tooltip on the disabled button says so. The API
refuses any other restore point upfront.

A backup that is still running is not a restore point yet. Read its
status in this list rather than the outcome of its task in the Activity
Log, because a `backup-managed` task can read `succeeded` while the
backup record it produced is still `pending`.

The database itself has to be `available`. A restore is one of five
Managed writes admissible only from that status, so it is refused
against a database that is `creating`, `modifying`, `degraded`, or
already busy with an earlier write.

For the statuses and the task names, see
[Reviewing the Activity Log](activity_log.md).

## Restoring Your Database

Select the `Restore` button, to the right of a backup, to restore your
database to the selected backup. The `Restore from backup` popup opens,
confirming the date and time of the backup you selected. The popup
warns you that any changes made after that point in time are lost, and
notes that the database keeps its name and connection details, and is
briefly unavailable while the restore runs. A `hot` backup of
the current data is taken first, before the restore begins.

![The Restore from backup popup](../images/sf_backups_restore.png)

Select `Restore` to confirm, or `Cancel` to close the popup without
restoring the database.

**The restore happens in place.** The database keeps its ID and its
connection details, so nothing your application holds needs changing
afterwards. It replaces the current data, so anything written since the
backup was taken is no longer in the database.

The restore is asynchronous. The API answers with the database in
status `modifying` and recovers in the background, so the console shows
the database as `Modifying` while the restore runs. Wait for
`Available`.

Once you confirm, a `Restore in progress` popup opens, showing a
progress bar and a checklist of restore steps:

* `Configuring System`
* `Taking Pre-Restore Snapshot`
* `Provisioning Restored Database`
* `Waiting for Database`

Each step is checked off as it completes:

![The Restore in progress popup](../images/sf_backup_restoring.png)

The checklist shows the steps reported for the restore task, so a
restore can list more of them, including `Repointing Backups`,
`Cutting Over Connection`, and `Retiring Old Incarnation`.

In the Activity Log, the operation appears as `restore-managed`.

## The Backup Taken Before the Restore

Before replacing anything, the restore takes a `hot` backup of the
database as it stands, so a restore run by mistake can itself be
undone. That step is mandatory. If that backup cannot be taken, the
restore fails rather than proceeding, and a backup already running
fails it too.

That refusal arrives on the restore's task rather than as an error on
the request. The API has already accepted the restore and the database
is already `modifying`, so the Activity Log is where it surfaces.

Three things about that backup before you go looking for it:

* **It doesn't appear in the list immediately.** The pre-restore backup
  surfaces in the `Backups` pane up to about a minute after the restore
  starts.

* **Nothing marks it as one.** In the list it is identical to any other
  `hot` backup. Identify it as the `hot` backup created at the moment the
  restore started.

* **It isn't an archive.** Treat it as a way back from a mistake
  noticed shortly afterwards, not as a restore point you can count on
  later.

## Backups Taken After a Restore

On a database with durable backups, the restore also leaves a `durable`
backup, taken from the restored database once it is up. That one
records the state the restore produced, not the state it replaced, so
it is not a way back.

Backups dated after a restore describe the restored database. The only
route back to the state the restore replaced is the pre-restore `hot`
backup described above.

## When a Restore Is Refused

`Could not start the restore.` is a red notification meaning the restore
request was refused. It is the fallback text, and the console shows the API's
own message where it sends one. A restore needs the database `Available`, and
only a completed backup can be restored from. Wait for `Available` and try
again.

## Related Pages

* [Reviewing the Activity Log](activity_log.md) covers the
  statuses and the task names a restore moves through.
