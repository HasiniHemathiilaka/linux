#!/usr/bin/env bash

# ==========================================================
# System Resource Threshold & Health Alert Script
# Description: Monitors CPU load, RAM usage, and disk capacity,
#              printing warnings when usage exceeds set limits.
# ==========================================================

set -euo pipefail

# Threshold limits in percent (%)
RAM_THRESHOLD=80
DISK_THRESHOLD=85

echo "=================================================="
echo "           SYSTEM THRESHOLD AUDIT                 "
echo "=================================================="

# 1. Check RAM usage
RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
RAM_PERCENT=$(( 100 * RAM_USED / RAM_TOTAL ))

echo "[+] Memory Usage: ${RAM_PERCENT}% (${RAM_USED}MB / ${RAM_TOTAL}MB)"
if [ "$RAM_PERCENT" -ge "$RAM_THRESHOLD" ]; then
    echo "  [!] WARNING: High Memory usage exceeds ${RAM_THRESHOLD}% threshold!"
else
    echo "  [✓] Memory status: Normal"
fi

# 2. Check Root Partition Disk Usage
DISK_PERCENT=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
echo -e "\n[+] Root Disk Usage: ${DISK_PERCENT}%"
if [ "$DISK_PERCENT" -ge "$DISK_THRESHOLD" ]; then
    echo "  [!] WARNING: Disk usage exceeds ${DISK_THRESHOLD}% threshold!"
else
    echo "  [✓] Disk status: Normal"
fi

# 3. Check CPU Load Averages (1 min, 5 min, 15 min)
echo -e "\n[+] CPU Load Average:"
if [ -f /proc/loadavg ]; then
    LOAD1=$(awk '{print $1}' /proc/loadavg)
    LOAD5=$(awk '{print $2}' /proc/loadavg)
    LOAD15=$(awk '{print $3}' /proc/loadavg)
    echo "  1-min: $LOAD1 | 5-min: $LOAD5 | 15-min: $LOAD15"
else
    uptime | awk -F'load average:' '{ print $2 }'
fi

# 4. Check Zombie Processes
ZOMBIE_COUNT=$(ps -eo stat | grep -c '^Z' || true)
echo -e "\n[+] Zombie Processes: $ZOMBIE_COUNT"
if [ "$ZOMBIE_COUNT" -gt 0 ]; then
    echo "  [!] WARNING: Detected $ZOMBIE_COUNT defunct/zombie process(es)!"
else
    echo "  [✓] No zombie processes found."
fi

echo "=================================================="
echo "             THRESHOLD CHECK DONE                 "
echo "=================================================="