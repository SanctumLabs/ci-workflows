require "minitest/autorun"
require "rbconfig"
require "fileutils"
require "tempfile"
require "open3"
require "tmpdir"

class CIValidationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  VALIDATOR = File.join(ROOT, "scripts/validate-ci-templates.rb")
  FIXTURE = File.join(ROOT, "tests/fixtures/ci-validation/gitlab-template.yml")

  def run_validator(path)
    Open3.capture3(RbConfig.ruby, VALIDATOR, path)
  end

  def test_accepts_representative_gitlab_script
    _stdout, stderr, status = run_validator(FIXTURE)

    assert status.success?, stderr
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
      path = File.join(directory, ".github/actions/sample/action.yml")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, "name: Sample\ndescription: Example\nruns:\n  using: composite\n")
      _stdout, stderr, status = run_validator(path)

      refute status.success?
      assert_match(/action metadata must define/, stderr)
    end
  end

  private

  def with_fixture(contents)
    Tempfile.create(["ci-validation", ".yml"]) do |file|
      file.write(contents)
      file.flush
      yield file.path
    end
  end
end
