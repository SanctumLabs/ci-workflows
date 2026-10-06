# CI dependency versions

This inventory covers third-party GitHub Actions, versions of tools installed or
run by this repository's templates, and container images referenced by GitHub
and GitLab CI. It was checked against upstream release notes and registries on
2026-10-06. Update this file whenever one of these references changes.

## Update policy

- Prefer the latest stable compatible major of third-party Actions, referenced
  by its major tag (for example, `actions/checkout@v7`). Review upstream release
  notes before crossing a major; do not assume that a major upgrade preserves
  inputs or behavior. Use a full commit SHA instead when immutable action code
  is required, and include the corresponding release version in a comment.
- Keep tool versions configurable through workflow/action inputs. Default to a
  supported, broadly compatible release line; reserve floating values such as
  `latest`, `stable`, or `lts/*` for defaults where automatic updates are
  intentional, and call that out below.
- Use explicitly versioned container tags and pair related images (for example,
  Docker CLI and DinD). Prefer a supported version line and distribution variant
  over `latest` or an unqualified image. Pin an image digest when exact
  reproducibility is required.
- Check the upstream lifecycle and compatibility, not only the newest tag.
  Update all occurrences of a dependency together, validate the affected
  reusable workflows, and review this inventory at least quarterly or when an
  upstream deprecation is announced.
- Reusable workflows can accept caller-provided runners and versions. Callers
  should verify that their runner supports the selected Action runtime and that
  their project supports the configured language/tool default.

Action tags below intentionally use major-version references except where the
repository currently has a version-specific pin. Major tags can move; they are
an update-maintenance choice, not immutable pins.

## Third-party GitHub Actions

