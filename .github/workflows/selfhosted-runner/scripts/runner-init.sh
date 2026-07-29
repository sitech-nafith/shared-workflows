  #!/bin/bash
  set -e

  GITHUB_ORG="sitech-nafith"
  RUNNER_TOKEN="$1"
  RUNNER_NAME="$2"

  cd /opt/actions-runner

  echo "=== Registering runner: $RUNNER_NAME ==="
  ./config.sh \
    --url "https://github.com/${GITHUB_ORG}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "self-hosted,linux,arm64,oci" \
    --ephemeral \
    --unattended

  echo "=== Starting runner ==="
  ./run.sh

  echo "=== Job complete, runner exited ==="
