# Reviewing the Log Files

The `Logs` pane on your database's management page displays the most
recent entries from your database's log file. Each entry shows the
timestamp, log level (for example, `LOG`), and message.

The `Logs` page displays the Postgres engine log for your database.
Records arrive newest first, with the newest line displayed at the top.

* Select `100`, `250`, `500`, or `1000` to control how many of the
  newest log lines are loaded.

* Select `Live tail` to follow new log entries as they arrive, which
  fetches new lines every 8 seconds, or select `Custom` to specify a
  fixed time range.

* Use the `Search messages` field to filter entries by keyword.
* Toggle `Live` to enable or disable automatic updates. `Live` is
  disabled while a `Custom` range is applied.

* Select a severity button (for example, `log` or `fatal`) to filter
  entries by level.

* Use the copy and download icons (in the upper-right corner of the log
  table) to copy or download the lines currently shown.

!!! hint

    The severity buttons and the `Search messages` field filter the lines
    already loaded rather than fetching more, so raise the line count to reach
    further back. When new lines arrive while you are scrolled away from the
    top, a button appears counting them, and selecting it returns you to the
    newest line. `Load older lines`, at the foot of the table, extends the
    loaded history until the page reads `End of the loaded history`.

![The Logs page](../images/sf_logs_all.png)

## When the Page Shows a Message Instead of Lines

The page shows one of these messages in place of the log table:

* `Couldn't load logs` means the read failed, and the panel displays a
  `Retry` button. Use it, and narrow the time range or lower the line count
  if it repeats.

* `No logs in this window` means the read succeeded and the window held no
  lines. Raise the line count, or widen a custom range. A quiet database
  writes few engine log lines.

* `No lines match the current filter` means lines loaded and the severity
  buttons or the search box excluded all of them. Clear the filter. Filters
  apply only to the lines already loaded, so raise the line count to reach
  further back rather than expecting a filter to fetch more.

`Could not copy the log lines to your clipboard.` appears when the copy icon
could not reach the clipboard. The cause is a browser permission or a
non-secure context, rather than anything about the database. Use the
download icon instead, which writes the same lines to a text file.

