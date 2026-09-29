# pgedge-starfleet-docs

The documentation for pgEdge Starfleet, built with MkDocs and the
Material theme. Prose in `docs/`, navigation in `mkdocs.yml`, no
application code.

Read [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md)
first. Between them they carry the layout, the build commands, the
writing style and the console coupling, and they are the source of
truth for all four. This file carries only what those two do not:
the mistakes that build green here and fail somewhere else.

> **A change here can break another product's deploy.** The pgEdge
> console clones `main` at deploy time and builds it. There is no
> committed baseline and no fallback, so a build this repo cannot
> complete fails the console's deploy rather than shipping stale
> pages. Treat every change as a change to two repos.
>
> The console's repo is private, so its name and file paths stay out
> of this repo. They are in
> `~/PROJECTS/docs/pgedge-starfleet-docs/CONSOLE-COUPLING-PRIVATE.md`.
> Never name a private repo, its files or its hosting in a file,
> commit message or pull request here.

## Commands

```bash
python3 -m venv .venv
.venv/bin/pip install --no-deps -r requirements.txt

.venv/bin/mkdocs build --strict          # what CI runs
.venv/bin/mkdocs serve -a 127.0.0.1:8000 # live preview
.github/scripts/check-console-links.sh   # from the repo root only
```

## What the checks do and do not cover

`Build docs` runs `mkdocs build --strict` against the pins and
rejects committed symlinks. `Console links` checks that every page in
`.github/console-links.txt` still exists and that `mkdocs.yml` keeps
`use_directory_urls: false`.

Neither replicates the console's own content-type gate. An asset with
an extension the console does not serve passes both checks here and
then fails, or 404s, in the product. `.svg` is the live example, and
CONTRIBUTING.md lists the formats that are safe.

## Traps

**A missing logo builds green.** `theme.logo_dark_mode` and
`theme.logo_light_mode` are not Material options. They work only
alongside `theme.custom_dir: overrides` and
`overrides/partials/logo.html`. Remove the `custom_dir` and the logo
disappears with no warning, because mkdocs does not validate theme
keys it does not recognise.

**`requirements.txt` is pinned to another repo.** It has to stay
byte-identical to the console's own pins, and nothing enforces the
match. Adding a tool here that the console
does not install means CI tests a build the console never runs.
Install contributor tooling separately.

**`check-console-links.sh` uses relative paths.** Run it from the
repo root. From anywhere else it cannot find `mkdocs.yml`, and the
failing `grep` makes it report that `mkdocs.yml` must keep
`use_directory_urls: false`, which has nothing to do with the actual
problem.

**The public URL is not set by this repo.** After launch,
`pgedge-docs` imports this repo and derives the directory from the
nav label in its own `mkdocs.yml`, through `slug()` in
`scripts/expand_imports.py`. It never reads `site_url` or `site_name`
from an imported repo. That one string in the other repo decides the
path.

**Moving a page is a two-repo change.** The console holds two
mirrors of this layout. `Console links` guards one of them and fails
the PR; nothing guards the other, so a miss leaves a test failing in
the console for a reason neither repo explains. The private note
names both files.

## Naming the console

Three usages, all deliberate:

- Repo-facing files — README, CONTRIBUTING, workflows, scripts — say
  **the pgEdge console**, never "the pgEdge Starfleet console".
- Prose on the pages says **the console**, bare. It reads that way 50
  times in `docs/`, against one outlier in `connecting/workbench.md`.
- Nav labels and page titles keep **pgEdge Starfleet Console** as the
  name of that section of the product UI.

## Writing

CONTRIBUTING.md has the style rules. One thing it does not say:
banned vocabulary, pgEdge-wide — synergy, leverage, paradigm shift,
best-in-class, utilize, stakeholder alignment, carries.

## Commits

CONTRIBUTING.md has the commit and pull request rules. Two it does
not state:

- Branch off `main`. Never commit to `main` directly.
- Never add `Co-Authored-By` lines, "Generated with" footers, or any
  other self-attribution to a commit, pull request or comment.
