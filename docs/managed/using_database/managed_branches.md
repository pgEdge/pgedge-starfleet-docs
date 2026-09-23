# Understanding Branches

A branch gives you a separate database that starts with your real data, so
you can test against it and leave the original unchanged. This feature is
called Fast Branching. The database you copy is the branch's source database,
or its parent. pgEdge assigns every branch a name, which the console calls the
assigned name. To create, connect to or delete a branch, see
[Creating and Managing Branches](../using_console/managed_branches.md).

## Copying a Database into a Branch

Creating a branch copies the source database by copy-on-write. The branch
starts with the source's data as it stood when you created the branch.

From then on, the branch and its source are independent. Nothing you
change on the branch reaches the source database. A change made on the source
database never reaches the branch.

## Settings a Branch Copies from Its Source

A branch copies the following settings from its source database when you
create it:

| Setting | On the branch |
|---------|---------------|
| Size | The same size as the source at creation. |
| Postgres version | The same version as the source. |
| Database name and user | The same database name and user name as the source. |
| Services | The AI services the source was running, with the same configuration. |
| Network access | Either a copy of the source's allowlist rules, or rules you set for the branch. |

Each of these settings is decided at creation. A later change to the source
database, such as a resize or a new allowlist rule, does not change the branch.

## Credentials a Branch Receives

A branch has its own connection details. The assigned name is also the
branch's hostname, so every branch has a different address from its
source.

The branch has its own password, which is different from the source
database's password. Copy the password from the branch's own page.

An MCP server on the branch has its own MCP token. The source's MCP token
does not work against the branch, so an MCP client needs the branch's own
token. A RAG server on the branch uses the same API tokens as the source,
so an existing RAG integration keeps working without new tokens.

## Changes a Branch Does Not Accept

A branch keeps every setting it was created with. The following changes
are not available on a branch, with what to do instead:

- A branch cannot be resized. Create a new branch after resizing the
  source, because the new branch copies the new size.
- A branch's network access cannot be changed. Create a new branch with
  the rules you need.
- A branch has no backups. After a branch is deleted, its data cannot be
  restored. Create a new branch from the source instead.
- A branch cannot be promoted to replace its source database. Copy the
  data you need from the branch to the source yourself.
- A branch cannot be branched again. Create each branch from the source
  database.
- A branch's services cannot be added, changed or removed. Change the
  services on the source, then create a new branch.

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

## Limits on Branches

The number of branches you can create depends on your plan, and applies
to each database separately:

| Plan | Branches per database |
|------|-----------------------|
| Trial | 3 |
| Paid | 5 |

A branch stops counting toward the limit as soon as you request its
deletion. You can create another branch while the deleted branch is still
being removed.

A branch can have a display name of up to 25 characters. The display name
is optional and is shown only in the console. A branch without a display
name is shown by its assigned name.

## Billing for Branches

A branch is billed by the hour, which is different from its source
database's monthly billing. The branch's charges are added to your
existing subscription, so creating a branch needs no separate checkout.

Billing for a branch follows its status:

- Billing starts when the branch's status becomes `available`.
- Billing is paused while the branch is `suspended`.
- Billing stops as soon as you request the branch's deletion.

Your invoice shows the final charge for each branch.

## Working with the Source Database

A source database with branches has three restrictions:

- The source database cannot be resized while it has branches, because
  each branch keeps the size it was created with. Delete the source's
  branches first, then resize the source database.
- Delete a database's branches before you delete the database. The
  console does not delete a database that still has branches.
- A branch cannot be created while a payment on the subscription is
  overdue, or while the source database's status is not `available`.

## Next Steps

To create your first branch, see
[Creating and Managing Branches](../using_console/managed_branches.md).
