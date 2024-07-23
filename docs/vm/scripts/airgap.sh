#!/bin/bash
set -e

# Check if NETWORK_INTERFACES is set
if [ -z "$NETWORK_INTERFACES" ]; then
	echo "Error: NETWORK_INTERFACES environment variable is not set."
	exit 1
fi

# Get IP address and subnet for the specified interface
LOCAL_IP=$(ip -4 addr show $NETWORK_INTERFACES | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
if [ -z "$LOCAL_IP" ]; then
	echo "Error: Could not determine IP address for $NETWORK_INTERFACES"
	exit 1
fi

# Get IP address and subnet for the flannel interface
FLANNEL_IP=$(ip -4 addr show flannel.1 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+')
if [ -z "$FLANNEL_IP" ]; then
	echo "Warning: Could not determine IP address for flannel interface. Using default 10.42.0.0/24"
	FLANNEL_IP="10.42.0.0/24"
fi

# Set default policies
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT DROP

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH connections on port 22 from any IP address
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT

# Allow local network traffic
iptables -A OUTPUT -d $LOCAL_IP -j ACCEPT
iptables -A OUTPUT -d $FLANNEL_IP -j ACCEPT

# Repeat for IPv6
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT DROP
ip6tables -A OUTPUT -o lo -j ACCEPT
ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow IPv6 SSH connections on port 22 from any IP address
ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT
ip6tables -A OUTPUT -p tcp --sport 22 -j ACCEPT
