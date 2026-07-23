# docker-scan — Docker Build & Trivy CVE Scan

## What it does

This workflow builds a Docker image for the `linux/amd64` platform using Docker Buildx and then runs [Trivy](https://trivy.dev/) against the locally loaded image to detect known CVEs in OS packages and language runtime dependencies. The image is never pushed to a registry — it exists only for the duration of the scan. Trivy produces a JSON report that is uploaded as an artifact. The job summary includes a count table broken down by severity (CRITICAL / HIGH / MEDIUM) and a collapsible detail table for CRITICAL and HIGH findings, with each CVE linked to the Aqua Security vulnerability database. An optional `fail_on_severity` input can be set to cause the job to exit non-zero if findings at that severity level are present.

## Why we run it

Container images bundle OS packages and language runtimes alongside application code. New CVEs are published continuously, and a vulnerability in a base image dependency can expose a production service even when the application code itself is clean. Building and scanning every pull request and push to main ensures that newly published CVEs in the image's dependency tree are surfaced before the image is promoted to production.

This check is **mandatory** for all sitech-nafith repositories that ship containers. See [standard-checks.md](standard-checks.md) for policy details.

## Minimal usage

```yaml
# .github/workflows/ci.yml
jobs:
  docker-scan:
    uses: sitech-nafith/shared-workflows/.github/workflows/docker-scan.yml@main
    with:
      image_name: "nafith/gateway-manager"
```

## All inputs

| Input | Type | Default | Description |
|---|---|---|---|
| `image_name` | string | (required) | Local image name to assign during the build (e.g. `nafith/gateway-manager`). Used as the Trivy scan target. |
| `dockerfile_context` | string | `.` | Docker build context directory |
| `dockerfile_path` | string | `""` | Path to the Dockerfile. When empty, defaults to `Dockerfile` inside the context directory. |
| `trivy_severity` | string | `CRITICAL,HIGH,MEDIUM` | Comma-separated list of severity levels Trivy should include in the report |
| `trivy_ignore_unfixed` | boolean | `true` | When `true`, CVEs with no available fix are excluded from all counts and the detail table |
| `fail_on_severity` | string | `""` | When set (e.g. `CRITICAL`), the job fails if one or more findings at that exact severity level are present. Leave empty to make all findings informational. |

## How to read the summary output

The job summary contains three sections.

**Build section** — confirms whether the Docker build succeeded and which tag was used:

| Image | Tag | Status |
|---|---|---|
| `nafith/gateway-manager` | `a1b2c3d` | built |

**CVE count table** — shows finding counts per severity:

| Image | Critical | High | Medium |
|---|---|---|---|
| `nafith/gateway-manager` | [CRITICAL] 2 | [HIGH] 5 | 11 |

**Detail table** — a collapsible `<details>` block for each image that has CRITICAL or HIGH findings. Each row includes the severity, CVE ID (linked to `avd.aquasec.com`), affected package name, installed version, fixed version (or `—` if none), and a truncated title.

If `fail_on_severity` is set, a note at the bottom of the summary indicates whether the threshold was triggered.

## Common issues / FAQ

**Q: The build fails with "no space left on device".**

GitHub-hosted runners have limited disk space. Large base images combined with multi-stage builds can exhaust available space. Use `docker system prune` in a step before the build, or consider using a smaller base image (e.g., `python:3.12-slim` instead of `python:3.12`).

**Q: Trivy is reporting CVEs in the base OS that have no fix available.**

This is expected and is why `trivy_ignore_unfixed` defaults to `true`. Unfixed CVEs cannot be remediated by changing the image — they require a new base image release from the upstream maintainer. Monitor the base image release notes and update the `FROM` line when a patched version is available.

**Q: The build always targets `linux/amd64`. What if we need `arm64`?**

The `linux/amd64` platform is hardcoded to match the production server architecture (OCI x86 instances). Do not override this without also verifying that the production deployment target supports the new architecture. If multi-arch support is needed, open an issue in this repository to discuss extending the workflow.
