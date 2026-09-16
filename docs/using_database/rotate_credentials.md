# Rotating Database Credentials

Rotating a database role's password replaces it with a new one the platform
generates. The `Rotate credentials` button on the `Connect` pane triggers
this, and for roughly ten seconds afterwards neither the old password nor
the new one can be relied on. Your account has one other credential,
the API client secret, which is replaced rather than rotated.

Rotation is not on the `Actions` menu. For the options that are, see
[Accessing Management Options with the Actions Menu](../using_console/actions.md).

## Rotating from the Connect Pane

The `Connect` pane on a database's overview page displays the connection
string, the psql command, the database name, the domain, the user, and the
password, with `Rotate credentials` underneath them.

The pane shows an `Admin` tab and an `Application` tab, one per built-in
role. Rotating from a tab rotates the Postgres user named on it.

The button is disabled while the database is provisioning, and the console
enables it on a database that is `Available` or `Degraded`. The API admits a
rotation only from `Available`, so a `Degraded` database can offer the button
and still refuse the write.

For the location of the `Connect` pane, see
[Connecting with psql](../connecting/psql.md). For the purpose of each
role, see [Managing Database Roles](roles.md).

## What Happens When You Confirm

The button opens a `Rotate credentials` dialog naming the Postgres user, with
`Rotate credentials` and `Cancel`. Rotating the `Application` role adds a note
about the MCP and RAG Servers restarting.

Confirming does three things:

* The API accepts the change and starts the work. The database moves to
  `Modifying`.

* A `rotate-password-managed` task appears in the Activity Log for this
  database. The call returns no task ID, so find the task by pasting the
  database ID into the Activity Log's `Subject ID` filter. See
  [Reviewing the Activity Log](../using_console/activity_log.md).

* The console re-reads every per-role credential, so the `Connect` pane shows
  the new password rather than a stale one for any role.

A success notification reads `Rotated the password for <user>.`

## Wait for Available Before Switching Over

The database reads `Modifying` for about ten seconds.

Until it is back to `Available`, two things are true at once:

* The new password does not authenticate yet. The `Connect` pane provides
  it to you before the running database accepts it, so reading it back and
  connecting immediately fails.

* The old password may still work. The rotation is not proof the old one
  is invalid. That outlives the task as well: a succeeded task says the
  new credential is live, never that the old one has stopped working.

Wait for `Available` before switching anything over. The status badge on
the same page is the signal.

Rotation breaks any session still using the old password, so switch every
client using the rotated role, not only the client used for testing.

## Rotating the Application Role Restarts MCP and RAG

The MCP and RAG Servers read the database's `app` password once, at
startup, so a rotation of the `Application` role restarts them. They
resume using the new password by the time the database reads
`Available` again.

Expect a short gap in service on both, and no change to your MCP client
configuration. See
[Enabling and Using the MCP Server](../serving_ai_content/mcp.md).

Rotating the `Admin` role does not restart them, because both servers
connect as `app`.

## Read the New Password Back

The new password is not shown by the rotation itself.

Read it from the `Password` field on the `Connect` pane, which is masked with a
reveal control and a copy button. The `Connection string` and `psql command`
rows show the password masked and copy it filled in, so copying either gives
you a working string without displaying the secret on screen.

Then update every place the old password is saved. That includes:

* application configuration and environment variables
* connection strings held by a deployment platform or a secret store
* local `psql` invocations, `.pgpass` entries, and GUI client profiles
* CI jobs that connect to this database

## Rotation Refused

### A Refusal

The console shows `Could not rotate credentials. Please try again.`,
or the API's own message where it sends one. The API's rotation
refusal reads `rotating a password requires the database to be
available; it is busy with another operation`.

Waiting resolves this. A database already `Modifying` because of an
earlier restore or resize refuses a rotation for the same reason.

### An Uncertain Outcome

If no notification arrives, do not select the button again. A
rotation sends the new credential to the database before it waits for
confirmation, and the database applies it independently, so a repeat
risks replacing a credential that is already in place.

Read the Activity Log instead. Find the `rotate-password-managed` task for
this database and compare its `Updated at` against the current time rather
than against its `Created at`. A rotation completes in seconds, so a task
still running whose `Updated at` is minutes old has stopped progressing. A
task whose `Created at` and `Updated at` are equal finished inside the
API's one-second timestamp resolution and is healthy.

### A Failure

A rotation that fails leaves the database `Degraded`, with the new
credential recorded but not applied, and a `Degraded` database is
refused another rotation until it is recovered.

## The API Client Secret

The REST API authenticates with an API client, managed on the `API Clients` tab
under `Settings`. See
[The API Clients Tab](../using_console/settings.md#the-api-clients-tab).

A client's secret is returned once, at creation, and cannot be fetched again.
The creation dialog says so directly: "Please copy the authentication ID and
secret below. You cannot retrieve the secret value again later." Both values
carry copy buttons.

Rotating one is therefore replacement, not rotation, and the order matters,
because the old credential is the working one until the new one has proven
itself:

1. Create the replacement client with `Create API Client`, and copy both the
   `Auth ID` and the `Auth Secret` before closing the dialog.

2. Point whatever uses the credential at the new pair, so nothing keeps
   running as the old client.

3. Confirm the new pair works by making a call with it.

4. Only then delete the old client. A deleted client cannot be recovered, only
   replaced.

## Next Steps

These pages cover related tasks that build on rotating credentials.

* [Managing Database Roles](roles.md) describes the roles whose
  passwords these are, and [Connecting with psql](../connecting/psql.md)
  explains how to handle the password once you have it.

* [Enabling and Using the MCP Server](../serving_ai_content/mcp.md)
  describes the server a rotation of the `Application` role restarts.

* [Reviewing the Activity Log](../using_console/activity_log.md)
  explains how to find the `rotate-password-managed` task.
