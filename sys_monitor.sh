#!/bin/bash

# ==========================================================
# Linux System Monitoring & Maintenance Practice Script
# Author: Practice Lab
# ==========================================================

echo "=================================================="
echo "          SYSTEM INFORMATION & HEALTH             "
echo "=================================================="

# 1. Display Current Date & Time
echo -e "\n[+] Date and Time:"
date

# 2. Display System Uptime
echo -e "\n[+] System Uptime:"
uptime -p

# 3. Display Logged-in User and Hostname
echo -e "\n[+] Hostname & Active User:"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"

# 4. Display Memory (RAM) Usage
echo -e "\n[+] Memory Usage (MB):"
free -m

# 5. Display Disk Space Usage (Root Partition)
echo -e "\n[+] Disk Space Usage:"
df -h / | awk 'NR==1 || NR==2 {print $0}'

# 6. Display Top 5 Memory-Consuming Processes
echo -e "\n[+] Top 5 Memory-Consuming Processes:"
ps aux --sort=-%mem | awk 'NR<=6 {print $1, $2, $3, $4, $11}'

# 7. Check Internet / Network Connectivity
echo -e "\n[+] Checking Network Connectivity:"
if ping -c 1 google.com &> /dev/null; then
    echo "Status: Connected to the Internet"
else
    echo "Status: No Internet Connection"
fi

echo -e "\n=================================================="
echo "          SYSTEM HEALTH CHECK COMPLETED           "
echo "=================================================="