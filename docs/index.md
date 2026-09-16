# pgEdge Starfleet

pgEdge Starfleet is pgEdge's distributed Postgres platform, and you can run it
two ways: as a fully managed service, or inside your own cloud account. This
page describes the different features of each platform, and directs you to the
right set of docs for your deployment.

## pgEdge Starfleet Managed Postgres

pgEdge Starfleet Managed Postgres is a fully managed Postgres offering; pgEdge
runs and operates the infrastructure for you on pgEdge-managed cloud resources.
Choose Managed when you want a database running in minutes without operating
any infrastructure yourself.

Every pgEdge Starfleet Managed Postgres database is configured with:

* automatic daily backups.
* an MCP server, so AI agents and MCP-aware tools can query your schema over an
  authenticated endpoint.
* a RAG server, for retrieval-augmented generation of your own content.
* fast branching, for writable copy-on-write branches.
* flat, predictable per-database pricing, with no organization fee and no usage
  metering.

For setup, usage, and reference material, see the
[pgEdge Starfleet Managed Postgres documentation](managed/managed_index.md).

## pgEdge Starfleet BYOC

pgEdge Starfleet BYOC (Bring Your Own Cloud) runs entirely on your own cloud
account. Your infrastructure and data never leave your custody, with pgEdge
Starfleet deploying a database on your cloud resources. Choose BYOC when you
need VPC isolation, custom hardware, or compliance controls that only your own
environment can provide.

Every pgEdge Starfleet BYOC deployment includes:

* deployment with your own cloud provider, with VPC isolation and custom
  hardware.
* multi-region, multi-master distributed Postgres, replicated with Spock.
* the same AI toolkit as Managed, including the MCP server and RAG server.
* compliance controls to support SOC 2 and HIPAA requirements.
* 24/7 enterprise support.

For setup, configuration, and reference material, see the
[pgEdge Starfleet BYOC documentation](byoc/byoc_index.md).

## Choosing a Deployment Model

The following table compares the two deployment models at a glance:

| Aspect | Managed | BYOC |
|--------|---------|------|
| Runs in | pgEdge-managed cloud infrastructure | your own cloud account |
| Best for | getting started quickly | isolation and compliance needs |
| Topology | single-region, single-node | multi-region, multi-master |
| Support | included at every size | 24/7 enterprise support |

You can start on Managed and move to BYOC later without changing platforms or
tooling.