| Reference in this repository | Where used | Upstream release checked |
| --- | --- | --- |
| `actions/checkout@v7` | Reusable workflows and the Go/Python test composite actions | [v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1) |
| `actions/setup-go@v7` | Go build, lint, and staticcheck workflows | [v7.0.0](https://github.com/actions/setup-go/releases/tag/v7.0.0) |
| `actions/setup-node@v7` | Danger, npm publish, and semantic-release workflows | [v7.0.0](https://github.com/actions/setup-node/releases/tag/v7.0.0) |
| `actions/setup-python@v7` | Poetry and uv composite setup actions | [v7.0.0](https://github.com/actions/setup-python/releases/tag/v7.0.0) |
| `actions/cache@v6` | Python setup, Rust, Docker, and Danger workflows | [v6.1.0](https://github.com/actions/cache/releases/tag/v6.1.0) |
| `actions/upload-artifact@v7` | Buf and Bun build workflows | [v7.0.1](https://github.com/actions/upload-artifact/releases/tag/v7.0.1) |
| `codecov/codecov-action@v7` | Go/Python coverage composite actions and Python test workflow | [v7.1.1](https://github.com/codecov/codecov-action/releases/tag/v7.1.1) |
| `jenseng/dynamic-uses@v1` | Workflows and composite actions that select a setup action dynamically | [v1.1.1](https://github.com/jenseng/dynamic-uses/releases/tag/v1.1.1) |
| `astral-sh/setup-uv@v10` | uv composite setup action | [v10.2.0](https://github.com/astral-sh/setup-uv/releases/tag/v10.2.0) |
| `snok/install-poetry@v1` | Poetry composite setup action | [v1.4.2](https://github.com/snok/install-poetry/releases/tag/v1.4.2) |
| `oven-sh/setup-bun@v2` | Bun build workflow | [v2.2.0](https://github.com/oven-sh/setup-bun/releases/tag/v2.2.0) |
| `astral-sh/ruff-action@v4.1.0` | Ruff lint workflow | [v4.1.0](https://github.com/astral-sh/ruff-action/releases/tag/v4.1.0) |
| `golangci/golangci-lint-action@v9.3.0` | Go lint workflow | [v9.3.0](https://github.com/golangci/golangci-lint-action/releases/tag/v9.3.0) |
| `dominikh/staticcheck-action@v1.4.1` | Staticcheck workflow | [v1.4.1](https://github.com/dominikh/staticcheck-action/releases/tag/v1.4.1) |
| Docker `setup-qemu@v4`, `metadata@v6`, `setup-buildx@v4`, `login@v4`, and `build-push@v7` | Docker Hub and GHCR workflows | [QEMU v4.4.0](https://github.com/docker/setup-qemu-action/releases/tag/v4.4.0), [metadata v6.2.0](https://github.com/docker/metadata-action/releases/tag/v6.2.0), [Buildx v4.4.1](https://github.com/docker/setup-buildx-action/releases/tag/v4.4.1), [login v4.6.0](https://github.com/docker/login-action/releases/tag/v4.6.0), [build-push v7.4.0](https://github.com/docker/build-push-action/releases/tag/v7.4.0) |
| `bufbuild/buf-setup-action@v1` | Buf build workflow | [v1.50.0](https://github.com/bufbuild/buf-setup-action/releases/tag/v1.50.0) |
| `softprops/action-gh-release@v3` | GitHub release workflow | [v3.0.3](https://github.com/softprops/action-gh-release/releases/tag/v3.0.3) |
| `rtCamp/action-slack-notify@v2` | Slack notification workflow | [v2.4.0](https://github.com/rtCamp/action-slack-notify/releases/tag/v2.4.0) |
| `actions-rust-lang/rustfmt@v1` | Rust lint workflow | [v1.1.2](https://github.com/actions-rust-lang/rustfmt/releases/tag/v1.1.2) |
| `actions-rust-lang/setup-rust-toolchain@v1` | Rust lint workflow | [v1.17.0](https://github.com/actions-rust-lang/setup-rust-toolchain/releases/tag/v1.17.0) |
| `danger/danger-js@9.1.8` | Danger workflow; exact tool-version pin | [npm version](https://www.npmjs.com/package/danger/v/9.1.8) |
| `wangchucheng/git-repo-sync@v0.1.0` | Repository sync workflow | [Latest upstream release](https://github.com/wangchucheng/git-repo-sync/releases/tag/v0.1.0) |

The newer `setup-rust-toolchain` v2 release changes warning behavior, so the
workflow remains on its v1 line until that behavior can be evaluated separately.
The repo-sync action has no later upstream release; do not invent a replacement
version without evaluating a migration. Danger remains on 9.1.8 because the
upstream package is now 14.x and that major jump needs a separate compatibility
review. `setup-uv` v10 removed no inputs used here, while `setup-python` v7's
removed `pip-install` input is not used by these workflows.

## Tool versions and defaults

| Tool | Repository default/reference | Where used | Upstream source |
| --- | --- | --- | --- |
| Go | `1.26` | Go reusable workflows and Go composite action | [Go release policy](https://go.dev/doc/devel/release#policy), [releases](https://go.dev/dl/) |
| Python | `3.12` | General Python workflows and Poetry setup; the uv setup action also defaults to `3.12` | [Python version status](https://devguide.python.org/versions/) |
| Python for Ruff | `3.14` | Ruff lint workflow | [Python version status](https://devguide.python.org/versions/) |
| Node.js | `24.x` | Danger and npm-publish workflows | [Node.js release schedule](https://github.com/nodejs/Release) |
| Node.js for semantic-release | `lts/*` | semantic-release workflow; intentionally follows the current LTS line | [Node.js release schedule](https://github.com/nodejs/Release) |
| Bun | `1.4.2` | Bun build workflow | [Bun v1.4.2](https://github.com/oven-sh/bun/releases/tag/bun-v1.4.2) |
| Ruff | `0.16.3` | Ruff workflow input default | [Ruff releases](https://github.com/astral-sh/ruff/releases) |
| uv | `latest` | uv composite action input default; callers can provide an exact version | [uv releases](https://github.com/astral-sh/uv/releases) |
| Poetry | `latest` | Poetry composite action input default; callers can provide an exact version | [Poetry releases](https://github.com/python-poetry/poetry/releases) |
| Staticcheck | `latest` | Staticcheck workflow input default | [Staticcheck releases](https://github.com/dominikh/staticcheck/releases) |
| Rust toolchain | `stable` | Rust build/lint workflows | [Rust release channels](https://doc.rust-lang.org/book/appendix-07-nightly-rust.html) |
| golang-migrate | `4.20.1` | Database migration composite action | [v4.20.1](https://github.com/golang-migrate/migrate/releases/tag/v4.20.1) |
| Danger JS | `9.1.8` | Danger workflow | [npm package](https://www.npmjs.com/package/danger) |

The Go default uses the supported 1.26 line rather than the newly released 1.27
line to allow downstream Go tooling to catch up. The Python and Node defaults
move away from older runtime lines, while remaining caller-overridable. The Go
test workflow's optional database and cache service images are caller-selected;
their image version inputs still default to `latest`, so callers should set an
explicit compatible version when reproducibility matters.

### Unpinned installations

These package-manager installs intentionally remain unchanged in this audit
because the templates do not provide a consumer lockfile or a compatibility
test for choosing a fixed package set. They resolve versions at job runtime:

- The GitLab release template globally installs `semantic-release`,
  `@semantic-release/gitlab`, `@semantic-release/changelog`, and
  `@semantic-release/git` without version constraints.
- The GitLab PyPI template installs the latest `twine` with `pip`.
- The Danger workflow runs `yarn install` against the consuming repository's
  dependencies; consumers should commit and use their lockfile.

Pin these dependencies or add a tested lockfile if deterministic tool
resolution is required. Do not update them independently of the consumer
project's semantic-release configuration or package support policy.

## Container images

| Image reference | Where used | Reason/source |
| --- | --- | --- |
| `docker:29-cli` with `docker:29-dind` | GitLab Docker Hub build template | Matching Docker 29 CLI/daemon major; [CLI tag](https://hub.docker.com/layers/library/docker/29-cli/images/sha256-b0dfb3beea69612ccf1f9cfd8f74179b9c497d6b0c9e1294664dffe9bc1c070a), [DinD tag](https://hub.docker.com/layers/library/docker/29-dind/images/sha256-dcac6f16dc25ddec91e2d467605775b95a035ab884b94cb4c2cc7cbef6fd726d) |
| `hadolint/hadolint:v2.15.1` | GitLab Hadolint template | Latest upstream version checked; [release](https://github.com/hadolint/hadolint/releases/tag/v2.15.1) |
| `docker.io/andrcuns/dependabot-gitlab:0.11.0` | GitLab Dependabot template | Retained: newer versioned tags found are prereleases; no compatibility notes for upgrading were available. [Current tag](https://hub.docker.com/layers/andrcuns/dependabot-gitlab/0.11.0/images/sha256-d41510387ea5b73e6b9dd478e79a33073857aed45fcb74e65555605b55c22c5d), [image tags](https://hub.docker.com/r/andrcuns/dependabot-gitlab/tags) |
| `sonarsource/sonar-scanner-cli:12.2.0.4256_8.1.0` | GitLab SonarCloud template | Replaces floating `latest` with the current published scanner image; [image tag](https://hub.docker.com/r/sonarsource/sonar-scanner-cli/tags?name=12.2.0.4256_8.1.0), [upstream release](https://github.com/SonarSource/sonar-scanner-cli/releases/latest) |
| `python:3.12-bookworm` | GitLab PyPI publishing template | Supported Python line with explicit Debian base; [official image tag](https://hub.docker.com/_/python/tags?name=3.12-bookworm) |
| `node:24-bookworm` | GitLab semantic-release template | Active LTS line with explicit Debian base; [Node.js schedule](https://github.com/nodejs/Release), [official image tag](https://hub.docker.com/_/node/tags?name=24-bookworm) |
| `postgres:16-alpine` | Python/PostgreSQL workflow default | Keeps PostgreSQL 16 compatibility while taking current 16.x patch updates; [official image tag](https://hub.docker.com/_/postgres/tags?name=16-alpine) |
| `cloudposse/slack-notifier@sha256:4e3c6d73d9c4ac15ef63d812acae5f8d3f0d166a642eb44d55836769619097c1` | GitLab Slack notification template | Pins the existing amd64 `latest` image contents by digest; upstream's tag has not changed since April 2024. [Docker Hub tag metadata](https://hub.docker.com/r/cloudposse/slack-notifier/tags) |

The `slack-notification`, `dependabot`, and `sonarcloud` GitLab templates now
have explicit image references. The Slack notifier image is digest-pinned
because upstream publishes no semantic version tags. GitHub service containers
in the Go test workflow are caller-configurable and are not fixed image
references.
