# Reviewing the Activity Log

When you start a task in the console (for example, deploying a database or
restoring from a backup), the console adds the task to the table on the
`Activity Log` page. The Activity Log page organizes console activity into a
table that you can sort and filter.

The console also displays a task progress bar on the main console page for
the related database.

Select `show details` on the progress bar to display additional information
about the task in progress. Each point on the task bar corresponds to an
event detail. To close the task bar, select the `X` in its upper-right
corner.

![Reviewing the Activity Log](images/sf_activity_log.png)

The Activity Log page displays the following columns:

* `Task name` identifies the type of task for the table entry (for example,
  `create`, `restore`, `edit-display-name`, or `upgrade-size`).
* `Status` indicates the state of the task; values are `running`,
  `succeeded`, `queued`, or `failed`.
* `Created At` is the timestamp at which the task started.
* `Updated At` is the timestamp at which the console last updated the task.

Use the arrow to the left of a `Task name` to expand the task information and
view details about the selected task.

## Filtering and Sorting the Activity Log

The Activity Log table supports filtering and sorting by column value. A
drop-down filter icon located next to each column name lists the available
values for that column. Select a value from the filter drop-down to
re-arrange the table and move matching content to the top. Select the arrow
between the column name and the filter drop-down to reverse the display order
based on that column.
