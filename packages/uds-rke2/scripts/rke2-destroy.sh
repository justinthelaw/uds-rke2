#!/bin/bash

set -e

# Check if RKE2 is installed
if ! command -v rke2 &>/dev/null; then
	echo "RKE2 is not installed on the host. Nothing to destroy."
	exit 0
fi

echo ""
echo "*******************************************"
echo "** WARNING: This DESTROYS your RKE2 node **"
echo "*******************************************"
echo ""
echo "*******************************************"
echo "***** WARNING: Press Ctrl-C to cancel *****"
echo "*******************************************"
echo ""

sleep 5

echo "Killing the current RKE2 node's processes..."
rke2-killall.sh

echo "Destroying the current node's RKE2 install..."
rke2-uninstall.sh

echo "Removing all remaining RKE2 artifacts..."
rm -rf /root/rke2-startup.sh /root/uds-rke2-artifacts/install/

echo "Successfully removed the RKE2 node's processes and installation!"
exit 0
