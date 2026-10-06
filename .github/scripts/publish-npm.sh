#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${PACKAGE_DIRECTORY:-}" ]]; then
  if [[ ! -d "$PACKAGE_DIRECTORY" ]]; then
    printf 'Package directory does not exist: %s\n' "$PACKAGE_DIRECTORY" >&2
    exit 1
  fi
  cd -- "$PACKAGE_DIRECTORY"
fi

npm ci
npm version "$PACKAGE_VERSION"
npm publish
