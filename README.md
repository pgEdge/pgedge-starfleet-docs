# pgedge-starfleet-docs

This repo contains the docs for pgEdge Starfleet.

## Building the Docs

The docs are built with [MkDocs](https://www.mkdocs.org/) and the
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

### Prerequisites

- Python 3.12+
- [uv](https://docs.astral.sh/uv/) (a fast Python package/venv manager)

Install `uv` if you don't already have it:

```bash
brew install uv
```

### One-time setup

From the repo root, create a virtual environment and install dependencies:

```bash
uv venv .venv --python 3.12
uv pip install --python .venv/bin/python \
  mkdocs \
  mkdocs-material
```

### Building the site

To build a static copy of the site into the `site/` directory:

```bash
.venv/bin/mkdocs build
```

`site/` is a build artifact (excluded via `.gitignore`) — copy it anywhere to
serve the docs as static files, no server-side dependencies required.

### Previewing changes locally

To run a local server that live-reloads as you edit files under `docs/`:

```bash
.venv/bin/mkdocs serve -a 127.0.0.1:8000
```

Then open [http://127.0.0.1:8000/](http://127.0.0.1:8000/) in your browser.

## Project Structure

The `docs/` directory mirrors the site's navigation hierarchy (see `nav:` in
`mkdocs.yml`):

```
docs/
  index.md                     Overview
  connecting.md                Connecting to a Database
  managed/
    creating_managed.md        Deploying a Managed Database
    using/
      index.md                 Using the Database Console
      services/
        index.md               Services
        mcp.md                 MCP Server
        rag.md                 RAG Server
      metrics.md                Metrics
      logs.md                   Logs
      backups.md                Backups
```
