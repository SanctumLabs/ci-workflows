require 'minitest/autorun'
require 'yaml'

class GoWorkflowContractTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  ACTION_PATH = File.join(ROOT, '.github/actions/go/action.yml')
  GO_WORKFLOW_PATHS = %w[
    .github/workflows/go.yml
    .github/workflows/go-test.yml
  ].map { |path| File.join(ROOT, path) }
  SHARED_WORKFLOW_INPUTS = %w[cache command go-version platform]

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

    assert_includes action.fetch('inputs').keys, 'codacy_token'

    action.fetch('inputs').each do |input_name, metadata|
      unsupported = metadata.keys - allowed_metadata
      assert_empty unsupported, "#{input_name} has unsupported metadata: #{unsupported.join(', ')}"
    end
  end

  def test_shared_go_workflow_inputs_have_matching_contracts
    contracts = GO_WORKFLOW_PATHS.map do |path|
      workflow = load_yaml(path)
      inputs = workflow_on(workflow).fetch('workflow_call').fetch('inputs')

      SHARED_WORKFLOW_INPUTS.each_with_object({}) do |input_name, contract|
        contract[input_name] = inputs.fetch(input_name).slice('type', 'required', 'default')
      end
    end

    assert_equal contracts.first, contracts.last
  end

  def test_go_workflows_delegate_to_action_with_declared_inputs
    action = load_yaml(ACTION_PATH)
    action_inputs = action.fetch('inputs')
    required_inputs = action_inputs.select { |_name, metadata| metadata['required'] }.keys

    GO_WORKFLOW_PATHS.each do |path|
      workflow = load_yaml(path)
      steps = workflow.fetch('jobs').values.flat_map { |job| job.fetch('steps', []) }
      action_steps = steps.select { |step| step['uses'].to_s.include?('/.github/actions/go@') }

      assert_equal 1, action_steps.length, "#{path} must invoke the Go composite action directly"
      assert_empty steps.select { |step| step.key?('run') || step['uses'].to_s.start_with?('actions/setup-go@') },
                   "#{path} duplicates Go setup or command execution"

      passed_inputs = action_steps.first.fetch('with')
      unknown_inputs = passed_inputs.keys - action_inputs.keys
      assert_empty unknown_inputs, "#{path} passes unknown action inputs: #{unknown_inputs.join(', ')}"
      assert_empty(required_inputs - passed_inputs.keys, "#{path} omits required action inputs")

      workflow_call = workflow_on(workflow).fetch('workflow_call')
      declared_context = {
        'inputs' => workflow_call.fetch('inputs', {}).keys,
        'secrets' => workflow_call.fetch('secrets', {}).keys
      }

      passed_inputs.each do |input_name, value|
        value.to_s.scan(/\$\{\{\s*(inputs|secrets)\.([\w-]+)\s*\}\}/).each do |context, name|
          assert_includes declared_context.fetch(context), name,
                          "#{path} #{input_name} references undeclared #{context}.#{name}"
        end
      end
    end
  end
end
