#!/bin/bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
SCRIPT_PATH="${ROOT_DIR}/scripts/docker-build.sh"
DOCKER_STUB="${ROOT_DIR}/tests/fixtures/docker"
TEST_TMPDIR=$(mktemp -d)
DOCKER_STUB_LOG="${TEST_TMPDIR}/docker.log"

cleanup() {
  rm -rf "${TEST_TMPDIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_logged() {
  local expected=$1
  grep -Fqx -- "${expected}" "${DOCKER_STUB_LOG}" || fail "docker call not found: ${expected}"
}

run_without_required_variable() {
  local missing_variable=$1
  local variable
  local -a environment=("PATH=$(dirname "${DOCKER_STUB}"):/usr/bin:/bin" "DOCKER_STUB_LOG=${DOCKER_STUB_LOG}")

  for variable in DOCKERHUB_USERNAME DOCKERHUB_PASSWORD DOCKERHUB_REPO DOCKER_IMAGE_NAME; do
    [[ "${variable}" == "${missing_variable}" ]] && continue
    case "${variable}" in
      DOCKERHUB_USERNAME) environment+=("${variable}=hub-user") ;;
      DOCKERHUB_PASSWORD) environment+=("${variable}=hub-password") ;;
      DOCKERHUB_REPO) environment+=("${variable}=hub/team") ;;
      DOCKER_IMAGE_NAME) environment+=("${variable}=app") ;;
    esac
  done

  env -i "${environment[@]}" /bin/bash "${SCRIPT_PATH}"
}

for required_variable in DOCKERHUB_USERNAME DOCKERHUB_PASSWORD DOCKERHUB_REPO DOCKER_IMAGE_NAME; do
  : > "${DOCKER_STUB_LOG}"
  if run_without_required_variable "${required_variable}" >/dev/null 2>&1; then
    fail "script succeeded without required variable ${required_variable}"
  fi
  [[ ! -s "${DOCKER_STUB_LOG}" ]] || fail "docker ran without required variable ${required_variable}"
done

: > "${DOCKER_STUB_LOG}"
env -i \
  "PATH=$(dirname "${DOCKER_STUB}"):/usr/bin:/bin" \
  "DOCKER_STUB_LOG=${DOCKER_STUB_LOG}" \
  DOCKERHUB_USERNAME=hub-user \
  DOCKERHUB_PASSWORD=hub-password \
  DOCKERHUB_REPO=hub/team \
  DOCKER_IMAGE_NAME=app \
  CACHE_TAG=main \
  DOCKER_CACHE_TARGET="compile package" \
  DOCKER_CONTEXT=build-context \
  DOCKERFILE=containers/app.Dockerfile \
  DOCKER_EXTRA_BUILD_ARGS="--build-arg MODE=ci" \
  DOCKER_IMAGE_TAG="sha-abc release/v1" \
  /bin/bash "${SCRIPT_PATH}" >/dev/null

assert_logged "login <--username> <hub-user> <--password-stdin>"
assert_logged "pull <hub/team/app:compile>"
assert_logged "pull <hub/team/app:package>"
assert_logged "build <--target> <compile> <--cache-from> <hub/team/app:main> <--cache-from> <hub/team/app:compile> <--build-arg> <MODE=ci> <-t> <hub/team/app:compile> <-f> <containers/app.Dockerfile> <build-context>"
assert_logged "push <hub/team/app:compile>"
assert_logged "build <--target> <package> <--cache-from> <hub/team/app:main> <--cache-from> <hub/team/app:compile> <--cache-from> <hub/team/app:package> <--build-arg> <MODE=ci> <-t> <hub/team/app:package> <-f> <containers/app.Dockerfile> <build-context>"
assert_logged "push <hub/team/app:package>"
assert_logged "build <--cache-from> <hub/team/app:main> <--cache-from> <hub/team/app:compile> <--cache-from> <hub/team/app:package> <--build-arg> <MODE=ci> <-t> <gitlabimagebuild> <-f> <containers/app.Dockerfile> <build-context>"
assert_logged "tag <gitlabimagebuild> <hub/team/app:main>"
assert_logged "push <hub/team/app:main>"
assert_logged "tag <gitlabimagebuild> <hub/team/app:sha-abc>"
assert_logged "push <hub/team/app:sha-abc>"
assert_logged "tag <gitlabimagebuild> <hub/team/app:release-v1>"
assert_logged "push <hub/team/app:release-v1>"

echo "PASS: Docker Hub build configuration and behavior"
