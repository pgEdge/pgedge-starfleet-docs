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

![Reviewing the Activity Log](images/sf_activity_log.png)

The Activity Log page displays the following columns:

* `Task name` identifies the type of task for the table entry (for
  example, `create-managed`, `restore-managed`, or
  `update-managed-size`). The console shows the raw name the API gives
  the task, with a tooltip that names it in plain language and says
  what it is.
  <!-- ui:src/components/tasks/index.tsx -->
* `Subject kind` is the kind of thing the task acted on, one of
  `database`, `cluster`, or `ingress`.
* `Subject ID` is the ID of that thing. For a Managed database, this is
  the database ID shown in the `Details` pane.
* `Status` indicates the state of the task. The values are `running`,
  `succeeded`, `queued`, and `failed`.
* `Created at` is the timestamp at which the task started.
* `Updated at` is the timestamp at which the console last updated the
  task.

<!-- ui:src/components/tasks/index.tsx -->

Use the arrow to the left of a `Task name` to expand the task
information and view the task's own steps and their progress.


## Filtering and Sorting the Activity Log

The Activity Log table supports filtering and sorting by column value.
A drop-down filter icon located next to each column name lists the
available values for that column. Select a value from the filter
drop-down to restrict the table to matching rows. Select the arrow
between the column name and the filter drop-down to reverse the display
order based on that column.
<!-- ui:src/components/tasks/index.tsx -->

The `Task name` filter offers a fixed list of names: `create`,
`update`, `delete`, `restore`, `backup`, `restore-from-pgdump`,
`restore-from-pgbackrest`, `update-backup-stores`, `add-nodes`,
`remove-node`, `replicate`, `apply`, and `destroy`. None of the Managed
task names below is in that list, so filter a Managed database's work
by pasting its database ID into `Subject ID` rather than by name.
<!-- ui:src/components/tasks/index.tsx -->


## Managed Task Names

Every Managed operation writes a task. These are the names in use
today.
<!-- saas:internal/starfleet/managed_databases/jobs/jobs.go -->

| Task name | What it is |
|-----------|------------|
| `create-managed` | Provisioning a new database. |
| `delete-managed` | Deleting a database. |
| `suspend-managed` | Hibernating a database. |
| `resume-managed` | Bringing a database back from hibernation. |
| `update-managed-size` | The resize. The name carries `size` as an infix rather than the suffix the others use. <!-- M:677 --> |
| `rotate-password-managed` | A role password rotation. |
| `update-managed` | Every services change. An MCP enable, an MCP configure, a RAG enable, and a service removal all write this one name, so the name alone does not say which service changed. <!-- M:678 --> |
| `restore-managed` | Restoring the database in place from a backup. |
| `backup-managed` | A backup. Read the caution below before trusting its status. |

### Task Names That Do Not Match the Console

**`update-managed` cannot tell you which service changed.** Every
services write shares it. To find out what changed, expand the row and
read the steps, or read the `AI Services` pane.
<!-- M:678 -->

