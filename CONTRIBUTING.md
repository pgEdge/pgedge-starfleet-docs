# Contributing to the pgEdge Starfleet Docs

This repository holds the documentation for pgEdge Starfleet. The
pgEdge console builds it at deploy time and serves it in-product at
`/docs`, so a change here can fail another product's deploy. Read
"Publishing this Documentation" in the [README](README.md) before your
first change.

## Getting Started

1. Branch off `main` — `docs/short-description`, or
   `fix/short-description` for a correction
2. Create the virtualenv and install the pinned dependencies, per the
   README
3. Preview your change with `.venv/bin/mkdocs serve`
4. Confirm `.venv/bin/mkdocs build --strict` passes
5. Open a pull request

Both checks, `Build docs` and `Console links`, run on every pull
request and have to pass before merge.

## Writing Style

- Wrap prose at 79 characters. Table rows, fenced code blocks and bare
  URLs are exempt; do not break one to fit the limit.
- Filenames under `docs/` are lowercase, with underscores rather than
  hyphens, matching the tree already there.
- A new page has to be added to `nav:` in `mkdocs.yml`, in the position
  it should appear. The nav is ordered deliberately rather than
  alphabetically, and mkdocs will not infer it.
- Nav labels are title case; prose is sentence case.

## Images

Screenshots go in `docs/images/` and are referenced with a relative
path.

Use `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.avif` or `.ico`. **Do
not add an `.svg`.** The console serves this site through a route whose
content-type map excludes SVG deliberately, so one builds green here
and then 404s in the product.

Symlinks are rejected by CI and by the console's deploy.

## Moving or Renaming a Page

The console deep-links into six of these pages and mirrors the full
nav, so moving a page means changing `pgEdge/product-ui` too, in the
same change. "Linking to the Console" in the README lists the files.

## Commits and Pull Requests

- One logical change per pull request
- Conventional commit style — `docs:`, `fix:`, `chore:`, `feat:` —
  with the header at 50 characters or fewer
- Say what changed and why in the body, and keep it shorter than the
  diff it describes

## Reporting Issues

- [Page is wrong or missing](.github/ISSUE_TEMPLATE/bug_report.md)
- [Documentation request](.github/ISSUE_TEMPLATE/feature_request.md)

## License

By contributing you agree that your contributions are licensed under
the [PostgreSQL License](LICENSE.md).
