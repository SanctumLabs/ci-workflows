require 'minitest/autorun'
require 'yaml'

class GoWorkflowContractTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  ACTION_PATH = File.join(ROOT, '.github/actions/go/action.yml')
  GO_TEST_WORKFLOW_PATH = File.join(ROOT, '.github/workflows/go-test.yml')

  def load_yaml(path)
    YAML.load_file(path)
  end

  def workflow_on(workflow)
    workflow['on'] || workflow[true]
  end

  def test_composite_action_does_not_invoke_a_reusable_workflow
    action_source = File.read(ACTION_PATH)
    action = load_yaml(ACTION_PATH)

    assert_equal 'composite', action.dig('runs', 'using')
    refute_match %r{\.github/workflows/}, action_source
    refute_match %r{jenseng/dynamic-uses}, action_source

    action.fetch('runs').fetch('steps').each do |step|
      assert step.key?('shell') unless step.key?('uses')
    end
  end

  def test_action_inputs_use_supported_metadata
    action = load_yaml(ACTION_PATH)
    allowed_metadata = %w[description default required deprecationMessage]

    action.fetch('inputs').each do |input_name, metadata|
      unsupported = metadata.keys - allowed_metadata
      assert_empty unsupported, "#{input_name} has unsupported metadata: #{unsupported.join(', ')}"
    end
  end

  def test_go_test_workflow_passes_declared_action_inputs
    action = load_yaml(ACTION_PATH)
    workflow = load_yaml(GO_TEST_WORKFLOW_PATH)
    action_steps = workflow.fetch('jobs').values.flat_map { |job| job.fetch('steps', []) }
                            .select { |step| step['uses'].to_s.include?('/.github/actions/go@') }

    assert_equal 1, action_steps.length, 'go-test.yml must invoke the Go composite action directly'

    action_inputs = action.fetch('inputs')
    passed_inputs = action_steps.first.fetch('with')
    unknown_inputs = passed_inputs.keys - action_inputs.keys
    required_inputs = action_inputs.select { |_name, metadata| metadata['required'] }.keys

    assert_empty unknown_inputs, "workflow passes unknown action inputs: #{unknown_inputs.join(', ')}"
    assert_empty(required_inputs - passed_inputs.keys, 'workflow omits required action inputs')

    call = workflow_on(workflow).fetch('workflow_call')
    declared_context = {
      'inputs' => call.fetch('inputs', {}).keys,
      'secrets' => call.fetch('secrets', {}).keys
    }

    passed_inputs.each do |input_name, value|
      value.to_s.scan(/\$\{\{\s*(inputs|secrets)\.([\w-]+)\s*\}\}/).each do |context, name|
        assert_includes declared_context.fetch(context), name,
                        "#{input_name} references undeclared #{context}.#{name}"
      end
    end
  end
end
