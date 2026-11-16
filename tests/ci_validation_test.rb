require "minitest/autorun"
require "rbconfig"
require "fileutils"
require "tempfile"
require "open3"
require "tmpdir"
require "yaml"

class CIValidationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  VALIDATOR = File.join(ROOT, "scripts/validate-ci-templates.rb")
  USAGE_GUIDE = File.join(ROOT, "docs/USAGE.md")
  FIXTURE = File.join(ROOT, "tests/fixtures/ci-validation/gitlab-template.yml")
  WORKFLOW_FIXTURE = File.join(ROOT, "tests/fixtures/ci-validation/go-workflow-consumer.yml")
  BUF_WORKFLOW = File.join(ROOT, ".github/workflows/buf_build.yaml")
  DOCKER_HUB_TEMPLATE = File.join(ROOT, ".gitlab/templates/docker-hub-build.yml")
  HADOLINT_TEMPLATE = File.join(ROOT, ".gitlab/templates/hadolint.yml")
  CODECOV_ACTIONS = %w[
    .github/actions/go/action.yml
    .github/actions/python-test/action.yml
  ].map { |path| File.join(ROOT, path) }.freeze
  CODECOV_WORKFLOWS = %w[
    .github/workflows/python-test.yml
    .github/workflows/go-test.yml
  ].map { |path| File.join(ROOT, path) }.freeze
  JVM_WORKFLOW_FIXTURES = %w[
    java-gradle-workflow-consumer.yml
    java-workflow-consumer.yml
    kotlin-command-workflow-consumer.yml
    kotlin-workflow-consumer.yml
  ].map { |name| File.join(ROOT, "tests/fixtures/ci-validation", name) }.freeze

  def run_validator(path)
    Open3.capture3(RbConfig.ruby, VALIDATOR, path)
  end

  def test_accepts_representative_gitlab_script
    _stdout, stderr, status = run_validator(FIXTURE)

    assert status.success?, stderr
  end

  def test_accepts_representative_reusable_workflow_consumer
    _stdout, stderr, status = run_validator(WORKFLOW_FIXTURE)

    assert status.success?, stderr
  end

  def test_buf_workflow_allows_distinct_artifact_names
    workflow = YAML.safe_load(File.read(BUF_WORKFLOW), aliases: false)
    workflow_call = workflow["on"] || workflow[true]
    input = workflow_call.fetch("workflow_call").fetch("inputs").fetch("artifact-name")
    upload_step = workflow.fetch("jobs").fetch("build").fetch("steps").find do |step|
      step["uses"].to_s.include?("actions/upload-artifact@")
    end

    assert_equal "string", input.fetch("type")
    assert_equal "lib", input.fetch("default")
    assert_equal "${{ inputs.artifact-name }}", upload_step.fetch("with").fetch("name")
  end

  def test_gitlab_images_provide_shells_required_by_their_jobs
    docker_template = YAML.safe_load(File.read(DOCKER_HUB_TEMPLATE), aliases: false)
    docker_job = docker_template.fetch(".docker-hub-build")

    assert_includes docker_job.fetch("before_script"), "apk add --no-cache bash"
    assert_includes docker_job.fetch("script").first, "docker-build.sh"
    assert_equal "hadolint/hadolint:v2.15.1-debian",
                 YAML.safe_load(File.read(HADOLINT_TEMPLATE), aliases: false)
                   .fetch("hadolint").fetch("image")
  end

  def test_codecov_uploads_use_explicit_authentication_and_fail_closed
    CODECOV_ACTIONS.each do |path|
      action = YAML.safe_load(File.read(path), aliases: false)
      assert_includes action.fetch("inputs"), "codecov_token"
      upload = action.fetch("runs").fetch("steps").find do |step|
        step["uses"].to_s.include?("codecov/codecov-action@")
      end

      assert_equal "${{ inputs.codecov_token }}", upload.fetch("with").fetch("token")
      assert_equal true, upload.fetch("with").fetch("fail_ci_if_error")
    end

    CODECOV_WORKFLOWS.each do |path|
      workflow = YAML.safe_load(File.read(path), aliases: false)
      workflow_call = workflow["on"] || workflow[true]
      assert_includes workflow_call.fetch("workflow_call").fetch("secrets"), "codecov_token"

      upload = workflow.fetch("jobs").values.flat_map { |job| job.fetch("steps", []) }.find do |step|
        step["uses"].to_s.include?("codecov/codecov-action@")
      end
      next unless upload

      assert_equal "${{ secrets.codecov_token }}", upload.fetch("with").fetch("token")
      assert_equal true, upload.fetch("with").fetch("fail_ci_if_error")
    end
  end

  def test_accepts_representative_jvm_workflow_consumers
    JVM_WORKFLOW_FIXTURES.each do |fixture|
      _stdout, stderr, status = run_validator(fixture)

      assert status.success?, "#{fixture}: #{stderr}"
    end
  end

  def test_jvm_consumer_inputs_match_reusable_workflows
    JVM_WORKFLOW_FIXTURES.each do |fixture|
      consumer = YAML.safe_load(File.read(fixture), aliases: false)
      workflow_path = consumer.fetch("jobs").values.first.fetch("uses").split("@", 2).first.split("/").last
      workflow = YAML.safe_load(
        File.read(File.join(ROOT, ".github/workflows", workflow_path)),
        aliases: false
      )
      workflow_call = workflow["on"] || workflow[true]
      defined_inputs = workflow_call.fetch("workflow_call").fetch("inputs")
      caller_inputs = consumer.fetch("jobs").values.first.fetch("with", {})

      caller_inputs.each do |name, value|
        assert_includes defined_inputs, name, "#{fixture} passes undefined input #{name}"

        input_type = defined_inputs.fetch(name).fetch("type")
        case input_type
        when "string"
          assert_kind_of String, value, "#{fixture} passes a non-string value for #{name}"
        when "boolean"
          assert_includes [true, false], value, "#{fixture} passes a non-boolean value for #{name}"
        when "number"
          assert_kind_of Numeric, value, "#{fixture} passes a non-numeric value for #{name}"
        end

        case name
        when "java-version"
          assert_includes %w[17 21 25], value, "#{fixture} uses an unsupported JDK version"
        when "build-tool"
          assert_includes %w[gradle maven], value, "#{fixture} uses an unsupported Java build tool"
        end
      end
    end
  end

  def test_usage_guide_documents_every_reusable_workflow_contract
    guide = File.read(USAGE_GUIDE)
    workflow_paths = Dir.glob(File.join(ROOT, ".github/workflows/*.{yml,yaml}")).sort

    workflow_paths.each do |path|
      workflow = YAML.safe_load(File.read(path), aliases: false)
      workflow_call = workflow["on"] || workflow[true]
      next unless workflow_call&.key?("workflow_call")

      relative_path = path.delete_prefix("#{ROOT}/")
      row = guide.lines.find { |line| line.start_with?("| `#{relative_path}` |") }
      refute_nil row, "usage guide is missing #{relative_path}"

      call = workflow_call.fetch("workflow_call")
      call.fetch("inputs", {}).each do |name, input|
        status = input["required"] ? "required" : "optional"
        entry = documented_input(row, name, relative_path)
        assert_includes entry, "(#{input.fetch("type")}; #{status}",
                        "#{relative_path} type or required status is missing for #{name}"
        if input.key?("default")
          assert_documented_default(entry, input["default"], relative_path, name)
        end
      end

      secrets = call["secrets"]
      if secrets.is_a?(Hash)
        secrets.each do |name, secret|
          status = secret["required"] ? "required" : "optional"
          assert_includes row, "`#{name}` (#{status})",
                          "#{relative_path} secret or required status is missing"
        end
      else
        assert_includes row, "none", "#{relative_path} should document that it takes no secrets"
      end

      permissions = workflow.fetch("permissions", {})
      unless permissions.empty?
        permissions.each do |name, value|
          assert_includes row, "#{name}: #{value}", "#{relative_path} permissions are missing"
        end
      end
      workflow.fetch("jobs", {}).each do |job_name, job|
        next unless job["permissions"]

        if job["permissions"].is_a?(Hash)
          job["permissions"].each do |name, value|
            assert_includes row, "#{name}: #{value}",
                            "#{relative_path} job permission #{job_name}.#{name} is missing"
          end
        else
          assert_includes row, "#{job_name}: #{job["permissions"]}",
                          "#{relative_path} job permissions are missing"
        end
      end
      if permissions.empty? && workflow.fetch("jobs", {}).values.none? { |job| job["permissions"] }
        assert_includes row, "not declared (caller defaults apply)",
                        "#{relative_path} should explain that permissions are not declared"
      end
    end
  end

  def test_rust_workflows_use_the_documented_toolchain_input
    %w[rust-build.yml rust-lint.yml rust-test.yml].each do |filename|
      path = File.join(ROOT, ".github/workflows", filename)
      workflow = YAML.safe_load(File.read(path), aliases: false)
      workflow_call = workflow["on"] || workflow[true]
      assert_equal "${{ inputs.rust-version }}",
                   workflow.fetch("jobs").values.flat_map { |job| job.fetch("steps") }
                          .find { |step| step["uses"].to_s.include?("setup-rust-toolchain") }
                          .fetch("with").fetch("toolchain"),
                   "#{filename} must pass rust-version to setup-rust-toolchain"
      assert_equal "stable", workflow_call.fetch("workflow_call").fetch("inputs")
                                             .fetch("rust-version").fetch("default")
    end
  end

  def test_usage_guide_documents_every_composite_action_contract
    guide = File.read(USAGE_GUIDE)

    Dir.glob(File.join(ROOT, ".github/actions/*/action.yml")).sort.each do |path|
      action = YAML.safe_load(File.read(path), aliases: false)
      relative_path = path.delete_prefix("#{ROOT}/")
      row = guide.lines.find { |line| line.start_with?("| `#{relative_path}` |") }
      refute_nil row, "usage guide is missing #{relative_path}"

      action.fetch("inputs", {}).each do |name, input|
        status = input["required"] ? "required" : "optional"
        entry = documented_input(row, name, relative_path)
        assert_includes entry, "(#{status}",
                        "#{relative_path} required status is missing for #{name}"
        if input.key?("default")
          assert_documented_default(entry, input["default"], relative_path, name)
        end
      end
    end
  end

  def test_usage_guide_lists_all_gitlab_templates_and_checked_examples
    guide = File.read(USAGE_GUIDE)

    Dir.glob(File.join(ROOT, ".gitlab/templates/*.{yml,yaml}")).each do |path|
      relative_path = path.delete_prefix("#{ROOT}/")
      assert_includes guide, "`#{relative_path}`", "usage guide is missing #{relative_path}"
    end

    Dir.glob(File.join(ROOT, "tests/fixtures/ci-validation/docs-*-workflow-consumer.yml")).each do |path|
      relative_path = path.delete_prefix("#{ROOT}/")
      assert_includes guide, relative_path, "usage guide is missing example link #{relative_path}"
    end

    assert_includes guide, "repository automation or internal wiring"
    assert_includes guide, "does not declare any as deprecated"

    Dir.glob(File.join(ROOT, ".github/workflows/*.{yml,yaml}")).sort.each do |path|
      workflow = YAML.safe_load(File.read(path), aliases: false)
      workflow_call = workflow["on"] || workflow[true] || {}
      next if workflow_call.key?("workflow_call")

      relative_path = path.delete_prefix("#{ROOT}/")
      assert_includes guide, "`#{relative_path}`",
                      "usage guide does not classify repo-only workflow #{relative_path}"
    end

    gitlab_example = YAML.safe_load(
      File.read(File.join(ROOT, "tests/fixtures/ci-validation/docs-gitlab-consumer.yml")),
      aliases: false
    )
    assert_includes guide, "../tests/fixtures/ci-validation/docs-gitlab-consumer.yml"
    include = gitlab_example.fetch("include").first
    assert_equal "/.gitlab/templates/docker-hub-build.yml", include.fetch("file")
    assert_equal ".docker-hub-build", gitlab_example.fetch("build-image").fetch("extends")
    assert_includes gitlab_example.fetch("build-image").fetch("variables"), "DOCKERHUB_PASSWORD"
    assert_equal "v1.4.1", include.fetch("ref")
    assert_equal ["build", "publish"], gitlab_example.fetch("stages")
    assert_includes gitlab_example.fetch("build-image").fetch("before_script").join("\n"),
                    "ci-workflows/v1.4.1/scripts/docker-build.sh"
    assert_includes gitlab_example.fetch("build-image").fetch("script").join("\n"),
                    "$CI_PROJECT_DIR/.ci-workflows/docker-build.sh"
  end

  def test_rejects_invalid_yaml
    with_fixture("invalid: [\n") do |path|
      _stdout, stderr, status = run_validator(path)

      refute status.success?
      assert_match(/invalid YAML/, stderr)
    end
  end

  def test_rejects_invalid_gitlab_shell
    with_fixture(".sample:\n  script:\n    - |\n        if true; then\n          echo missing-fi\n") do |path|
      _stdout, stderr, status = run_validator(path)

      refute status.success?
      assert_match(/invalid Bash syntax/, stderr)
    end
  end

  def test_rejects_incomplete_composite_action_metadata
    Dir.mktmpdir do |directory|
      %w[action.yml action.yaml].each do |metadata_file|
        path = File.join(directory, ".github/actions/sample/#{metadata_file}")
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, "name: Sample\ndescription: Example\nruns:\n  using: composite\n")
        _stdout, stderr, status = run_validator(path)

        refute status.success?
        assert_match(/action metadata must define/, stderr)
      end
    end
  end

  private

  def documented_input(row, name, path)
    inputs = row.split("|")[2].to_s.split("<br>").map(&:strip)
    entry = inputs.find { |candidate| candidate.start_with?("`#{name}` (") }
    refute_nil entry, "#{path} input #{name} is missing from the guide"
    entry
  end

  def assert_documented_default(entry, expected, path, name)
    raw_default = entry[/; default: (.*)\)\z/, 1]
    refute_nil raw_default, "#{path} default is missing for #{name}"
    assert_equal expected, YAML.safe_load(raw_default, aliases: false),
                 "#{path} default is incorrect for #{name}"
  end

  def with_fixture(contents)
    Tempfile.create(["ci-validation", ".yml"]) do |file|
      file.write(contents)
      file.flush
      yield file.path
    end
  end
end
