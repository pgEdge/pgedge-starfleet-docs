# Reviewing the Log Files

The `Logs` page displays the Postgres engine log for your database, with the
newest line at the top; each entry shows the timestamp, log level (for
example, `LOG`), and message.

The page provides the following controls:

* the `100`, `250`, `500`, and `1000` buttons control how many of the newest
  log lines load.
* `Live tail` follows new log entries as they arrive, fetching new lines
  every 8 seconds; `Custom` specifies a fixed time range instead.
* the `Search messages` field filters entries by keyword.
* `Live` toggles automatic updates on or off, and is disabled while a
  `Custom` range is applied.
* a severity button (for example, `log` or `fatal`) filters entries by
  level.
* the copy and download icons (in the upper-right corner of the log table)
  copy or download the lines currently shown.

!!! hint

    The severity buttons and the `Search messages` field filter the lines
    already loaded rather than fetching more, so raise the line count to reach
    older entries. If new lines arrive while you are scrolled away from the
    top, a button appears counting them, and selecting it returns you to the
    newest line. `Load older lines`, at the foot of the table, extends the
    loaded history until the page reads `End of the loaded history`.

![The Logs page](../images/sf_logs_all.png)

## When the Page Shows a Message Instead of Lines

The page shows one of these messages in place of the log table:

* `Couldn't load logs` means the read failed. Select the `Retry` button; if the
  error repeats, narrow the time range or lower the line count.

* `No logs in this window` means the read succeeded and the window held no
  lines. Raise the line count, or widen a custom range. A quiet database writes
  few engine log lines.

* `No lines match the current filter` means lines loaded, but the severity
  buttons or the search box excluded all of them. Clear the filter. Filters
  apply only to the lines already loaded, so raise the line count to reach
  further back rather than expecting a filter to fetch more.

* `Could not copy the log lines to your clipboard` appears when the copy
  icon cannot reach the clipboard. The cause is a browser-permission or
  non-secure-context issue, rather than anything about the database. Use
  the download icon instead, which writes the same lines to a text file.
