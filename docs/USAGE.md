# CI workflow usage

This repository provides reusable GitHub Actions workflows and composite
actions, plus GitLab CI templates. This guide is the consumer-facing index:
each table identifies the source contract path. Required inputs and secrets are marked
`required`; other inputs are optional and show their metadata default when one
is declared. `none` means the workflow declares no caller-provided secrets.

## Choose and pin a version

For GitHub Actions, reference an entry point in a consumer workflow with
`SanctumLabs/ci-workflows/<path>@<ref>`. Use a published release tag or a full
commit SHA for reproducible builds; avoid `@main` in production because it
tracks changes on every run. The examples below use `v1.4.1`; replace it with a
release or SHA approved by your project. For GitLab, use the matching Git ref
in the `include` declaration. See [dependency versions](../DEPENDENCY_VERSIONS.md)
for runtime defaults, third-party action pins, and update policy.

## GitHub reusable workflows

Call reusable workflows as jobs with `uses` and pass declared inputs under
`with`. Credentials belong under `secrets`, never in `with`. Use the narrowest
`GITHUB_TOKEN` permissions your consumer needs. The permissions column records
permissions explicitly declared by the called workflow; `not declared` means
the caller/repository default remains in effect, not that no token is used.
The called workflow cannot elevate permissions beyond those granted by its
caller.

