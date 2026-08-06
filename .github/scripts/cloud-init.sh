#!/bin/bash
# Runs at OCI instance boot via user-data

GITHUB_REPO="__GITHUB_REPO__"   # optional now; can be removed if unused
GITHUB_ORG="__GITHUB_ORG__"
RUNNER_TOKEN="__RUNNER_TOKEN__"
RUNNER_NAME="__RUNNER_NAME__"
LOG="/tmp/runner-init.log"

# Pre-create log file writable by all users
touch "$LOG"
chmod 666 "$LOG"

echo "=== Cloud-init started ===" >> "$LOG"
echo "Runner name: $RUNNER_NAME" >> "$LOG"

# Wait for network to be ready
sleep 15

echo "=== Switching to ubuntu user ===" >> "$LOG"

# Export vars so they are available inside the heredoc
export GITHUB_REPO GITHUB_ORG RUNNER_TOKEN RUNNER_NAME LOG

sudo -u ubuntu -E bash << 'EOF'
cd /opt/actions-runner

echo "=== Registering runner: $RUNNER_NAME ===" >> "$LOG"

./config.sh \
  --url "https://github.com/${GITHUB_ORG}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "self-hosted,linux,arm64,oci" \
  --ephemeral \
  --unattended >> "$LOG" 2>&1

echo "=== Starting runner ===" >> "$LOG"
./run.sh >> "$LOG" 2>&1
echo "=== Job complete ===" >> "$LOG"
EOF
