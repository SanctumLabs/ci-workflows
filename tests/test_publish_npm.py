import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
PUBLISH_SCRIPT = ROOT / ".github/scripts/publish-npm.sh"
WORKFLOW = ROOT / ".github/workflows/publish_npm.yml"


class PublishNpmWorkflowTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.workspace = Path(self.temp_dir.name)
        self.bin_dir = self.workspace / "bin"
        self.bin_dir.mkdir()
        self.npm_log = self.workspace / "npm.log"

        fake_npm = self.bin_dir / "npm"
        fake_npm.write_text(
            '#!/usr/bin/env bash\n'
            'printf "%s\\t%s\\n" "$PWD" "$*" >> "$NPM_LOG"\n'
        )
        fake_npm.chmod(0o755)

    def tearDown(self):
        self.temp_dir.cleanup()

    def run_publish(self, package_directory):
        env = os.environ.copy()
        env.update(
            {
                "PATH": f"{self.bin_dir}{os.pathsep}{env['PATH']}",
                "NPM_LOG": str(self.npm_log),
                "PACKAGE_DIRECTORY": package_directory,
                "PACKAGE_VERSION": "1.2.3",
            }
        )
        return subprocess.run(
            ["bash", str(PUBLISH_SCRIPT)],
            cwd=self.workspace,
            env=env,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_root_directory_publishes_from_workspace_root(self):
        result = self.run_publish("")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.npm_log.read_text().splitlines(),
            [
                f"{self.workspace.resolve()}\tci",
                f"{self.workspace.resolve()}\tversion 1.2.3",
                f"{self.workspace.resolve()}\tpublish",
            ],
        )

    def test_package_directory_is_quoted_and_publishes_from_that_directory(self):
        package_name = "$(touch injected); package dir"
        package_dir = self.workspace / package_name
        package_dir.mkdir()

        result = self.run_publish(str(package_dir))

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.npm_log.read_text().splitlines(),
            [
                f"{package_dir}\tci",
                f"{package_dir}\tversion 1.2.3",
                f"{package_dir}\tpublish",
            ],
        )
        self.assertFalse((self.workspace / "injected").exists())

    def test_missing_package_directory_fails_before_running_npm(self):
        result = self.run_publish(str(self.workspace / "missing package"))

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Package directory does not exist", result.stderr)
        self.assertFalse(self.npm_log.exists())

    def test_workflow_uses_correct_output_and_passes_directory_via_environment(self):
        workflow = WORKFLOW.read_text()

        self.assertIn("steps.directory-check.outputs.changeDir", workflow)
        self.assertNotIn("steps.directory-check.ouputs", workflow)
        self.assertIn(
            "if: ${{ steps.directory-check.outputs.changeDir == 'true' }}",
            workflow,
        )
        self.assertIn(
            "if: ${{ steps.directory-check.outputs.changeDir != 'true' }}",
            workflow,
        )
        self.assertIn("PACKAGE_DIRECTORY: ${{ inputs.directory }}", workflow)
        self.assertIn('PACKAGE_DIRECTORY: ""', workflow)
        self.assertEqual(workflow.count("run: bash .github/scripts/publish-npm.sh"), 2)
        self.assertNotIn("cd ${{ inputs.directory }}", workflow)


if __name__ == "__main__":
    unittest.main()
