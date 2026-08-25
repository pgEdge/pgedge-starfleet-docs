# Restoring from Backup

The `Backups` pane on your database's management page displays a list of the
backups taken of your database; each backup is either a `hot` backup (fast,
short-term storage) or a `durable` backup (longer-term, resilient storage).

Each backup entry displays:

* The backup ID.
* A tag indicating whether the backup is a `hot` or `durable` backup.
* The backup status (for example, `completed`).
* How long ago the backup was taken.

![The Backups page](../../images/managed_backups_page.png)

Select the `Restore` button, to the right of a backup, to restore your
database to the selected backup. The `Restore from backup` popup opens,
confirming the date and time of the backup you selected; the popup warns you
that any changes made after that point in time will be lost, and lets you know
that the database keeps its name and connection details, and is briefly
unavailable while the restore runs. A snapshot of the current data is taken
first, before the restore begins.

![The Restore from backup popup](../../images/managed_backups_restore.png)

Select `Restore` to confirm, or `Cancel` to close the popup without restoring
the database. Once you confirm, a popup in the lower-right corner of the
window lets you know that the backup is restoring.




