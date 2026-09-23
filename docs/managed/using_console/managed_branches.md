# Creating and Managing Branches

You can create a branch of a database from the console, connect to the
branch, and delete the branch when you are finished with it. Each branch
holds a database's data from the moment you create the branch. The
database you copy is the branch's source database. Each branch has a
label, which is its display name if you gave it one, and its assigned name
otherwise. For how branches behave, see
[Understanding Branches](../using_database/managed_branches.md).

## Before You Start

Branches are managed from the database page of the source database.
Select the database under `Databases` in the navigation pane to open its
page.

- The source database's status must be `available` before you can create
  a branch.
- A branch's network access is set once, when you create the branch, and
  cannot be changed afterward. Decide which addresses need to reach the
  branch before you open the `Create branch` dialog.

## Viewing Your Branches

The `Branches` pane on the database page lists the branches of the
database. The pane sits below `AI Services` and above `Backups`.

![The Branches pane with no branches](../images/managed_branches_card_empty.png)

The pane header shows how many branches the database has, against the
limit for your plan, for example `2 of 5 branches`. Each row in the pane
shows the following details:

- `Branch` shows the branch's label. A branch with a display name also
  shows its assigned name below the label.
- `Size` shows the size the branch copied from the source database.
- `Alive since` shows how long ago the branch became available.
- `Rate` shows the branch's price per hour.

![The Branches pane with two branches](../images/managed_branches_card.png)

Select a branch's label to open the branch's page. For the limits on each
plan, see
[Understanding Branches](../using_database/managed_branches.md#limits-on-branches).

## Creating a Branch

A new branch starts from the source database's data at the moment you
select `Create branch`. To create a branch:

1. On the source database's page, select `Create branch` in the
   `Branches` pane.

    The `Create branch` dialog opens.

2. Optionally, enter a display name of up to 25 characters in
   `Display name`.

    The display name is shown only in the console. pgEdge assigns the
    branch's name, which is also its hostname, after the branch is created.

3. Check the `Size` section, which shows the size the branch copies from
   the source.

    A branch cannot be resized later, and resizing the source database
    does not change the branch.

4. In the `Network access` section, choose which addresses can reach the
   branch, because this choice cannot be changed later:

    - Select the `Copy` option, which names the source database and its
      rule count, to give the branch the source's current allowlist rules.
    - Select `Set rules just for this branch` to allow only the ranges you
      add. Select `Add my current IP` to add your own address, or
      `Add range` to add another range.

    To change network access afterward, create a new branch and delete
    this one.

5. Read the `What this costs` section, which lists what the branch costs
   per hour.

    The branch is billed by the hour from when it becomes available, until
    you request its deletion.

6. Select `Create branch`.

    The branch's row shows `Creating` until the branch is ready, then the
    branch's status becomes `available`.

![The Create branch dialog](../images/managed_branch_create.png)

## Connecting to a Branch

The branch's page shows the branch's connection details when the branch
is `available`. Select the branch's label in the `Branches` pane to open
the branch's page.

The `Connect` pane on the branch's page shows the following details:

- `Connection string` and `psql command` connect to the branch's own
  hostname, which is its assigned name.
- `Database name` and `User` match the source database.
- `Password` is the branch's own password, which is different from the
  source database's password.

The `ALLOWED IP RANGES` list shows the branch's network access, marked
`FIXED AT CREATION`. The list is read-only.

The `Services` pane shows the AI services the branch copied from the
source database. An MCP client needs the branch's own MCP token, because
the source's MCP token does not work against the branch. Select
`Copy branch token` in the `Services` pane, and give the client that token.

![The branch page](../images/managed_branch_details.png)

For connecting with a client, see
[Connecting to a pgEdge Starfleet Database](../connecting/managed_index.md).

## Deleting a Branch

Deleting a branch removes the branch and its data. Branches have no
backups, so a deleted branch cannot be restored. To delete a branch:

1. In the `Branches` pane, select `Delete` on the branch's row, or select
   `Delete branch` on the branch's page.

    The `Delete branch` dialog opens.

2. Type the branch's label, as the dialog shows it.

3. Select `Delete branch`.

    The branch and its data are lost, and no backup can bring them back.
    Create a new branch from the source database if you need the data
    again.

![The Delete branch dialog](../images/managed_branch_delete.png)

Billing for the branch stops when you select `Delete branch`, and the
branch stops counting toward your limit. The row shows `Deleting` until
the branch is removed.

## Troubleshooting

The following entries describe what you see when the console refuses a
branch action, and what to do.

### Create Branch Is Disabled at the Branch Limit

The `Create branch` button is disabled, and its tooltip reads
`You've used all 5 branches for this database.` The database has reached
the branch limit for your plan.

![The Create branch button disabled at the branch limit](../images/managed_branch_at_limit.png)

Delete a branch you no longer need, and its slot is available again. On a
trial, the tooltip also offers `Add a payment method`, which raises the
limit to that of a paid plan.

### Create Branch Is Disabled While a Payment Is Overdue

The `Branches` pane shows a banner reading
`Branching is blocked while this subscription is past due.` The
subscription has an unpaid invoice. Select `Review billing` in the banner,
and settle the invoice to create branches again.

### Create Branch Is Disabled Because the Source Is Not Available

The tooltip says the source database has to be available first, and
names its current status. A branch copies the source as it stands, so the
source database must be `available`. Create the branch when the source
database's status returns to `available`.

### Create Branch Is Disabled in the Network Access Section

The `Create branch` button in the dialog stays disabled. The source
database has no allowlist rules to copy, or the option
`Set rules just for this branch` has no range. A branch created that way
could never be reached.
Add at least one range, then select `Create branch`.

### Nothing Can Reach the Branch

The branch's page shows `Nothing can reach this branch`. The branch was
created with no allowed ranges, and its network access cannot be changed.
Create a new branch with the ranges you need, then delete this branch.

### The Branch Shows a Failed Status

The branch's status is `failed`. The branch could not be created. Delete
the branch and create a new one.

### The Branch Is Suspended

The branch's page shows `This branch is suspended`. The subscription is
unpaid or has expired, so the branch is hibernated and cannot be reached.
Billing for the branch is paused. Select `Review billing` and settle the
subscription to resume the branch.

### A Branch Cannot Be Deleted While It Is Being Created

The console refuses to delete a branch whose status is `creating`. Wait
until the branch's status is `available`, then delete the branch.

### The Source Database Is Not Deleted

After you select `Delete Database`, the dialog stays open and the source
database is not deleted. The console does not delete a database that still
has branches. Delete
each of the database's branches first, then delete the database. A
database with a branch still being created cannot be deleted either. Wait
until that branch is `available`, and delete the branch first.

### The MCP Client Is Rejected by the Branch

An MCP client that works against the source database is refused by the
branch. The client is using the source's MCP token, which does not work
against the branch. Select `Copy branch token` on the branch's page, and
give the client the branch's own token.

### Upgrade Size Is Disabled on the Source Database

`Upgrade size` is disabled on the source database's `Actions` menu and in
its `Plan & billing` pane. A database cannot be resized while it has
branches, because each branch keeps the size it was created with. Delete
the database's branches first, then resize the database.

![The Actions menu with Upgrade size disabled](../images/managed_branch_resize_blocked.png)

## Next Steps

For how branches behave, see
[Understanding Branches](../using_database/managed_branches.md). For
connecting with psql, pgAdmin or the AI DBA Workbench, see
[Connecting to a pgEdge Starfleet Database](../connecting/managed_index.md).
