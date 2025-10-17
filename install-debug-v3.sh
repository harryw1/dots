#!/usr/bin/env bash

# DEBUG VERSION 3 - Test full installation flow
# This version doesn't source the original script to avoid double execution

# Enable debugging
exec 2> >(tee -a "install-debug-v3.log" >&2)

echo "=== DEBUG V3 STARTED ===" | tee -a install-debug-v3.log
echo "Time: $(date)" | tee -a install-debug-v3.log
echo "PWD: $(pwd)" | tee -a install-debug-v3.log
echo "Running on: $(uname -a)" | tee -a install-debug-v3.log
echo "User: $(whoami)" | tee -a install-debug-v3.log
echo "" | tee -a install-debug-v3.log

# Check critical conditions
echo "[DEBUG V3] Checking environment..." | tee -a install-debug-v3.log
echo "[DEBUG V3] Arch Linux check: $([ -f /etc/arch-release ] && echo 'YES (/etc/arch-release exists)' || echo 'NO (/etc/arch-release NOT found)')" | tee -a install-debug-v3.log
echo "[DEBUG V3] hyprctl available: $(command -v hyprctl &>/dev/null && echo 'YES' || echo 'NO')" | tee -a install-debug-v3.log
echo "[DEBUG V3] Shell: $SHELL" | tee -a install-debug-v3.log
echo "" | tee -a install-debug-v3.log

# Now let's trace the actual install.sh execution
echo "[DEBUG V3] Running install.sh with bash -x..." | tee -a install-debug-v3.log
echo "[DEBUG V3] This will show every command executed..." | tee -a install-debug-v3.log
echo "" | tee -a install-debug-v3.log

# Run install.sh with full tracing and capture to log
bash -x ./install.sh 2>&1 | tee -a install-debug-v3.log

echo "" | tee -a install-debug-v3.log
echo "[DEBUG V3] install.sh execution completed (or exited)" | tee -a install-debug-v3.log
echo "[DEBUG V3] Exit code: $?" | tee -a install-debug-v3.log
echo "=== DEBUG V3 LOG SAVED TO: install-debug-v3.log ===" | tee -a install-debug-v3.log
