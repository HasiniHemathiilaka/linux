#!/usr/bin/env bash

# ==========================================================
# Service & Process Watchdog Script
# Description: Checks if critical processes are active,
#              logs health status, and tracks CPU/Memory usage.
# ==========================================================

# Exit immediately if a command fails
set -euo pipefail

# Configuration
LOG_FILE="./watchdog.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# List of critical processes to monitor (add/remove as needed)
TARGET_SERVICES=("sshd" "cron" "bash")

log_message() {
    local LEVEL="$1"
    local MESSAGE="$2"
    echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" | tee -a "$LOG_FILE"
}

check_service() {
    local SERVICE_NAME="$1"

    if pgrep -x "$SERVICE_NAME" > /dev/null; then
        # Fetch PID, CPU%, and Memory%
        local STATS
        STATS=$(ps -C "$SERVICE_NAME" -o pid,%cpu,%mem --no-headers | head -n 1)
        log_message "INFO" "Service '$SERVICE_NAME' is RUNNING -> (PID CPU% MEM%): $STATS"
    else
        log_message "WARN" "Service '$SERVICE_NAME' is NOT running!"
    fi
}

# --- Script Execution ---
echo "=================================================="
echo "           STARTING WATCHDOG AUDIT                "
echo "=================================================="

log_message "INFO" "Watchdog check initiated by user: $(whoami)"

for SERVICE in "${TARGET_SERVICES[@]}"; do
    check_service "$SERVICE"
done

# System Resource Summary
TOTAL_TASKS=$(ps -e --no-headers | wc -l)
log_message "INFO" "Total active processes on system: $TOTAL_TASKS"

echo "=================================================="
echo "Audit complete. Detailed logs written to: $LOG_FILE"
echo "=================================================="