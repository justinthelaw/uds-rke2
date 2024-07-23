#!/bin/bash
set -e

echo "Adding host traffic rules for Ceph controllers"

# Get network interface
NETWORK_INTERFACES=$(ip route get 8.8.8.8 | awk 'NR==1 {print $5}')

# Get IP address and prefix length
IP_ADDRESS=$(ifconfig $NETWORK_INTERFACES | grep 'inet ' | awk '{print $2}')
NETMASK=$(ifconfig $NETWORK_INTERFACES | grep 'inet ' | awk '{print $4}')

# Adds rule for the Ceph traffic
iptables -A INPUT -i "$NETWORK_INTERFACES" -m multiport -p tcp -s $IP_ADDRESS/$NETMASK --dports 6789,3300,6800:7568 -j ACCEPT
