# Deploying a Managed Database

After authenticating with pgEdge Starfleet, a dialog guides you through
creating your first database:

![Welcome to pgEdge Starfleet](images/managed_cloud_welcome.png)

Select the `Create your first database` button to continue.

![Step one - name your database and choose regions](images/managed_deploy_one.png)

In the first step, you will provide details about the database:

- Provide a name for the database in the `Database name` field.
- Use the `Region` drop-down to select the region in which the database will
  deploy.
- Choose the Postgres version that your hosted database will use.

After completing the dialog, click `Continue`.

![Step two - select features for your database](images/managed_deploy_two.png)

Next, you will select deployment features:

- In the `SIZE` section, select the size of your resource bundle. The
  following table describes the available sizes:

 | Size | vCPU | RAM | Storage | Connections | Price |
 |------|------|-----|---------|-------------|-------|
 | Small | 1 vCPU | 2 GB RAM | 25 GB storage | 20 conns | Free trial, then $25/mo |
 | Large | 2 vCPU | 8 GB RAM | 50 GB storage | 50 conns | $99/mo |
 | XL | 4 vCPU | 16 GB RAM | 150 GB storage | 100 conns | $249/mo |

  For details about functionality provided by each size, see
  [Managing Database Details](using_database/managed_database_details.md).

- The `ADD-ONS` section features a list of optional features for your
  database. The following table describes the available add-ons:

 | Feature | Description | Price |
 |---------|--------------|-------|
 | Point-in-time recovery | Restores your database to any second within the past 7 days. | +$15/mo |
 | Priority support | Provides a 1-hour response time through a dedicated support channel. | +$49/mo |
 | Guaranteed resources | Reserves dedicated CPU and RAM for your database, so performance is not affected by bursting contention from other workloads. | +$40/mo |
 | Extended retention | Retains backups and metrics for 30 days. | +$10/mo |

Select the features that will be accessible to your database, and select
`Create Database`.

![Step three - deploy your database](images/managed_deploy_three.png)

When your database is ready, the console opens to an information page showing
your database features, and connection details. The database name is selected
in the navigation pane (on the left side of the console).

The new database is also shown on a pane on the Databases page:

![The new database pane on the Databases page](images/managed_database_page.png)

## Troubleshooting - When the Wizard Cannot Continue

The wizard displays a message when a step fails:

* `Couldn't check billing status` is displayed with the body text: `We
  couldn't confirm your billing status. Please retry before continuing.`. The
  message includes a `Retry` button. 
  
    The account requires a payment method before you can create a database;
    continuing past an unconfirmed billing status risks a refusal at the end
    of the wizard.

* `Something went wrong` is displayed with the body text: `Unable to start
  checkout. Please try again.`  The message includes a `Back` button.
  
    The payment step could not open a checkout session. If the API sends a
    message of its own, it will replace the body text.

* `Confirmation failed` is displayed with the body text: `We couldn't confirm
  your payment method.` 
  
    The panel also notes that the card may still have been saved, so check
    again in a moment before entering the card a second time.

* `Couldn't create your database` means the create request itself failed.
  The panel displays the reason, as well as `Try again` and `Back` buttons.

## Next Steps

These pages cover related tasks that build on creating your database:

* The
  [Managing Database Details](using_database/managed_database_details.md)
  document describes each size tier, and the statuses a database moves through.
* The [Managing Database Roles](using_database/managed_roles.md) document
  explains the `admin` and `app` roles your database includes.
* The
  [Loading Data into Your pgEdge Starfleet Database](using_database/managed_loading_data.md)
  document explains how to load a schema and data into your new database.
* The [Enabling and Using the MCP Server](serving_ai_content/managed_mcp.md)
  document describes the MCP add-on.
* The [Enabling and Using the RAG Server](serving_ai_content/managed_rag.md)
  document describes the RAG add-on.
