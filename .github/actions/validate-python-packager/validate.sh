#!/usr/bin/env bash
set -euo pipefail

case "${PACKAGER:-}" in
  poetry|uv)
    ;;
  *)
    echo "::error::Unsupported Python packager '${PACKAGER:-}'. Supported packagers: poetry, uv." >&2
    exit 1
    ;;
esac
