# CI dependency versions

This inventory covers third-party GitHub Actions, versions of tools installed or
run by this repository's templates, and container images referenced by GitHub
and GitLab CI. It was checked against upstream release notes and registries on
2026-11-15. Update this file whenever one of these references changes.

## Update policy

- Pin third-party Actions to a full commit SHA and include the corresponding
  upstream release version in a trailing comment. Select the latest stable
  compatible release and review its notes before crossing a major; do not assume
  that a major upgrade preserves inputs or behavior.
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

Third-party GitHub Actions are pinned to the full commit SHA for the verified
upstream release. Each `uses:` line includes a release-version comment for
reviewability; the SHA, not the comment or a moving tag, determines the code
that runs. To update one, verify compatibility against the upstream release,
resolve its tag to the commit SHA, change both the workflow reference and this
inventory, and retain the release comment.

## Third-party GitHub Actions

| Pinned reference (upstream release) | Where used | Upstream release |
| --- | --- | --- |
| `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | Reusable workflows and Go/Python test composite actions | [Release](https://github.com/actions/checkout/releases/tag/v7.0.1) |
| `actions/setup-go@b7ad1dad31e06c5925ef5d2fc7ad053ef454303e` (`v7.0.0`) | Go composite action and Go lint/staticcheck workflows | [Release](https://github.com/actions/setup-go/releases/tag/v7.0.0) |
| `actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1` (`v7.1.0`) | Danger, npm publish, and semantic-release workflows | [Release](https://github.com/actions/setup-node/releases/tag/v7.1.0) |
| `actions/setup-python@6d4fd22b20465ccc0f7354476588e8df7c9ca0e0` (`v7.1.0`) | Poetry and uv composite setup actions | [Release](https://github.com/actions/setup-python/releases/tag/v7.1.0) |
| `actions/cache@55cc8345863c7cc4c66a329aec7e433d2d1c52a9` (`v6.1.0`) | Python setup, Rust, Docker, and Danger workflows | [Release](https://github.com/actions/cache/releases/tag/v6.1.0) |
| `actions/upload-artifact@cf430e030ddbb5b0abf93d22962f4752f3646cd9` (`v7.0.2`) | Buf and Bun build workflows | [Release](https://github.com/actions/upload-artifact/releases/tag/v7.0.2) |
| `actions/download-artifact@9000827ccba6bdab643e8b6fd33ac0654aef8333` (`v8.0.2`) | Downstream example for merging artifacts from multiple Buf workflow calls | [Release](https://github.com/actions/download-artifact/releases/tag/v8.0.2) |
| `codecov/codecov-action@303a32d7a59b442fa8d48b6a1cc6825c09c847a5` (`v7.1.1`) | Go/Python coverage actions and Python test workflow | [Release](https://github.com/codecov/codecov-action/releases/tag/v7.1.1) |
| `jenseng/dynamic-uses@8bc24f0360175e710da532c4d19eafdbed489a06` (`v1.1.1`) | Workflows and composite actions that select a setup action dynamically | [Release](https://github.com/jenseng/dynamic-uses/releases/tag/v1.1.1) |
| `astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2` (`v10.3.3`) | uv composite setup action | [Release](https://github.com/astral-sh/setup-uv/releases/tag/v10.3.3) |
| `snok/install-poetry@a783c322200f0519c7926aa6faa857c4e23e9263` (`v1.4.2`) | Poetry composite setup action | [Release](https://github.com/snok/install-poetry/releases/tag/v1.4.2) |
| `oven-sh/setup-bun@0c5077e51419868618aeaa5fe8019c62421857d6` (`v2.2.0`) | Bun build workflow | [Release](https://github.com/oven-sh/setup-bun/releases/tag/v2.2.0) |
| `astral-sh/ruff-action@278981a28ce3188b1e39527901f38254bf3aac89` (`v4.1.0`) | Ruff lint workflow | [Release](https://github.com/astral-sh/ruff-action/releases/tag/v4.1.0) |
| `golangci/golangci-lint-action@ba0d7d2ec06a0ea1cb5fa41b2e4a3ab91d21278a` (`v9.3.0`) | Go lint workflow | [Release](https://github.com/golangci/golangci-lint-action/releases/tag/v9.3.0) |
| `dominikh/staticcheck-action@9716614d4101e79b4340dd97b10e54d68234e431` (`v1.4.1`) | Staticcheck workflow | [Release](https://github.com/dominikh/staticcheck-action/releases/tag/v1.4.1) |
| Docker QEMU `99012661954931238ded8c8b007157a8430204e1` (`v4.4.0`), metadata `dc802804100637a589fabce1cb79ff13a1411302` (`v6.2.0`), Buildx `f87e5991a6d7451dcb8d9637bfbc97413f497069` (`v4.4.1`), login `8aa5831fb8d48d8f76594c7ddde61ae58019f550` (`v4.8.0`), build-push `c3c9e263c25d99ce0380d002d59b67737d91b0dc` (`v7.4.0`) | Docker Hub and GHCR workflows | [QEMU](https://github.com/docker/setup-qemu-action/releases/tag/v4.4.0), [metadata](https://github.com/docker/metadata-action/releases/tag/v6.2.0), [Buildx](https://github.com/docker/setup-buildx-action/releases/tag/v4.4.1), [login](https://github.com/docker/login-action/releases/tag/v4.8.0), [build-push](https://github.com/docker/build-push-action/releases/tag/v7.4.0) |
| `bufbuild/buf-setup-action@a47c93e0b1648d5651a065437926377d060baa99` (`v1.50.0`) | Buf build workflow | [Release](https://github.com/bufbuild/buf-setup-action/releases/tag/v1.50.0) |
| `softprops/action-gh-release@8a0cd651e5b2365bd640854a3fa5dfc70e4875f3` (`v3.0.4`) | GitHub release workflow | [Release](https://github.com/softprops/action-gh-release/releases/tag/v3.0.4) |
| `rtCamp/action-slack-notify@06cc13f74fa8d4d2296c09455d91e9453e4025f4` (`v2.4.1`) | Slack notification workflow | [Release](https://github.com/rtCamp/action-slack-notify/releases/tag/v2.4.1) |
| `actions-rust-lang/rustfmt@4066006ec54a31931b9b1fddfd38f2fdf2d27143` (`v1.1.2`) | Rust lint workflow | [Release](https://github.com/actions-rust-lang/rustfmt/releases/tag/v1.1.2) |
| `actions-rust-lang/setup-rust-toolchain@166cdcfd11aee3cb47222f9ddb555ce30ddb9659` (`v1.17.0`) | Rust lint workflow | [Release](https://github.com/actions-rust-lang/setup-rust-toolchain/releases/tag/v1.17.0); v2.0.1 is newer but changes warning enforcement |
| `danger/danger-js@fbcbc6a9f652227b481b28ca226cee02a820d970` (`9.1.8`) | Danger workflow and exact tool version | [npm package](https://www.npmjs.com/package/danger/v/9.1.8) |
| `wangchucheng/git-repo-sync@63782025e80e84c48b25a1ee6bb9a22a3bd570d3` (`v0.1.0`) | Repository sync workflow | [Latest upstream release](https://github.com/wangchucheng/git-repo-sync/releases/tag/v0.1.0) |

The newer `setup-rust-toolchain` v2 release changes how compiler warnings are
enforced (using Cargo's `build.warnings` configuration rather than the previous
default `RUSTFLAGS`), so the workflow remains on its v1.17.0 commit until that
behavior can be evaluated separately.
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
| Node.js | `24.x` | Danger and npm-publish workflows; supported maintenance LTS line | [Node.js release schedule](https://github.com/nodejs/Release) |
| Node.js for semantic-release | `lts/*` | semantic-release workflow; intentionally follows the current LTS line | [Node.js release schedule](https://github.com/nodejs/Release) |
| Bun | `1.4.2` | Bun build workflow | [Bun v1.4.2](https://github.com/oven-sh/bun/releases/tag/bun-v1.4.2) |
| Ruff | `0.17.5` | Ruff workflow input default | [Ruff v0.17.5](https://github.com/astral-sh/ruff/releases/tag/0.17.5) |
| Buf CLI | `1.50.0` | Default `version` input from `buf-setup-action@v1`; the reusable workflow does not expose a version override | [buf-setup-action metadata](https://github.com/bufbuild/buf-setup-action/blob/v1/action.yml) |
| golangci-lint | `latest` unless the consumer's `go.mod` supplies a version | Go lint workflow; action input is not set | [golangci-lint releases](https://github.com/golangci/golangci-lint/releases) |
| uv | `latest` | uv composite action input default; callers can provide an exact version | [uv releases](https://github.com/astral-sh/uv/releases) |
| Poetry | `latest` | Poetry composite action input default; callers can provide an exact version | [Poetry releases](https://github.com/python-poetry/poetry/releases) |
| Staticcheck | `latest` | Staticcheck workflow input default | [Staticcheck releases](https://github.com/dominikh/staticcheck/releases) |
| Rust toolchain | `stable` | Rust build/lint workflows | [Rustup release channels](https://rust-lang.github.io/rustup/concepts/channels.html) |
| golang-migrate | `4.20.1` | Database migration composite action | [v4.20.1](https://github.com/golang-migrate/migrate/releases/tag/v4.20.1) |
| Danger JS | `9.1.8` | Danger workflow | [npm package](https://www.npmjs.com/package/danger) |

The Go default uses the supported 1.26 line rather than the newer 1.27 line
to allow downstream Go tooling to catch up. The Python and Node defaults
move away from older runtime lines, while remaining caller-overridable. The Go
test workflow's optional database and cache service images are caller-selected;
their image version inputs still default to `latest`, so callers should set an
explicit compatible version when reproducibility matters.

### Codecov authentication

Codecov Action v7 requires authentication for uploads from the upstream
repository; fork pull requests retain Codecov's tokenless support. The Go and
Python coverage actions expose an optional `codecov_token` input, and their
reusable workflows expose the matching `codecov_token` secret. Consumers that
enable coverage uploads should store their Codecov repository token as a
secret and pass it through. For example, reusable-workflow callers should map
their secret explicitly (replace `@main` with the stable ref used by your
project). Direct composite-action callers should pass the same secret as the
`codecov_token` input:

```yaml
jobs:
  test:
    uses: SanctumLabs/ci-workflows/.github/workflows/python-test.yml@main
    with:
      command: pytest
      upload-coverage: true
    secrets:
      codecov_token: ${{ secrets.CODECOV_TOKEN }}
```

The upload steps fail the job if Codecov reports an error, including CLI
signature or checksum verification failures. OIDC is supported by the upstream
action, but these reusable interfaces use an optional token to avoid requiring
additional `id-token: write` permissions from consumers. See the [Codecov v7
authentication documentation](https://github.com/codecov/codecov-action/blob/v7.1.1/README.md#using-oidc)
and [action inputs](https://github.com/codecov/codecov-action/blob/v7.1.1/action.yml).

### Buf artifact names

The reusable Buf workflow accepts an optional `artifact-name` input (default
`lib`). Give each call a unique name when invoking it more than once in a
workflow; download and merge those named artifacts in the consumer:

```yaml
jobs:
  buf-a:
    uses: SanctumLabs/ci-workflows/.github/workflows/buf_build.yaml@main
    with:
      artifact-name: lib-a
  buf-b:
    uses: SanctumLabs/ci-workflows/.github/workflows/buf_build.yaml@main
    with:
      artifact-name: lib-b
  combine:
    needs: [buf-a, buf-b]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@9000827ccba6bdab643e8b6fd33ac0654aef8333 # v8.0.2
        with:
          pattern: lib-*
          merge-multiple: true
```

Pin the reusable workflow to a stable repository ref and pin third-party
actions in consumer workflows according to their own policy.

## Internal reusable references

These are references to this repository rather than third-party actions. The
existing `@main` references are retained so repository workflows continue to
follow the checked-out default branch;
the release action's workflow is similarly coupled to the repository's main
branch. For consumers that need a stable workflow definition, use a published
release tag or a full commit SHA in the consumer's `uses:` reference. Do not
silently replace these with a version until the repository's consumer-facing
release-tag policy is established.

| Internal reference | Where used |
| --- | --- |
| `SanctumLabs/ci-workflows/.github/actions/go@main` | Go and Go test reusable workflows |
| `SanctumLabs/ci-workflows/.github/actions/python-test@main` | Python/PostgreSQL test workflow |
| `SanctumLabs/ci-workflows/.github/workflows/release-semantic.yml@main` | Internal release action |
| Python packager action paths at `@main` | Python build, lint, test, and publish workflows select `setup-python-${{ inputs.packager }}` dynamically |

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
| `docker:29-cli` with `docker:29-dind` | GitLab Docker Hub build template | Matching Docker 29 CLI/daemon major; the job installs Bash before running its Bash build script; [CLI tag](https://hub.docker.com/layers/library/docker/29-cli/images/sha256-b0dfb3beea69612ccf1f9cfd8f74179b9c497d6b0c9e1294664dffe9bc1c070a), [DinD tag](https://hub.docker.com/layers/library/docker/29-dind/images/sha256-dcac6f16dc25ddec91e2d467605775b95a035ab884b94cb4c2cc7cbef6fd726d) |
| `hadolint/hadolint:v2.15.1-debian` | GitLab Hadolint template | Debian variant includes a shell for the GitLab runner; [release](https://github.com/hadolint/hadolint/releases/tag/v2.15.1), [image tags](https://hub.docker.com/r/hadolint/hadolint/tags?name=v2.15.1-debian) |
| `docker.io/andrcuns/dependabot-gitlab:0.11.0` | GitLab Dependabot template | Retained: newer versioned tags found are prereleases; no compatibility notes for upgrading were available. [Current tag](https://hub.docker.com/layers/andrcuns/dependabot-gitlab/0.11.0/images/sha256-d41510387ea5b73e6b9dd478e79a33073857aed45fcb74e65555605b55c22c5d), [image tags](https://hub.docker.com/r/andrcuns/dependabot-gitlab/tags) |
| `sonarsource/sonar-scanner-cli:12.2.0.4256_8.1.0` | GitLab SonarCloud template | Replaces floating `latest` with the current published scanner image; [image tag](https://hub.docker.com/r/sonarsource/sonar-scanner-cli/tags?name=12.2.0.4256_8.1.0), [upstream release](https://github.com/SonarSource/sonar-scanner-cli/releases/latest) |
| `python:3.12-bookworm` | GitLab PyPI publishing template | Supported Python line with explicit Debian base; [official image tag](https://hub.docker.com/_/python/tags?name=3.12-bookworm) |
| `node:24-bookworm` | GitLab semantic-release template | Supported maintenance LTS line with explicit Debian base; [Node.js schedule](https://github.com/nodejs/Release), [official image tag](https://hub.docker.com/_/node/tags?name=24-bookworm) |
| `postgres:16-alpine` | Python/PostgreSQL workflow default | Keeps PostgreSQL 16 compatibility while taking current 16.x patch updates; [official image tag](https://hub.docker.com/_/postgres/tags?name=16-alpine) |
| `cloudposse/slack-notifier@sha256:4e3c6d73d9c4ac15ef63d812acae5f8d3f0d166a642eb44d55836769619097c1` | GitLab Slack notification template | Pins the existing amd64 `latest` image contents by digest; upstream's tag has not changed since April 2024. [Docker Hub tag metadata](https://hub.docker.com/r/cloudposse/slack-notifier/tags) |

The `slack-notification`, `dependabot`, and `sonarcloud` GitLab templates now
have explicit image references. The Slack notifier image is digest-pinned
because upstream publishes no semantic version tags. GitHub service containers
in the Go test workflow are caller-configurable and are not fixed image
references.
