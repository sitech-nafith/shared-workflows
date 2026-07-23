# lint-python — Ruff Lint & Format Check

## What it does

This workflow runs [Ruff](https://docs.astral.sh/ruff/), a fast Python linter and formatter, against one or more source directories. It performs two distinct checks: `ruff check` enforces style and correctness rules (equivalent to Flake8, isort, pyupgrade, and others combined), and `ruff format --check` verifies that all files match Ruff's canonical formatting without modifying them. Both checks produce structured output. A JSON lint report is uploaded as an artifact. Results are summarized in the job summary.

## Why we run it

Consistent code style reduces cognitive load during code review by eliminating style debates. Automated lint enforcement also catches real bugs: unused imports that shadow names, undefined variables, and incorrect exception handling are all flagged before the code reaches a reviewer. Ruff is chosen because it replaces multiple slower tools with a single fast binary and integrates with `pyproject.toml` for per-project configuration.

This check is **recommended** for all sitech-nafith Python repositories. See [standard-checks.md](standard-checks.md) for policy details.

## Minimal usage

```yaml
# .github/workflows/ci.yml
jobs:
  lint:
    uses: sitech-nafith/shared-workflows/.github/workflows/lint-python.yml@main
    with:
      lint_paths: "app/ sidecar/ tests/"
```

## All inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `python_version` | string | `3.12` | Python version for the runner environment |
| `lint_paths` | string | `.` | Space-separated list of directories or files to lint and format-check |
| `ruff_version` | string | `""` | Ruff version to pin (e.g. `0.4.4`). Leave empty to always install the latest published release. |

## How to read the summary output

The job summary shows a table with one row per check:

| Check | Status |
|---|---|
| Lint | PASSED |
| Format | FAILED |

Below the table, the count of lint violations is printed (e.g., `3 lint violation(s) found.`). When the format check fails, it means one or more files differ from the canonical Ruff format. Run `ruff format <paths>` locally to auto-fix formatting. When the lint check fails, run `ruff check --fix <paths>` to apply auto-fixable rules, then manually address any remaining violations.

## Common issues / FAQ

**Q: Ruff is enforcing a rule we disagree with (e.g., line length, or a specific rule code).**

Add a `[tool.ruff]` section to `pyproject.toml` in the repository root. Example to extend the default ignore list and set line length:

```toml
[tool.ruff]
line-length = 120

[tool.ruff.lint]
ignore = ["E402", "F841"]
```

The shared workflow respects any `pyproject.toml` configuration present in the repository.

**Q: A specific line triggers a rule that does not apply in context.**

Add an inline suppression comment:

```python
import os  # noqa: F401
```

To suppress a specific rule code: `# noqa: E501`. To suppress all rules on a line: `# noqa`. Prefer specific codes over blanket suppression.

**Q: The format check is failing but the code looks correct to me.**

Ruff's formatter is opinionated and deterministic. Run `ruff format <paths>` locally — it will rewrite the files to match exactly what the format check expects. Commit the result. Common causes of format failures include trailing whitespace, inconsistent quote style, and blank lines within functions.
