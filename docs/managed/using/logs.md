# Reviewing the Log Files

The `Logs` pane on your database's management page displays the most recent
entries from your database's log file; each entry shows the timestamp, log
level (for example, `LOG`), and message.

The `Logs` page displays the complete Postgres engine log for your database,
live-updated as new entries are written.

* Select `100`, `250`, `500`, or `1000` to control how many log lines are
  loaded.
* Select `Live tail` to continuously stream new log entries as they're written,
  or select `Custom` to specify a fixed time range.
* Use the `Search messages` field to filter entries by keyword.
* Toggle `Live` to enable or disable automatic updates.
* Select `fatal` or `log` to filter entries by severity level.
* Use the copy and download icons (in the upper-right corner of the log table)
  to copy or download the loaded log lines.

![The Logs page](../../images/sf_logs_all.png)

