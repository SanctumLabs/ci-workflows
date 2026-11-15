# Contributing

## Reusable CI conventions

- Declare reusable-workflow inputs with a description and type; required inputs have no default, while optional inputs have an explicit default. Document action inputs and mark required inputs explicitly.
- Declare credentials as GitHub `secrets`, never as ordinary inputs. Mark secrets optional only when the workflow can safely run without them.
- Set the least permissions needed in each reusable workflow. Callers should grant only the permissions its jobs require; avoid `write-all`.
- Give optional runtime and runner inputs a conservative, explicit default; prefer a stable supported runtime version over `latest`. Do not change existing third-party action or runtime versions as part of unrelated changes.
- Use `./.github/actions/<name>` for local actions and repository-relative paths for scripts. Reference reusable workflows as `SanctumLabs/ci-workflows/.github/workflows/<file>@<ref>` and shared actions as `SanctumLabs/ci-workflows/.github/actions/<name>@<ref>`.
- For GitLab templates, document required and optional variables near the template, use hidden job names for reusable jobs, and keep executable shell in checked scripts or script blocks.

## Java and Kotlin workflows

- `java-ci.yml` supports Gradle and Maven projects with JDK 21 by default. Both paths expect the repository wrapper (`./gradlew` or `./mvnw`); `task` defaults to `test`, and `command` can replace it with a shell command. The Maven path can use `task: verify` for the standard full verification lifecycle.
- `kotlin-ci.yml` supports Kotlin projects using Gradle and the `./gradlew` wrapper. It defaults to the `test` task; set `task: build` or provide `command` for a different build.
- Both workflows accept `java-version` and `cache`; dependency caching is enabled by default. Java uses `setup-java` caching for the selected Gradle or Maven tool, and Kotlin uses Gradle caching.

Example Java caller:

```yaml
jobs:
  test:
    uses: SanctumLabs/ci-workflows/.github/workflows/java-ci.yml@main
    with:
      java-version: "21"
      build-tool: gradle
      task: check
```

Example Maven caller:

```yaml
jobs:
  test:
    uses: SanctumLabs/ci-workflows/.github/workflows/java-ci.yml@main
    with:
      build-tool: maven
      task: verify
```

Example Kotlin caller:

```yaml
jobs:
  test:
    uses: SanctumLabs/ci-workflows/.github/workflows/kotlin-ci.yml@main
    with:
      java-version: "21"
      task: build
```

The credential-free repository check validates GitHub workflow syntax, parses GitHub action metadata and GitLab templates, and checks GitLab shell syntax. Run it locally with:

```sh
ruby scripts/validate-ci-templates.rb
ruby tests/ci_validation_test.rb
```