| Workflow | Inputs (type, requirement, and declared default) | Secrets (requirement) | Declared token permissions |
| --- | --- | --- | --- |
| `.github/workflows/buf_build.yaml` | `artifact-name` (string; optional; default: "lib") | none | not declared (caller defaults apply) |
| `.github/workflows/dangerci.yml` | `node-version` (string; optional; default: "24.x") | `token` (required) | not declared (caller defaults apply) |
| `.github/workflows/docker_gcr.yml` | `tag` (string; optional; default: "latest") | `token` (required) | not declared (caller defaults apply) |
| `.github/workflows/docker_hub.yml` | `tag` (string; optional; default: "latest") | `username` (required)<br>`password` (required)<br>`registry` (required)<br>`repository` (required) | not declared (caller defaults apply) |
| `.github/workflows/go-lint-staticcheck.yml` | `platform` (string; optional; default: "ubuntu-latest")<br>`go-version` (string; optional; default: "1.26")<br>`cache` (boolean; optional; default: true)<br>`cache-key` (string; optional; default: "")<br>`version` (string; optional; default: "latest") | none | not declared (caller defaults apply) |
| `.github/workflows/go-lint.yml` | `platform` (string; optional; default: "ubuntu-latest")<br>`go-version` (string; optional; default: "1.26")<br>`cache` (boolean; optional; default: true)<br>`working-directory` (string; optional; default: ".") | none | not declared (caller defaults apply) |
| `.github/workflows/go-test.yml` | `platform` (string; optional; default: "ubuntu-latest")<br>`go-version` (string; optional; default: "1.26")<br>`cache` (boolean; optional; default: true)<br>`command` (string; required)<br>`upload-coverage` (boolean; optional; default: false)<br>`database-image-name` (string; optional; default: "")<br>`database-image-version` (string; optional; default: "latest")<br>`database-name` (string; optional; default: "db")<br>`database-username` (string; optional; default: "dbuser")<br>`database-password` (string; optional; default: "dbpassword")<br>`database-port` (number; optional; default: 5432)<br>`database-port-internal` (number; optional; default: 5432)<br>`cache-image` (string; optional; default: "")<br>`cache-version` (string; optional; default: "latest")<br>`cache-port` (number; optional; default: 6379)<br>`cache-port-internal` (number; optional; default: 6379) | `codacy_token` (optional)<br>`codecov_token` (optional) | not declared (caller defaults apply) |
| `.github/workflows/go.yml` | `platform` (string; optional; default: "ubuntu-latest")<br>`go-version` (string; optional; default: "1.26")<br>`cache` (boolean; optional; default: true)<br>`command` (string; required) | none | not declared (caller defaults apply) |
| `.github/workflows/java-ci.yml` | `java-version` (string; optional; default: "21")<br>`build-tool` (string; optional; default: "gradle")<br>`task` (string; optional; default: "test")<br>`command` (string; optional; default: "")<br>`cache` (boolean; optional; default: true) | none | workflow contents: read |
| `.github/workflows/js-bun-setup.yml` | `working-directory` (string; optional; default: "/")<br>`command` (string; required)<br>`bun-version` (string; optional; default: "1.4.2")<br>`build-dir` (string; optional; default: "build") | none | not declared (caller defaults apply) |
| `.github/workflows/kotlin-ci.yml` | `java-version` (string; optional; default: "21")<br>`task` (string; optional; default: "test")<br>`command` (string; optional; default: "")<br>`cache` (boolean; optional; default: true) | none | workflow contents: read |
| `.github/workflows/publish_npm.yml` | `directory` (string; optional)<br>`version` (string; required)<br>`scope` (string; required)<br>`registry` (string; required)<br>`nodeVersion` (string; optional; default: "24.x") | `npmAuthToken` (required) | publish-npm: write-all |
| `.github/workflows/python-build.yml` | `packager` (string; optional; default: "poetry")<br>`command` (string; required)<br>`python-version` (string; optional; default: "3.12")<br>`install-command` (string; optional; default: "uv pip install -r pyproject.toml --all-extras")<br>`virtual-env-dir` (string; optional; default: ".venv") | none | not declared (caller defaults apply) |
| `.github/workflows/python-lint-ruff.yml` | `packager` (string; optional; default: "poetry")<br>`python-version` (string; optional; default: "3.14")<br>`ruff-version` (string; optional; default: "0.17.5")<br>`directory` (string; optional; default: ".")<br>`ruff-args` (string; optional; default: "check")<br>`changed-files` (string; optional; default: "false")<br>`install-command` (string; optional; default: "uv pip install -r pyproject.toml --all-extras")<br>`virtual-env-dir` (string; optional; default: ".venv") | none | not declared (caller defaults apply) |
| `.github/workflows/python-lint.yml` | `packager` (string; optional; default: "poetry")<br>`command` (string; required)<br>`python-version` (string; optional; default: "3.12") | none | not declared (caller defaults apply) |
| `.github/workflows/python-pypi-publish.yml` | `packager` (string; optional; default: "poetry")<br>`command` (string; required)<br>`python-version` (string; optional; default: "3.12")<br>`version` (string; required)<br>`install-command` (string; optional; default: "uv pip install -r pyproject.toml --all-extras")<br>`virtual-env-dir` (string; optional; default: ".venv") | `pypi_token` (required) | not declared (caller defaults apply) |
| `.github/workflows/python-test-with-postgres.yml` | `packager` (string; optional; default: "poetry")<br>`command` (string; required)<br>`python-version` (string; optional; default: "3.12")<br>`upload-coverage` (boolean; optional; default: false)<br>`postgres-database-version` (string; optional; default: "16-alpine")<br>`database-name` (string; optional; default: "db")<br>`database-username` (string; optional; default: "dbuser")<br>`database-password` (string; optional; default: "dbpassword")<br>`database-port` (number; optional; default: 5432) | `codacy_token` (optional) | not declared (caller defaults apply) |
| `.github/workflows/python-test.yml` | `packager` (string; optional; default: "poetry")<br>`command` (string; required)<br>`python-version` (string; optional; default: "3.12")<br>`upload-coverage` (boolean; optional; default: false) | `codacy_token` (optional)<br>`codecov_token` (optional) | not declared (caller defaults apply) |
| `.github/workflows/release-semantic.yml` | none | `token` (required) | release contents: write<br>release issues: write<br>release pull-requests: write |
| `.github/workflows/release.yml` | `name` (string; optional)<br>`tag_name` (string; required) | none | not declared (caller defaults apply) |
| `.github/workflows/repo_sync.yml` | none | `url` (required)<br>`username` (required)<br>`token` (required) | not declared (caller defaults apply) |
| `.github/workflows/rust-build.yml` | `rust-version` (string; optional; default: "stable")<br>`profile` (string; optional; default: "release")<br>`platform` (string; optional; default: "ubuntu-latest")<br>`cache` (boolean; optional; default: true)<br>`working-directory` (string; optional; default: ".") | none | not declared (caller defaults apply) |
| `.github/workflows/rust-lint.yml` | `rust-version` (string; optional; default: "stable")<br>`profile` (string; optional; default: "release")<br>`platform` (string; optional; default: "ubuntu-latest")<br>`cache` (boolean; optional; default: true)<br>`working-directory` (string; optional; default: ".") | none | not declared (caller defaults apply) |
| `.github/workflows/rust-test.yml` | `rust-version` (string; optional; default: "stable")<br>`profile` (string; optional; default: "release")<br>`platform` (string; optional; default: "ubuntu-latest")<br>`cache` (boolean; optional; default: true)<br>`working-directory` (string; optional; default: ".") | none | not declared (caller defaults apply) |
| `.github/workflows/slack_notification.yml` | `slack_username` (string; optional; default: "Ratholos")<br>`slack_channel` (string; optional; default: "pipelines")<br>`slack_icon` (string; optional; default: "https://github.com/ratholos.png?size=48")<br>`slack_color` (string; optional; default: "good")<br>`slack_icon_emoji` (string; optional; default: ":large_green_circle:")<br>`slack_message` (string; optional; default: "Success")<br>`slack_title` (string; optional; default: "${{ github.repository }} - ${{ github.event.workflow_run.name }} Workflow Run") | `slack_webhook` (required) | not declared (caller defaults apply) |

