#!/bin/bash
set -e

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_message "Starting reverse airgap process..."

# Flush all IP table rules
log_message "Flushing all iptables rules..."
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

log_message "Flushing all ip6tables rules..."
ip6tables -F
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -X

# Reset to the default IP table policies
log_message "Resetting iptables policies to ACCEPT..."
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

log_message "Resetting ip6tables policies to ACCEPT..."
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

# Remove any persistent iptables rules if they exist
if [ -f /etc/iptables/rules.v4 ]; then
    log_message "Removing persistent IPv4 rules..."
    rm -f /etc/iptables/rules.v4
fi

if [ -f /etc/iptables/rules.v6 ]; then
    log_message "Removing persistent IPv6 rules..."
    rm -f /etc/iptables/rules.v6
fi

log_message "Reverse airgap process completed."