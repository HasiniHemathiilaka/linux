#!/usr/bin/env bash

# ==========================================================
# Automated Disk Cleanup & Temporary File Purge Script
# Description: Cleans user/system temp directories, removes 
#              dangling log archives, and reports freed space.
# ==========================================================

set -euo pipefail

LOG_DIR="./logs"
TEMP_DIR="/tmp"
THRESHOLD_DAYS=7

echo "=================================================="
echo "          SYSTEM CLEANUP & MAINTENANCE            "
echo "=================================================="

# 1. Capture initial disk usage
BEFORE_SPACE=$(df -h / | awk 'NR==2 {print $4}')
echo "[+] Free space before cleanup: $BEFORE_SPACE"

# 2. Purge old log files older than THRESHOLD_DAYS
if [ -d "$LOG_DIR" ]; then
    echo "[+] Scanning for old logs in $LOG_DIR (older than $THRESHOLD_DAYS days)..."
    DELETED_LOGS=$(find "$LOG_DIR" -type f -name "*.log" -mtime +"$THRESHOLD_DAYS" -print -delete | wc -l)
    echo "[✓] Removed $DELETED_LOGS old log file(s)."
else
    echo "[!] Log directory $LOG_DIR not found. Skipping."
fi

# 3. Clean temporary files created by current user
echo "[+] Clearing stale temporary files from $TEMP_DIR..."
find "$TEMP_DIR" -user "$(whoami)" -type f -mtime +1 -delete 2>/dev/null || true

# 4. Clean package manager cache if running as root / with sudo available
if command -v apt-get &> /dev/null && [ "$EUID" -eq 0 ]; then
    echo "[+] Running apt autoremove and autoclean..."
    apt-get autoremove -y > /dev/null
    apt-get autoclean -y > /dev/null
    echo "[✓] Package cache cleaned."
fi

# 5. Capture final disk usage
AFTER_SPACE=$(df -h / | awk 'NR==2 {print $4}')
echo -e "\n[+] Free space after cleanup: $AFTER_SPACE"

echo "=================================================="
echo "               CLEANUP COMPLETED                  "
echo "=================================================="