`release-semantic.yml` requires a caller `GITHUB_TOKEN` permission set that
includes `contents: write`, `issues: write`, and `pull-requests: write`.
`publish_npm.yml` declares `write-all` on its `publish-npm` job; review that
broad permission requirement before use. For all workflows with no declaration,
choose caller permissions based on the called workflow's jobs and repository
policy; use `contents: read` for workflows that only check out source.

### Copyable workflow examples

Each linked consumer fixture is a complete workflow file and is included in
the repository's `actionlint` validation:

- [Go test](../tests/fixtures/ci-validation/docs-go-workflow-consumer.yml)
- [Python test and optional Codecov upload](../tests/fixtures/ci-validation/docs-python-workflow-consumer.yml)
- [Java with Gradle](../tests/fixtures/ci-validation/docs-java-workflow-consumer.yml)
- [Kotlin](../tests/fixtures/ci-validation/docs-kotlin-workflow-consumer.yml)
- [Rust test](../tests/fixtures/ci-validation/docs-rust-workflow-consumer.yml)
- [Bun build](../tests/fixtures/ci-validation/docs-bun-workflow-consumer.yml)

For coverage uploads, store the provider token in the consuming repository's
Actions secrets and map it under `secrets`. The Codecov token is optional in
the reusable workflow contract; the example enables upload and passes it.
See [Codecov authentication guidance](../DEPENDENCY_VERSIONS.md#codecov-authentication)
for the behavior of coverage upload steps.

## GitHub composite actions

Use composite actions as steps. Their inputs are declared in `action.yml`;
unlike reusable-workflow secrets, credentials passed to a composite action are
ordinary action inputs, so pass secret values via `${{ secrets.NAME }}` and do
not print them. The consuming job controls `GITHUB_TOKEN` permissions; actions
do not declare workflow permissions themselves.

| Action | Inputs (requirement and declared default) |
| --- | --- |
| `.github/actions/go/action.yml` | `command` (required)<br>`go-version` (optional; default: "1.26")<br>`cache` (optional; default: "true")<br>`upload-coverage` (optional; default: "false")<br>`codacy_token` (optional)<br>`codecov_token` (optional) |
| `.github/actions/migrate-db/action.yml` | `database_url` (required; default: "postgres://root:password@localhost:5432/test?sslmode=disable")<br>`migration_files_source` (optional; default: "file://db/migrations")<br>`golang-migrate-version` (optional; default: 4.20.1) |
| `.github/actions/python-test/action.yml` | `packager` (optional; default: poetry)<br>`command` (required)<br>`python-version` (optional; default: "3.12")<br>`upload-coverage` (optional; default: "false")<br>`codacy_token` (optional)<br>`codecov_token` (optional) |
| `.github/actions/setup-python-poetry/action.yml` | `python-version` (optional; default: "3.12")<br>`poetry-version` (optional; default: latest) |
| `.github/actions/setup-python-uv/action.yml` | `python-version` (optional; default: "3.12")<br>`uv-version` (optional; default: latest)<br>`enable-cache` (optional; default: true)<br>`cache-dependency-glob` (optional; default: "uv.lock")<br>`virtual-env-directory` (optional; default: ".venv")<br>`install-command` (optional; default: "uv pip install -r pyproject.toml --all-extras") |
| `.github/actions/validate-python-packager/action.yml` | `packager` (required) |

The Python setup actions support `poetry` and `uv`. The `migrate-db` action
exposes a `migration_report` output. The Go and Python test actions upload
coverage only when enabled; provide the matching optional coverage tokens when
that integration is used.

## GitLab CI templates

Include a template from the GitLab project/ref that hosts this repository, then
extend its hidden job or add its visible job to your pipeline. The former README
referenced the project `sanctumlabs/tools/gitlab-ci`; if your GitLab mirror is
published elsewhere, replace that project path. Template file paths below
reflect this repository's current `.gitlab/templates/` directory.

Copy the [validated Docker Hub consumer example](../tests/fixtures/ci-validation/docs-gitlab-consumer.yml)
and replace the example project path, ref, and image values with your GitLab
mirror and release.

Set registry credentials as masked/protected GitLab CI variables, not literal
values in `.gitlab-ci.yml`. The Docker template uses Docker-in-Docker; the
selected runner must allow the required service configuration.

| Template | Entry point | Required consumer configuration | Optional configuration |
| --- | --- | --- | --- |
| `.gitlab/templates/dependabot.yml` | `.dependabot` (hidden job; extend it) | `PACKAGE_MANAGER` (for example `npm`, `pip`, or `gradle`); schedule variable `SCHEDULE_NAME` must equal `DEPENDABOT_SCHEDULE_NAME` | `DEPENDABOT_SCHEDULE_NAME` defaults to `dependabot`; set `SCHEDULE_NAME=dependabot` in the matching GitLab pipeline schedule (or set both to the same custom name). The template also requires `CI_PIPELINE_SOURCE=schedule` |
| `.gitlab/templates/docker-hub-build.yml` | `.docker-hub-build` (hidden job; extend it) | `DOCKERHUB_REPO`, `DOCKERHUB_USERNAME`, `DOCKERHUB_PASSWORD`, `DOCKER_IMAGE_NAME`; Docker-in-Docker-capable runner | `CACHE_TAG`, `DOCKER_CACHE_TARGET`, `DOCKER_CONTEXT`, `DOCKER_EXTRA_BUILD_ARGS`, `DOCKERFILE`, `DOCKER_IMAGE_TAG` |
| `.gitlab/templates/hadolint.yml` | `hadolint` (visible job) | A `test` stage in the consumer pipeline | `DOCKERFILES` defaults to `./Dockerfile`; `IGNORED_RULES` is declared, but the current script always passes `--ignore DL3008`, so changing that variable does not change the ignored rules |
| `.gitlab/templates/publish-pypi.yml` | `.publish-pypi` (hidden job; extend it) | Built distributions under `./dist/*`; GitLab job token access to the package registry | `DIRECTORY`, `REPOSITORY_URL`, and `TWINE_PASSWORD` are initialized for GitLab's package registry and can be overridden. `TWINE_USERNAME` is not an effective override: the script passes `-u '__token__'`; changing the upload username requires overriding the job's `script` |
| `.gitlab/templates/release.yml` | `create-tag` (visible manual job) | `GITLAB_ACCESS_TOKEN` CI variable with permission to create tags; job is restricted to `main`; add `publish` to the consumer's top-level `stages` because GitLab's defaults do not include it | Instead of adding `publish`, override `create-tag`'s `stage` to an existing stage. Add the documented optional `needs` dependency when release should wait for a manual deploy job |
| `.gitlab/templates/slack-notification.yml` | `slack-success` and `slack-failure` (visible jobs) | `SLACK_WEBHOOK_URL`, `SANCTUM_LABS_PIPELINES_CHANNEL` | `SLACK_DEPLOY_CHANNEL`; configure `needs` for manual deploys or notifications can run before deployment finishes |
| `.gitlab/templates/sonarcloud.yml` | `.sonarcloud` (hidden job; extend it) | `SONAR_TOKEN`, SonarCloud project configuration, and coverage artifact passed to the job if coverage is used | `.sonar` cache location/key and scanner properties in `sonar-project.properties` |

GitLab template variables are not typed metadata in the same way as GitHub
workflow inputs. Treat the required/optional lists above and each template's
comments as the consumer contract. Review the referenced file before depending
on variables not listed here.

## Supported configurations and internal files

- **Go:** reusable build, test, lint, and Staticcheck workflows; Go composite
  action. Go defaults to `1.26`. Database/cache services in `go-test.yml` are
  optional and configurable; their image versions default to floating
  `latest`, so set explicit versions when reproducibility matters.
- **Python:** build, lint, Ruff lint, test, PostgreSQL test, and PyPI publish
  workflows; Poetry/uv setup and test actions. `packager` accepts `poetry` or
  `uv`; defaults are documented in the tables. Ruff uses Python `3.14`; other
  Python workflows default to `3.12`.
- **Java:** `java-ci.yml` supports Java 17, 21, or 25 and Gradle or Maven; both
  require the repository wrapper.
- **Kotlin:** `kotlin-ci.yml` supports the documented Java versions 17, 21,
  and 25 and runs the Gradle wrapper.
- **Rust:** build, lint, and test workflows use the `stable` toolchain by
  default.
- **JavaScript/Bun:** `js-bun-setup.yml` provides the Bun build workflow;
  `publish_npm.yml` publishes a package to a configured npm registry.
- **Other workflows:** Buf, Docker Hub/GCR, Danger, release, repository sync,
  and Slack notification workflows are listed in the reusable-workflow table.

Only files with an `on.workflow_call` declaration are reusable workflows. The
following files are repository automation or internal wiring, not consumer
workflow entry points:

- `.github/workflows/validate-ci-templates.yml`
- `.github/workflows/validate-go-workflows.yml`
- `.github/workflows/validate-python-packager.yml`
- `.github/workflows/release-action.yaml` (calls the internal
  `release-semantic.yml` workflow)

No consumer entry point is marked deprecated by this guide because the
repository does not declare any as deprecated. Reusable entry points are those
with `workflow_call`; composite actions are identified by their action
metadata; GitLab templates are the files under `.gitlab/templates/`.

## Validate and contribute

Run the same credential-free checks used by CI before proposing a change:

```sh
ruby scripts/validate-ci-templates.rb
ruby tests/ci_validation_test.rb
```

The repository workflow also runs `actionlint` against workflow consumer
fixtures. Add or update a fixture under `tests/fixtures/ci-validation/` when
changing a documented GitHub example. The usage-guide contract test checks that
the catalog contains every reusable workflow/action and its declared inputs,
secrets, and permission requirements. For new entry points, add metadata,
include a validated consumer fixture, and update the catalog, supported
configuration summary, and any relevant GitLab example.

Follow the [reusable CI conventions](../CONTRIBUTING.md#reusable-ci-conventions)
for inputs, secrets, least privilege, versions, and GitLab variables.
