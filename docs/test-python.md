# test-python — Pytest with Coverage Reporting

## What it does

This workflow installs project dependencies from a requirements file and a set of standard testing packages (pytest, pytest-cov, pytest-asyncio, httpx), then runs the test suite with coverage measurement enabled. Coverage is reported in three formats: terminal output for inline visibility, XML for downstream tooling, and JSON for the job summary script. Test counts (passed, failed, skipped) and the overall coverage percentage are extracted and written to the GitHub Actions job summary. The `coverage.xml` artifact is uploaded for integration with external coverage services if needed.

## Why we run it

Automated tests verify that code behaves as intended and catch regressions before they reach production. Coverage measurement provides a signal (not a guarantee) about which parts of the codebase are exercised by the test suite. Running tests on every push and pull request ensures that new code does not silently break existing behavior.

This check is **recommended** for all sitech-nafith Python repositories. See [standard-checks.md](standard-checks.md) for policy details.

## Minimal usage

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    uses: sitech-nafith/shared-workflows/.github/workflows/test-python.yml@main
```

## All inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `python_version` | string | `3.12` | Python version for the runner environment |
| `test_paths` | string | `tests/` | Space-separated paths passed to pytest as positional arguments |
| `requirements_file` | string | `requirements.txt` | Path to the pip requirements file to install before tests |
| `extra_packages` | string | `""` | Additional pip packages to install beyond the requirements file and the built-in test dependencies (space-separated) |
| `cov_source` | string | `app` | Package or directory passed to `--cov=` for coverage measurement |
| `min_coverage` | number | `0` | Minimum coverage percentage. When greater than 0, pytest will fail if total coverage is below this threshold. `0` means no threshold is enforced. |

## How to read the summary output

The job summary shows a single table row with test counts and coverage:

| Status | Passed | Failed | Skipped | Coverage |
|---|---|---|---|---|
| PASSED | 142 | 0 | 3 | [OK] 84.7% |

The coverage icon has three states:
- `[OK]` — 80% or above
- `[WARN]` — between 60% and 79%
- `[LOW]` — below 60%

The full coverage breakdown by file is available in the `coverage.xml` artifact and in the pytest terminal output captured in `pytest-output.txt` (also visible in the step log).

## Common issues / FAQ

**Q: Tests that pass locally are failing in CI with import errors.**

The most common cause is a missing package. Check whether all transitive dependencies are pinned in `requirements.txt`. In some projects, dev dependencies (test libraries, fixtures) are in a separate `requirements-dev.txt`. Use the `extra_packages` input to install them:

```yaml
with:
  extra_packages: "factory-boy freezegun"
```

**Q: Environment variables set in `.env` locally are not available in CI.**

Tests should never read from a `.env` file directly. Use `conftest.py` to set required environment variables before importing the application. Set values with `os.environ["KEY"] = "value"` directly — do not use `os.environ.setdefault`, because if the variable is already set by the runner environment it will silently keep the wrong value.

**Q: Coverage is lower in CI than locally.**

Coverage depends on which tests are collected. Verify that the `test_paths` input matches the directory structure and that no tests are being skipped due to missing marks or environment checks. Also verify that `cov_source` points to the correct package directory — a mismatch means some source files are not counted.
