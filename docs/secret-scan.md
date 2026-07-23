# secret-scan — Gitleaks Secret Scanning

## What it does

This workflow installs Gitleaks and runs it against the repository to detect secrets (API keys, tokens, passwords, private keys, and similar sensitive strings) that have been committed to git. By default it scans the full commit history rather than only the latest commit, ensuring that secrets removed in a subsequent commit are still flagged. Findings are written to a JSON report, uploaded as an artifact, and summarized in the GitHub Actions job summary.

## Why we run it

A committed secret can be exploited even after it is removed from the latest code, because the git history remains accessible to anyone with repository read access. Automated secret scanning on every push and pull request prevents secrets from entering the history in the first place and catches any that slip through code review.

This check is **mandatory** for all sitech-nafith repositories. See [standard-checks.md](standard-checks.md) for policy details.

## Minimal usage

```yaml
# .github/workflows/ci.yml
jobs:
  secret-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/secret-scan.yml@main
```

## All inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `gitleaks_version` | string | `8.27.2` | Gitleaks release version to download and install |
| `full_history` | boolean | `true` | When `true`, checks out the full git history (`fetch-depth: 0`). Set to `false` to scan only the latest commit (not recommended — requires a waiver). |

## How to read the summary output

After the job runs, the GitHub Actions job summary shows a table with two columns:

| Status | Findings |
|---|---|
| PASSED | No secrets detected |

or

| Status | Findings |
|---|---|
| FAILED | 3 secret(s) detected |

The full structured report (`gitleaks-report.json`) is uploaded as an artifact named `gitleaks-report`. Download it from the Actions run page to see which files and commits contain findings. Each entry includes the rule that matched, the file path, the line number, and the commit SHA.

## Common issues / FAQ

**Q: The scan is failing on a test fixture or example credential.**

Gitleaks supports an `allowlist` in `.gitleaks.toml` at the root of the repository. You can allowlist specific files, regex patterns, or commit SHAs. Example:

```toml
[allowlist]
  paths = ["tests/fixtures/sample_config.env"]
```

Add a comment in the file explaining why the string is safe (e.g., `# test fixture — not a real credential`).

**Q: The scan is slow because the history is very large.**

This is expected for repositories with long histories. Gitleaks exits as soon as the scan completes — there is no way to skip earlier commits selectively without a waiver. On most repositories the scan finishes within 60 seconds.

**Q: A secret was committed before this check was adopted. What do I do?**

The secret must be treated as compromised and rotated immediately, regardless of when it was committed. After rotation, use a Gitleaks allowlist to suppress the historical finding for the specific commit SHA. Document the rotation and suppression in the waiver issue. See [standard-checks.md](standard-checks.md) for the waiver process.
