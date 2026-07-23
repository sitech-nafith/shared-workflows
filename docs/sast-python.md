# sast-python — Bandit SAST for Python

## What it does

This workflow runs [Bandit](https://bandit.readthedocs.io/), the standard Python SAST tool, against one or more source directories. Bandit analyzes the abstract syntax tree of each Python file, checking for known insecure patterns such as use of `subprocess` with shell interpolation, hardcoded passwords, SQL injection via string formatting, use of weak cryptography, and dozens of other security anti-patterns. Results are written to a structured JSON report, uploaded as an artifact, and summarized in the job summary with counts broken down by severity.

## Why we run it

Static analysis catches entire classes of security vulnerabilities before code is ever executed or reviewed by a human. Bandit's rule set is tuned specifically for Python and covers the OWASP Top 10 categories most relevant to Python web applications and services. Running it on every push and pull request ensures that new code does not introduce known-insecure patterns.

This check is **mandatory** for all sitech-nafith Python repositories. See [standard-checks.md](standard-checks.md) for policy details.

## Minimal usage

```yaml
# .github/workflows/ci.yml
jobs:
  sast:
    uses: sitech-nafith/shared-workflows/.github/workflows/sast-python.yml@main
    with:
      scan_paths: "app/ sidecar/"
```

## All inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `python_version` | string | `3.12` | Python version for the runner environment |
| `scan_paths` | string | `app/` | Space-separated list of directories or files to scan recursively |
| `severity_level` | string | `medium` | Minimum severity to report: `low`, `medium`, or `high`. Findings below this threshold are not included in the report. |
| `confidence_level` | string | `medium` | Minimum confidence to report: `low`, `medium`, or `high`. Findings with confidence below this threshold are not included. |

## How to read the summary output

The job summary shows a table with counts split by severity:

| Status | High | Medium | Low |
|---|---|---|---|
| PASSED | 0 | 0 | 2 |

The job **fails** (non-zero exit) when any HIGH or MEDIUM finding is present. LOW findings are shown for informational purposes only. The full report (`bandit-report.json`) is uploaded as an artifact and contains the file path, line number, CWE, and remediation suggestion for each finding.

## Common issues / FAQ

**Q: Bandit is flagging `subprocess.run` with a list argument, which is safe.**

Bandit's `B603` rule flags all `subprocess` calls at low severity, including the safe list-argument form. If this creates noise, you can suppress individual lines with a `# nosec B603` comment. For the comment to suppress correctly, place it on the same line as the call:

```python
result = subprocess.run(["nginx", "-t"], capture_output=True)  # nosec B603
```

If you use `# nosec` with a description word after the test ID (e.g., `# nosec B603 safe-list-arg`), Bandit may parse the word as a test name and emit a warning. Keep the comment to the test ID only, or add the description on the line above.

**Q: We use `os.chmod` in a sidecar and Bandit flags it as B103.**

Place the `# nosec B103` comment on the line **above** the `chmod` call (not inline), with a brief description explaining why the permission is intentional:

```python
# nosec B103 — 0o660 is intentional: readable by app group only
os.chmod(path, 0o660)
```

**Q: How do I suppress a finding across an entire file?**

Add a `# nosec` comment at the top of the file (after the module docstring) to suppress all findings in that file. This should be used sparingly and requires a comment explaining the rationale. Prefer per-line suppression where possible.
