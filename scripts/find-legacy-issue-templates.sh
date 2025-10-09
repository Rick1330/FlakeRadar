#!/usr/bin/env bash
set -euo pipefail
dir=".github/ISSUE_TEMPLATE"
if [ ! -d "$dir" ]; then
  echo "No issue templates directory found."
  exit 0
fi
echo "Scanning for legacy issue templates using 'about:'..."
found=0
while IFS= read -r -d '' f; do
  # Skip config.yml as it's a special case
  if [[ "$(basename "$f")" == "config.yml" ]]; then
    continue
  fi
  if grep -qE '^[[:space:]-]*about:' "$f"; then
    echo "Legacy template: $f (contains 'about:')"
    found=1
  fi
done < <(find "$dir" -maxdepth 1 -type f -name "*.yml" -print0)
if [ $found -eq 1 ]; then
  echo "Found legacy YAML templates. Replace 'about:' with Issue Forms ('description:') or remove files."
  exit 1
else
  echo "OK: No legacy 'about:' found."
fi