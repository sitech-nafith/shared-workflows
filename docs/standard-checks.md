# Standard Checks Policy

This document defines the minimum security and quality bar required for all repositories under the **sitech-nafith** GitHub organization.

---

## Purpose

Inconsistent CI practices across repositories create blind spots that lead to secrets leaking, vulnerable containers reaching production, and low-quality code entering the codebase. The standard checks defined here establish a uniform, automated baseline that every repository must meet.

These checks are implemented as reusable workflows in `sitech-nafith/shared-workflows` and are called from each repository's own CI pipeline. This design ensures that improvements to the checks propagate to all repositories automatically.

---

## Mandatory vs Recommended Checks

| Check | File | Mandatory for | Recommended for |
|---|---|---|---|
| Secret scan | `secret-scan.yml` | All repositories | — |
| SAST (Bandit) | `sast-python.yml` | All Python repositories | — |
| Docker scan (Trivy) | `docker-scan.yml` | Repositories that ship containers | — |
| Lint (Ruff) | `lint-python.yml` | — | All Python repositories |
| Unit tests (Pytest) | `test-python.yml` | — | All Python repositories |

A repository is considered a **Python repository** if it contains any `.py` source files outside of isolated scripts or tooling.

A repository is considered to **ship containers** if it maintains a `Dockerfile` or publishes to a container registry as part of its release process.

---

## Pass/Fail Criteria

### secret-scan (Gitleaks)

| Result | Condition |
|---|---|
| PASS | Gitleaks reports zero findings across the full git history |
| FAIL | One or more secrets detected anywhere in the commit history |

The full history scan (`fetch-depth: 0`) is mandatory. Scanning only the latest commit (`full_history: false`) is permitted only during initial adoption for repositories with pre-existing history issues that are being remediated under a waiver.

### sast-python (Bandit)

| Result | Condition |
|---|---|
| PASS | Zero HIGH-severity findings AND zero MEDIUM-severity findings |
| FAIL | One or more HIGH or MEDIUM findings at the configured confidence level |

LOW-severity findings are reported in the artifact but do not cause a failure. The default severity and confidence thresholds are both `medium`. Raising these thresholds requires a waiver.

### docker-scan (Trivy)

| Result | Condition |
|---|---|
| PASS (informational) | Scan completes regardless of findings (default behavior) |
| FAIL | `fail_on_severity` is set and one or more findings match that severity |

By default the Docker scan is informational — it surfaces CVE counts in the job summary without failing the pipeline. Repositories with a higher security posture requirement may set `fail_on_severity: CRITICAL` to enforce zero tolerance for critical vulnerabilities. Unfixed CVEs are excluded from counts by default (`trivy_ignore_unfixed: true`).

### lint-python (Ruff)

| Result | Condition |
|---|---|
| PASS | `ruff check` exits 0 AND `ruff format --check` exits 0 |
| FAIL | Any lint violation or formatting difference detected |

### test-python (Pytest)

| Result | Condition |
|---|---|
| PASS | All collected tests pass (zero failures, zero errors) |
| FAIL | One or more test failures or errors |
| COVERAGE WARN | Tests pass but coverage falls below `min_coverage` threshold |

Coverage below 80% is flagged in the job summary. The `min_coverage` input defaults to 0 (not enforced), but teams are encouraged to set a threshold of at least 60%.

---

## Waiver Process

Exemptions are granted for specific, documented reasons on a time-limited basis.

1. Open an issue in `sitech-nafith/shared-workflows` using the title format: `Waiver request: <repo-name> — <check-name>`
2. Include in the issue body:
   - Repository name and link
   - Which check(s) you are requesting an exemption from
   - Technical justification (why the check cannot be satisfied today)
   - Remediation plan with a target date
3. A maintainer of `sitech-nafith/shared-workflows` must approve the issue before the exemption is considered active.
4. Waivers are reviewed quarterly. Unresolved waivers that have passed their target date are escalated to the engineering lead.

Active waivers must be documented in the repository's own `README.md` or a `docs/security-waivers.md` file with a link to the approval issue.

---

## Enforcement Timeline

| Date | Milestone |
|---|---|
| 2026-07-01 | Shared workflows published and available for adoption |
| 2026-10-01 | All new repositories must adopt standard checks at creation |
| 2026-12-31 | All existing sitech-nafith repositories must adopt standard checks |
| 2027-01-01 | Repositories without standard checks will be flagged in the quarterly security review |

The adoption deadline for all existing repositories is **31 December 2026**.

See the [adoption announcement](#) for full context.

---

## Questions and Support

Open an issue in `sitech-nafith/shared-workflows` or contact the platform engineering team.