**`update-managed-size` is the resize**, not a generic size-related
update. It is the task behind the `Upgrade size` action described in
[Accessing Management Options with the Actions Menu](managed/using/actions.md#upgrading-the-size-tier).
<!-- M:677 -->

**`backup-managed` can read `succeeded` while the backup is still
pending.** The task claims to have taken the backup, and its steps read
`Configuring System` then `Taking Backup` at 100 percent succeeded,
while the backup record it produced is still `pending`. Both reach a
terminal state, just not together. Read the backup's own status on the
`Backups` pane rather than the task's.
<!-- M:962 -->
<!-- 18 seconds measured between the task reaching succeeded and the -->
<!-- backup record leaving pending -->

### What a Succeeded Task Means

A task that reads `succeeded` means the status has been set. A
succeeded task never sits beside a status the operation had not yet
applied.
<!-- M:561 -->

What it does not say is which status resulted, or that the database is
usable. Read the status badge for that.
<!-- M:567 -->

Delete is the exception. A succeeded delete removes the database
record, so the database disappears from the list, and that
disappearance is the confirmation. A delete that leaves the database
behind is one whose task failed.
<!-- M:572 -->

A services change is the other exception. A succeeded `update-managed`
means the API-side work finished, and the deployed server lags behind,
by roughly a minute or two for a configure, and around fifteen to
twenty seconds for a first MCP enable.
<!-- M:748 -->


## Database Statuses

The status is the badge on the Databases list and on the database
header. The API publishes nine values. The table gives the meaning of
each and the writes each one admits.
<!-- M:534 -->

| Status | What it means | Which writes it admits |
|--------|---------------|------------------------|
| `creating` | Being provisioned. Not yet usable. <!-- M:541 --> | None of the five writes below. Delete is admissible. <!-- M:711 --> |
| `available` | Ready. The only status every write is admissible from. <!-- M:542 --> | All of them. |
| `modifying` | A restore, resize, services change, or credential rotation is in flight. <!-- M:543 --> | None of the five. Delete is admissible unless a billing provision is unfinished, which a resize reopens. <!-- M:711 --> |
| `deleting` | Being torn down. <!-- M:544 --> | None, including delete. <!-- M:711 --> |
| `failed` | The last operation failed. That covers a create, a teardown, a suspend or resume, or a restore that reported success without a committed cutover. The database record is kept either way. <!-- M:545 --> | None of the five. Delete is admissible. <!-- M:711 --> |
| `degraded` | A resize failed after the database was already up. A failed credential rotation lands here too. <!-- M:546 --> | None of the five, whatever the console's buttons allow. See the note below. |
| `suspending` | Being hibernated. <!-- M:547 --> | None of the five. |
| `suspended` | Hibernated. <!-- M:548 --> | None of the five. |
| `resuming` | Coming back from hibernation. <!-- M:549 --> | None of the five. |

`available` is the one to wait for. Check against it rather than
against "not creating", because a database can reach `failed` or
`degraded` without passing through `creating` again.
<!-- M:551 -->

Nothing in the console suspends or resumes a database. There is no
action for either on the Managed database pages, only a banner on a
database that is already suspended. The last three statuses are listed
because a database suspended by some other means still reports them.
<!-- ui:src/components/databases/managed/details/DetailsSuspendedBanner.tsx -->
<!-- M:556 -->

**A `degraded` database shows its action buttons enabled.** The console
treats `available` and `degraded` alike for `Rotate credentials`, the
display-name edit, and deletion protection, and the API admits the five
writes below only from `available`. So an action offered on a
`degraded` database can still be refused. `Upgrade size` is the
exception the console already gates, being offered only from
`available`.
<!-- ui:src/components/databases/managed/ManagedDatabaseDetails.tsx -->
<!-- ui:src/utils/managedDatabase.ts canResizeManagedDatabase -->

### The Five Writes That Need Available

Five operations are admissible only from `available`, including against
a database already `modifying` because of an earlier change:
<!-- M:578 -->

* Restore from a backup
* Upgrade size
* Any services change, meaning enabling, configuring, or disabling the
  MCP or RAG server
* Rotate credentials
* Take a backup

Everything else is looser. Editing the display name and switching
deletion protection take no hold on the database and succeed against a
busy one. Delete does not wait for a restore to finish.
<!-- M:711 -->

A write attempted from any other status is refused, and the console shows
the API's message where it sends one. The message names the status the API
wanted rather than the one it found, so read the current status from the
status badge, wait for `available`, and try again.
<!-- M:586 --> <!-- M:601 -->


## Other Statuses and Task Names You May See

A status or a task name outside the two lists above can appear.
<!-- M:534 --> <!-- M:656 -->
<!-- the API declares both as bare strings with no enum -->

* A tenant with older databases carries task names that are not in the
  table above. Unsuffixed `create`, `update`, and `delete` appear
  beside the `-managed` ones, along with names such as `replicate` and
  `restore-from-pgdump`.
  <!-- M:668 -->
  <!-- a 100-task read missed six names a 400-task read found, so no -->
  <!-- sample proves the list complete -->
* A status you do not recognise is not automatically an error. Read it,
  and treat anything that is not `available` as a database that is not
  ready for the five writes.
  <!-- M:556 -->


## Related Pages

* [Restoring from Backup](managed/using/backups.md) covers the restore
  this glossary keeps pointing at.
* [Accessing Management Options with the Actions Menu](managed/using/actions.md)
  covers the resize, the display-name edit, and deletion protection.
