# sitech-nafith Shared Workflows

## Overview

This repository provides reusable GitHub Actions workflows (callable via `workflow_call`) for all repositories in the **sitech-nafith** GitHub organization. Each workflow encapsulates one standard check so that improvements to the check implementation propagate to every caller automatically.

Workflows are maintained by the platform engineering team. The organizational policy governing which checks are mandatory, their pass/fail criteria, and the adoption deadline is defined in [docs/standard-checks.md](docs/standard-checks.md).

All existing sitech-nafith repositories must adopt the standard checks by **31 December 2026**.

---

## Available Workflows

| Workflow | File | What it checks | Typical runtime |
|---|---|---|---|
| Secret scan | `secret-scan.yml` | Full git history for committed secrets (Gitleaks) | 30–90 s |
| SAST | `sast-python.yml` | Python source for insecure code patterns (Bandit) | 20–60 s |
| Lint & format | `lint-python.yml` | Code style and formatting (Ruff) | 10–30 s |
| Unit tests | `test-python.yml` | Test suite execution with coverage reporting (Pytest) | 1–5 min |
| Docker scan | `docker-scan.yml` | Container image build + CVE scan (Trivy) | 2–8 min |

---

## Quick Start

The following example shows a complete caller workflow for a Python project that also ships a Docker container. Copy this into `.github/workflows/ci.yml` in your repository and adjust the inputs for your project layout.

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  secret-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/secret-scan.yml@main

  sast:
    uses: sitech-nafith/shared-workflows/.github/workflows/sast-python.yml@main
    with:
      scan_paths: "app/ sidecar/"

  lint:
    uses: sitech-nafith/shared-workflows/.github/workflows/lint-python.yml@main
    with:
      lint_paths: "app/ sidecar/ tests/"

  test:
    uses: sitech-nafith/shared-workflows/.github/workflows/test-python.yml@main
    with:
      cov_source: "app"
      min_coverage: 60

  docker-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/docker-scan.yml@main
    with:
      image_name: "nafith/my-service"
      fail_on_severity: "CRITICAL"
```

---

## Usage by Workflow

### secret-scan

Runs Gitleaks against the repository. By default scans the full git history.

```yaml
jobs:
  secret-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/secret-scan.yml@main
```

With explicit version pin and shallow scan (requires waiver — see [standard-checks.md](docs/standard-checks.md)):

```yaml
jobs:
  secret-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/secret-scan.yml@main
    with:
      gitleaks_version: "8.27.2"
      full_history: false
```

| Input | Type | Default | Description |
|---|---|---|---|
| `gitleaks_version` | string | `8.27.2` | Gitleaks release version to download |
| `full_history` | boolean | `true` | Scan full git history. `false` scans HEAD only (not recommended). |

---

### sast-python

Runs Bandit SAST on Python source directories.

```yaml
jobs:
  sast:
    uses: sitech-nafith/shared-workflows/.github/workflows/sast-python.yml@main
    with:
      scan_paths: "app/"
```

| Input | Type | Default | Description |
|---|---|---|---|
| `python_version` | string | `3.12` | Python version for the runner |
| `scan_paths` | string | `app/` | Space-separated directories or files to scan |
| `severity_level` | string | `medium` | Minimum severity to report: `low`, `medium`, `high` |
| `confidence_level` | string | `medium` | Minimum confidence to report: `low`, `medium`, `high` |

---

### lint-python

Runs `ruff check` (lint) and `ruff format --check` (format verification).

```yaml
jobs:
  lint:
    uses: sitech-nafith/shared-workflows/.github/workflows/lint-python.yml@main
    with:
      lint_paths: "app/ tests/"
```

| Input | Type | Default | Description |
|---|---|---|---|
| `python_version` | string | `3.12` | Python version for the runner |
| `lint_paths` | string | `.` | Space-separated directories or files to check |
| `ruff_version` | string | `""` | Pin a specific Ruff version (e.g. `0.4.4`). Empty installs latest. |

---

### test-python

Runs pytest with coverage measurement. Installs `requirements.txt` plus pytest, pytest-cov, pytest-asyncio, and httpx automatically.

```yaml
jobs:
  test:
    uses: sitech-nafith/shared-workflows/.github/workflows/test-python.yml@main
    with:
      cov_source: "app"
      min_coverage: 60
```

| Input | Type | Default | Description |
|---|---|---|---|
| `python_version` | string | `3.12` | Python version for the runner |
| `test_paths` | string | `tests/` | Paths passed to pytest |
| `requirements_file` | string | `requirements.txt` | Requirements file to install |
| `extra_packages` | string | `""` | Additional pip packages to install (space-separated) |
| `cov_source` | string | `app` | Argument for `--cov=` |
| `min_coverage` | number | `0` | Fail if coverage is below this percentage. `0` = not enforced. |

---

### docker-scan

Builds a Docker image for `linux/amd64` and scans it with Trivy. Never pushes to a registry.

```yaml
jobs:
  docker-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/docker-scan.yml@main
    with:
      image_name: "nafith/my-service"
```

With a non-default Dockerfile location and hard failure on CRITICAL CVEs:

```yaml
jobs:
  docker-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/docker-scan.yml@main
    with:
      image_name: "nafith/firewall-sidecar"
      dockerfile_context: "sidecar/"
      fail_on_severity: "CRITICAL"
```

| Input | Type | Default | Description |
|---|---|---|---|
| `image_name` | string | (required) | Local image name (e.g. `nafith/gateway-manager`) |
| `dockerfile_context` | string | `.` | Docker build context directory |
| `dockerfile_path` | string | `""` | Path to Dockerfile. Empty defaults to `Dockerfile` inside context. |
| `trivy_severity` | string | `CRITICAL,HIGH,MEDIUM` | Severities Trivy should report |
| `trivy_ignore_unfixed` | boolean | `true` | Exclude CVEs with no available fix |
| `fail_on_severity` | string | `""` | Fail job if this severity has findings. Empty = informational only. |

---

## Adoption Deadline

All sitech-nafith repositories must adopt the standard checks defined in [docs/standard-checks.md](docs/standard-checks.md) by **31 December 2026**.

New repositories created after 1 October 2026 must include standard checks from the time of creation.

See the [adoption announcement](#) for the full rollout timeline and background.

---

## Support

- Open an issue in this repository for questions about workflow behavior, waiver requests, or to report a bug.
- For urgent security concerns, contact the platform engineering team directly.
- Consult the per-check documentation in the [docs/](docs/) directory for detailed usage guidance and common troubleshooting steps.
