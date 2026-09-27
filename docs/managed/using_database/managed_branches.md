# Understanding Branches

A branch provides a separate pgEdge Starfleet Managed database that
is created containing the source database's data, so you can test
against it, leaving the original unchanged. This feature is called
*Fast Branching*. The database you copy is the branch's source
database, which the console refers to as its parent. Each branch is
assigned a unique name, and can also have a display name of up to 25
bytes; the display name is optional, and the console displays
it only there. A branch without a display name displays its assigned
name instead. To create, connect to or delete a branch, see
[Creating and Managing Branches](../using_console/managed_branches.md).

## Copying a Database into a Branch

Creating a branch copies the source database by copy-on-write. The
branch starts with the source's data as of the moment you created
the branch.

From that point forward, the branch and its source are independent.
Data modifications on the branch are isolated from the source;
modifications on the source do not cascade to the branch.

## Settings a Branch Copies from Its Source

A branch copies the following settings from its source database when you
create it:

| Setting | On the branch |
|---------|---------------|
| Size | The same size as the source at creation. |
| Region | The same region as the source. |
| Postgres version | The same version as the source. |
| Database name and user | The same database name and user name as the source. |
| Services | The MCP server and RAG server the source was running, with the same configuration. |
| Network access for Postgres | Either the source's current allowlist rules, or a new set of rules defined just for the branch. |

Creating the branch fixes each of these settings. A later change to
the source database, such as a new allowlist rule, does not change
the branch.

The network access you choose covers connections to Postgres only. The MCP
server and RAG server on a branch keep the allowlists they had on the source
database.

## Branch Credentials

A branch has its own connection details. The assigned name is also
the branch's hostname, so every branch has a different address from
its source. Each built-in role has its own password on the branch, which
is unique from the source database's password. Select the copy icon
beside `Password` on the branch's page to copy it. A branch's passwords
cannot be rotated.

If the source runs an MCP server, the branch's MCP server has
a unique address and MCP token, so ensure that any connecting MCP
client has the branch's own address and token.
A RAG server on the branch has its own address. The RAG server
details display `Same API tokens as the source.`, because the RAG
server uses the source's provider keys. Point a RAG integration at
the branch's `API base URL` to query the branch.

## Branching Limitations

Unlike the parent database, branch configuration is not easily
modified. The restrictions below apply to the branch itself and to
the source database it was created from.

### Limitations on the Branch

Use the following workarounds to reconfigure your branch as needed:

- A branch cannot be resized. For a larger branch, resize the source
  and create a new branch.
- A branch's network access cannot be changed. For a branch with
  different connection properties, create a new branch from a
  source database with the connection properties you need.
- A branch has no backups, so deleting one loses its data
  permanently. Backups of the source database contain the original
  data as of the moment you created the branch.
- A branch cannot be promoted to replace its source database. Copy the
  data you need into the source database, as
  [Loading Data into Your pgEdge Starfleet Database](managed_loading_data.md)
  describes.
- A branch cannot be branched again. For an additional branch, create
  it directly from the source database.
- A branch's services cannot be added, changed or removed. For a
  branch with different services, change the services on the source,
  then create a new branch.

### Limitations on the Source Database

A source database with branches has three restrictions:

- The source database cannot be resized while it has branches, because
  each branch keeps the size it was created with. Delete the source's
  branches first, then resize the source database.
- Deleting the database also deletes its branches. The console refuses
  the delete while a branch is still `creating`.
- A branch cannot be created while a payment on the subscription is
  overdue, or while the source database's status is not `available` or
  `degraded`.

## Branch Statuses

The status of a branch appears in a badge on the branch's row and on the
branch's page. The following table describes each status:

| Status | Description |
|--------|-------------|
| `creating` | The branch is being copied. It cannot be reached until its status is `available`. |
| `available` | The branch is ready for connections. |
| `suspending` | The branch is being hibernated. |
| `suspended` | The branch is hibernated and cannot be reached. Billing for the branch is paused. |
| `resuming` | The branch is coming back from hibernation. |
| `deleting` | Deletion of the branch has been requested. Billing for the branch has already stopped. |
| `failed` | The branch could not be created. Delete the branch and create a new one. |

A branch becomes `suspended` when the subscription is unpaid or has
expired. Settling the subscription resumes the branch.

## Billing for Branches

pgEdge bills a branch by the hour, unlike its source database's
monthly billing. pgEdge adds the branch's charges to your existing
subscription, so creating a branch needs no separate checkout.

Billing for a branch follows its status:

- Billing starts when the branch's status becomes `available`.
- Billing pauses while the branch is `suspended`.
- Billing stops as soon as you request the branch's deletion.

Your invoice displays the final charge for each branch.

The number of branches you can create depends on your plan, and applies
to each database separately:

| Plan | Branches per database |
|------|-----------------------|
| Trial | 3 |
| Paid | 5 |

A branch stops counting toward the limit as soon as you request its
deletion. You can create another branch while the deleted branch is still
being removed.
