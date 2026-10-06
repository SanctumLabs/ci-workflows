#!/usr/bin/env ruby

require "open3"
require "yaml"

ROOT = File.expand_path("..", __dir__)
SHELL_FIELDS = %w[script before_script after_script].freeze

def parse_yaml(path)
  YAML.safe_load(File.read(path), aliases: false)
rescue StandardError => error
  raise "#{path}: invalid YAML: #{error.message}"
end

def validate_workflow(path, document)
  return unless path.match?(%r{(?:^|/)\.github/workflows/})

  unless document.key?("name") && document.key?("jobs") && document["jobs"].is_a?(Hash)
    raise "#{path}: workflow must define name and jobs"
  end
end

def validate_action_metadata(path, document)
  return unless path.match?(%r{(?:^|/)\.github/actions/[^/]+/action\.yml\z})

  runs = document["runs"]
  valid_runs = case runs.is_a?(Hash) ? runs["using"] : nil
               when "composite"
                 runs["steps"].is_a?(Array)
               when "docker"
                 runs["image"].is_a?(String)
               else
                 runs.is_a?(Hash) && runs["using"].to_s.match?(/\Anode\d+\z/) &&
                   runs["main"].is_a?(String)
               end
  return if document["name"].is_a?(String) && document["description"].is_a?(String) && valid_runs

  raise "#{path}: action metadata must define name, description, and valid runs for its runtime"
end

def shell_commands(node, path, commands = [])
  case node
  when Hash
    node.each do |key, value|
      if SHELL_FIELDS.include?(key)
        flatten_commands(value, path, commands)
      else
        shell_commands(value, path, commands)
      end
    end
  when Array
    node.each { |value| shell_commands(value, path, commands) }
  end
  commands
end

def flatten_commands(value, path, commands)
  case value
  when String
    commands << [path, value]
  when Array
    value.each { |item| flatten_commands(item, path, commands) }
  else
    raise "#{path}: shell fields must contain strings or arrays of strings"
  end
end

def validate_shell(path, source)
  _stdout, stderr, status = Open3.capture3("bash", "-n", stdin_data: source)
  return if status.success?

  raise "#{path}: invalid Bash syntax: #{stderr.strip}"
end

def validate_file(path)
  if path.end_with?(".yml", ".yaml")
    document = parse_yaml(path)
    raise "#{path}: expected a YAML mapping" unless document.is_a?(Hash)

    validate_workflow(path, document)
    validate_action_metadata(path, document)
    shell_commands(document, path).each { |source_path, source| validate_shell(source_path, source) }
  elsif path.end_with?(".sh")
    validate_shell(path, File.read(path))
  end
end

def default_files
  Dir.chdir(ROOT) do
    Dir.glob([
      ".github/workflows/**/*.{yml,yaml}",
      ".github/actions/**/action.yml",
      ".gitlab/templates/**/*.{yml,yaml}",
      "scripts/**/*.sh",
      "tests/fixtures/ci-validation/**/*.{yml,yaml}"
    ]).sort
  end
end

files = ARGV.empty? ? default_files : ARGV
begin
  files.each { |path| validate_file(path) }
  puts "Validated #{files.length} CI metadata and shell files."
rescue StandardError => error
  warn error.message
  exit 1
end
