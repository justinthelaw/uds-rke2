#!/bin/bash

set -e

# Flush all IP table rules
iptables -F
ip6tables -F

# Reset to the default IP table rules
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT

# Restart the NetworkManager for changes to take effect
systemctl restart NetworkManager
