#!/bin/bash
set -e

# Install dependencies and cli tools needed by other scripts
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

echo "Checking for required dependencies on the host..."

# Check for LVM2
if ! command -v lvm &>/dev/null; then
	echo "LVM2 is not installed. Installing LVM2..."
	apt-get install lvm2 -y
else
	echo "LVM2 is already installed."
fi

# Check for Ceph common
if ! command -v ceph &>/dev/null; then
	echo "Ceph common is not installed. Installing Ceph common..."
	apt-get install ceph-common -y
else
	echo "Ceph common is already installed."
fi

echo "All required dependencies are now installed."
