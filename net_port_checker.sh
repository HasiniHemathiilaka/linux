#!/usr/bin/env bash

# ==========================================================
# Network Connectivity & Open Port Auditor
# Description: Validates network reachability, DNS lookup,
#              and audits listening local ports.
# ==========================================================

set -euo pipefail

# Target hosts for testing connectivity
TARGET_HOSTS=("8.8.8.8" "google.com")

echo "=================================================="
echo "          NETWORK & PORT AUDIT TOOL               "
echo "=================================================="

# 1. Check local IP configuration
echo -e "\n[+] Local IP Configuration:"
if command -v hostname &> /dev/null; then
    hostname -I 2>/dev/null || echo "Host: $(hostname)"
else
    echo "Hostname utility not available."
fi

# 2. Test ping / latency to external targets
echo -e "\n[+] Testing Network Reachability:"
for TARGET in "${TARGET_HOSTS[@]}"; do
    if ping -c 2 -W 2 "$TARGET" &> /dev/null; then
        echo "  [✓] Connection to $TARGET: Reachable"
    else
        echo "  [✗] Connection to $TARGET: Unreachable"
    fi
done

# 3. DNS Resolution check
echo -e "\n[+] Testing DNS Resolution (google.com):"
if command -v getent &> /dev/null; then
    DNS_IP=$(getent hosts google.com | awk '{ print $1 }' | head -n 1)
    echo "  [✓] Resolved google.com -> $DNS_IP"
else
    echo "  [!] getent command not found, skipping DNS test."
fi

# 4. Check active listening ports (TCP/UDP)
echo -e "\n[+] Listening Ports (Active Sockets):"
if command -v ss &> /dev/null; then
    ss -tuln | awk 'NR<=10 {print $1, $2, $5}'
elif command -v netstat &> /dev/null; then
    netstat -tuln | awk 'NR<=10 {print $1, $4}'
else
    echo "  [!] Neither 'ss' nor 'netstat' available to query sockets."
fi

echo -e "\n=================================================="
echo "                 AUDIT COMPLETE                   "
echo "=================================================="