#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
validator="$repo_root/.github/actions/validate-python-packager/validate.sh"

for packager in poetry uv; do
  PACKAGER="$packager" bash "$validator"
done

for packager in pip pipenv ""; do
  if output="$(PACKAGER="$packager" bash "$validator" 2>&1)"; then
    echo "Expected packager '$packager' to be rejected." >&2
    exit 1
  fi

  expected="Unsupported Python packager '$packager'. Supported packagers: poetry, uv."
  if [[ "$output" != *"$expected"* ]]; then
    echo "Expected rejection message '$expected', got '$output'." >&2
    exit 1
  fi
done

surfaces=(
  ".github/workflows/python-build.yml"
  ".github/workflows/python-lint.yml"
  ".github/workflows/python-lint-ruff.yml"
  ".github/workflows/python-test.yml"
  ".github/workflows/python-test-with-postgres.yml"
  ".github/workflows/python-pypi-publish.yml"
  ".github/actions/python-test/action.yml"
)

for surface in "${surfaces[@]}"; do
  if ! grep -Fq "Supported package managers: poetry, uv." "$repo_root/$surface"; then
    echo "Missing supported-packager documentation in $surface." >&2
    exit 1
  fi
  if ! grep -Fq "uses: sanctumlabs/ci-workflows/.github/actions/validate-python-packager@main" "$repo_root/$surface"; then
    echo "Missing packager validation in $surface." >&2
    exit 1
  fi
done

echo "Python packager contract tests passed."
