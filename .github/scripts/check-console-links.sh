#!/usr/bin/env bash
# Fails if a page the pgEdge console links to is missing from docs/, or if
# mkdocs would stop building flat .html files. Run from the repo root.
set -u

list=.github/console-links.txt
failed=0

if ! grep -qE '^use_directory_urls:[[:space:]]*false[[:space:]]*$' mkdocs.yml; then
    echo "::error::mkdocs.yml must keep 'use_directory_urls: false'." \
        "The console links to flat .html paths."
    failed=1
fi

while IFS= read -r page; do
    case "$page" in ''|'#'*) continue ;; esac
    if [ ! -f "docs/$page" ]; then
        echo "::error::docs/$page is missing, but the pgEdge console links" \
            "to it. Keep the page at this path, or update" \
            "managedDocsPaths.json in pgEdge/product-ui and $list together."
        failed=1
    fi
done < "$list"

if [ "$failed" -eq 0 ]; then
    echo "All console-linked pages are present."
fi
exit "$failed"
