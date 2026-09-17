# Reviewing the Activity Log

When you start a task in the console (for example, deploying a database
or restoring from a backup), the console adds the task to the table on
the `Activity Log` page. The Activity Log page organizes console
activity into a table that you can sort and filter.

The console also displays a task progress bar on the main console page
for the related database.

Select `show details` on the progress bar to display additional
information about the task in progress. Each point on the task bar
corresponds to an event detail. To close the task bar, select the `X`
in its upper-right corner.

![Reviewing the Activity Log](../images/sf_activity_log.png)

The Activity Log page displays the following columns:

* `Task name` identifies the type of task for the table entry (for
  example, `create-managed`, `restore-managed`, or
  `update-managed-size`). The console shows the raw name the API gives
  the task, with a tooltip that names it in plain language and explains
  what it does.

* `Subject kind` is the kind of resource the task acted on, one of
  `database`, `cluster`, or `ingress`.
* `Subject ID` is the ID of that resource. For a Managed database,
  this is the database ID shown in the `Details` pane.
* `Status` indicates the state of the task. The values are `running`,
  `succeeded`, `queued`, and `failed`.
* `Created at` is the timestamp at which the task started.
* `Updated at` is the timestamp at which the console last updated the
  task.

Use the arrow to the left of a `Task name` to expand the task
information and view the task's own steps and their progress.

## Filtering and Sorting the Activity Log

The Activity Log table supports filtering and sorting by column value.
A drop-down filter icon located next to each column name lists the
available values for that column. Select a value from the filter
drop-down to restrict the table to matching rows. Select the arrow
between the column name and the filter drop-down to reverse the display
order based on that column.

## Managed Task Names

Every Managed operation writes a task. The following table describes the
task names currently in use:

| Task name | Description |
|-----------|-------------|
| `create-managed` | This task provisions a new database. |
| `delete-managed` | This task deletes a database. |
| `suspend-managed` | This task hibernates a database. |
| `resume-managed` | This task brings a database back from hibernation. |
| `update-managed-size` | This task performs a resize. |
| `rotate-password-managed` | This task rotates the password for a role. |
| `update-managed` | This task represents every services change; an MCP enable, an MCP configure, a RAG enable, and a service removal all write this same name, so the name alone does not identify which service changed. |
| `restore-managed` | This task restores the database in place from a backup. |
| `backup-managed` | This task takes a backup; read the caution below before trusting its status. |

### Task Names That Do Not Match the Console

Some task names are easy to misread against what actually happened in the
console:

* **`update-managed` cannot tell you which service changed.** Every services
  write shares this task type. To find out what changed, expand the row and
  read the steps, or review the `AI Services` pane.
* **`update-managed-size` refers to a resize, not a generic update.** This is
  the task associated with the `Upgrade size` action described in
  [Accessing Management Options with the Actions Menu](actions.md#upgrading-the-size-tier).
* **`backup-managed` can read `succeeded` while the backup is still pending.**
  The task claims to have taken the backup: its steps show
  `Configuring System` then `Taking Backup`, both at 100 percent and marked
  `succeeded`, while the backup record it produced is still `pending`. Both
  reach a terminal state, but not at the same time. Read the backup's own
  status on the `Backups` pane rather than the task's.

### What Succeeded Does Not Tell You

A task that reads `succeeded` means the operation itself finished, and the
console has already applied the resulting status change; there is no lag
between the two. The task record itself does not say which status resulted, or
whether the database is usable.

Delete is the exception. A successful delete removes the database record, so
the database disappears from the list, and the disappearance is the
confirmation. If a delete leaves the database behind, the task failed.

A services change is the other exception. A succeeded `update-managed` means
the API has finished its side of the change, but the deployed server itself
takes longer to reflect it; expect roughly a minute or two for a configure,
and fifteen to twenty seconds for a first MCP enable.

## Related Pages

The following pages provide more detail on topics referenced above:

* [Restoring from Backup](backups.md) describes the restore this page
  keeps pointing at.
* [Accessing Management Options with the Actions Menu](actions.md)
  describes the resize, the display-name edit, and deletion protection.
* [Managing Database Details](../using_database/database_details.md)
  describes database sizes and statuses in full.
