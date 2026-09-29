# pgedge-starfleet-docs

[![Build docs](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/build-docs.yml/badge.svg)](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/build-docs.yml)
[![Console links](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/console-links.yml/badge.svg)](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/console-links.yml)
[![Lint](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/lint.yml/badge.svg)](https://github.com/pgEdge/pgedge-starfleet-docs/actions/workflows/lint.yml)

This repo contains the docs for pgEdge Starfleet.

## Publishing this Documentation

The pgEdge console builds this repo and serves it in-product at `/docs`.
It clones `main` at deploy time, installs its pinned dependencies, and
runs `mkdocs build`. There is no committed baseline and no fallback: if
this repo does not build, the console's deploy fails rather than shipping
stale pages.

Two consequences worth knowing before you merge anything:

- A build that is broken here breaks an unrelated product's deploy.
  `requirements.txt` is pinned to exactly the versions the console
  installs, and the `Build docs` check runs them, so a mkdocs failure
  surfaces on the docs PR rather than on the console's deploy.
- `Build docs` does not cover everything the console checks. Two of its
  gates are not replicated here, so these still fail at deploy time:

  - **Asset extensions.** The console serves `/docs` with a fixed map
    of content types. An extension missing from it either fails the
    deploy outright, `.pdf` for instance, or ships an
    asset that 404s in-product, which is currently the case for `.svg`.
    Only add image formats already in that map: `.png`, `.jpg`,
    `.jpeg`, `.gif`, `.webp`, `.avif`, `.ico`.
  - **Nav entries the console mirrors.** See "Pages the console links
    to" below.

  Symlinks are the exception: the console refuses them, and `Build
  docs` now rejects them here too.
- The console links directly into a handful of these pages. See
  "Pages the console links to" below.

After launch this repo also goes public and is served through
`docs.pgedge.com`, alongside `pgEdge/pgedge-docs`.

## Building the Documentation

The docs are built with [MkDocs](https://www.mkdocs.org/) and the
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

### Prerequisites

- Python 3.12+

### One-time Setup

From the repo root, create a virtual environment and install the pinned
dependencies:

```bash
python3 -m venv .venv
.venv/bin/pip install --no-deps -r requirements.txt
```

`--no-deps` is deliberate. `requirements.txt` pins every transitive, and
letting pip resolve them instead would build the docs against a
dependency set the console never runs.

Then install the commit hooks. `pre-commit` is deliberately not in
`requirements.txt`, which has to stay identical to the console's own
pins, so install it separately:

```bash
python3 -m pip install pre-commit
pre-commit install
```

The hooks run markdownlint, yamllint and gitleaks over the files you
touch. The `Lint` check runs the same hooks over the whole tree on
every pull request, so skipping this step moves the failure rather
than avoiding it.

### Building the Site

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

### Previewing Changes Locally

To run a local server that live-reloads as you edit files under `docs/`:

```bash
.venv/bin/mkdocs serve -a 127.0.0.1:8000
```

Then open [http://127.0.0.1:8000/](http://127.0.0.1:8000/) in your
browser.

## Project Structure

The `docs/` directory mirrors the site's navigation hierarchy (see `nav:`
in `mkdocs.yml`). Filenames are lowercase; prose wraps at 79 characters.

```text
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

## Linking to the Console

The pgEdge console links to a few of these pages from its "Learn more"
anchors, and its deploy fails if one is missing. The `Console links`
check lists them in `.github/console-links.txt` and fails a pull request
that moves or removes one.

The console keeps two copies of this repo's layout. One lists the pages
it links into, which `Console links` guards, so a miss fails a pull
request here. The other lists every page, and nothing here guards it, so
a miss fails the console's own tests instead.

Moving or renaming a page therefore needs a matching change in the
console, which pgEdge maintainers make. Update the console first, then
`.github/console-links.txt`.
