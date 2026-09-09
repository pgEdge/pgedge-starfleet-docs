# pgedge-starfleet-docs

[![Build docs](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/build-docs.yml/badge.svg)](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/build-docs.yml)
[![Console links](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/console-links.yml/badge.svg)](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/console-links.yml)

This repo contains the docs for pgEdge Starfleet.

## Where these docs are published

The pgEdge console builds this repo and serves it in-product at `/docs`.
`scripts/sync-docs.mjs` in `pgEdge/product-ui` clones `main` at deploy
time, installs the pins in `scripts/docs-requirements.txt`, runs `mkdocs
build`, and copies the result into the console's `docs-site/`. There is
no committed baseline and no fallback: if this repo does not build, the
console's Vercel deploy fails rather than shipping stale pages.

Two consequences worth knowing before you merge anything:

- A build that is broken here breaks an unrelated product's deploy.
  `requirements.txt` in this repo is pinned to exactly the versions the
  console installs, and the `Build docs` check runs them, so CI here
  tests the same build the console runs.
- The console links directly into a handful of these pages. See
  "Pages the console links to" below.

After launch this repo also goes public and is served through
`docs.pgedge.com`, alongside `pgEdge/pgedge-docs`.

## Building the Docs

The docs are built with [MkDocs](https://www.mkdocs.org/) and the
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

### Prerequisites

- Python 3.12+

### One-time setup

From the repo root, create a virtual environment and install the pinned
dependencies:

```bash
python3 -m venv .venv
.venv/bin/pip install --no-deps -r requirements.txt
```

`--no-deps` is deliberate. `requirements.txt` pins every transitive, and
letting pip resolve them instead would build the docs against a
dependency set the console never runs.

### Building the site

To build a static copy of the site into the `site/` directory:

```bash
.venv/bin/mkdocs build --strict
```

`--strict` turns mkdocs warnings, such as a `nav:` entry pointing at a
file that does not exist, into errors. CI builds this way; the console
does not, so a warning you ignore locally becomes a silently missing
page in the product.

`site/` is a build artifact (excluded via `.gitignore`) — copy it
anywhere to serve the docs as static files, no server-side dependencies
required.

### Previewing changes locally

To run a local server that live-reloads as you edit files under `docs/`:

```bash
.venv/bin/mkdocs serve -a 127.0.0.1:8000
```

Then open [http://127.0.0.1:8000/](http://127.0.0.1:8000/) in your
browser.

## Project Structure

The `docs/` directory mirrors the site's navigation hierarchy (see `nav:`
in `mkdocs.yml`). Filenames are lowercase; prose wraps at 79 characters.

```
docs/
  index.md                        Overview
  community.md                    Community
  docs_link.md                    Docs
  managed/
    creating_managed.md           Deploying a Managed Database
  using_console/
    console_overview.md           Using the Console: Overview
    metrics.md                    Monitoring System Metrics
    logs.md                       Reviewing the Log Files
    backups.md                    Restoring from Backup
    activity_log.md               Reviewing the Activity Log
    settings.md                   Managing Account Settings
    team_management.md            Managing Team Members
    actions.md                    The Actions Menu
  serving_ai_content/
    mcp.md                        Enabling and Using the MCP Server
    rag.md                        Enabling and Using the RAG Server
  connecting/
    index.md                      Connecting to a Database
    workbench.md                  Connecting with the AI DBA Workbench
    psql.md                       Connecting with psql
    pgadmin.md                    Connecting with pgAdmin
  using_database/
    roles.md                      Managing Database Roles
    rotate_credentials.md         Rotating Database Credentials
    sizes.md                      Selecting or Modifying the Size
    loading_data.md               Loading Data into Your Database
    extensions.md                 Installing Extensions
    orm_guides.md                 ORM and Framework Guides
  img/                            Logos and favicon
  images/                         Screenshots
  stylesheets/extra.css           pgEdge styling
overrides/
  partials/logo.html              Per-scheme logo, needs theme.custom_dir
```

## Pages the console links to

The pgEdge console links to a few of these pages from its "Learn more"
anchors, and its deploy fails if one is missing. The `Console links`
check lists them in `.github/console-links.txt` and fails a pull request
that moves or removes one. To move such a page, update
`managedDocsPaths.json` in `pgEdge/product-ui` in the same change, then
the list.
