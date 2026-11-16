# CI Workflows

Reusable CI workflows, composite GitHub Actions, and GitLab CI templates for
common build, test, lint, publish, and release tasks.

## Get started

- [Usage guide](docs/USAGE.md): supported entry points, inputs, secrets,
  permissions, configuration support, and copyable consumer examples.
- [Dependency versions](DEPENDENCY_VERSIONS.md): runtime defaults, third-party
  action pins, and version update policy.
- [Contributing](CONTRIBUTING.md): conventions and validation commands.

GitHub consumers call reusable workflows as jobs and pass credentials through
`secrets`; GitLab consumers include a template and extend its hidden job where
applicable. Pin consumer references to a published release tag or full commit
SHA rather than a moving `@main` ref. The usage guide documents the current
entry points and tested examples for both CI systems.
