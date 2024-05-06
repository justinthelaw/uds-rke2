#!/bin/bash
set -e

# Install dependencies and cli tools needed by os-stig.sh
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

echo "Checking for required dependencies on the host..."

# Check for Ansible
if ! command -v ansible &>/dev/null; then
	echo "Ansible is not installed. Installing Ansible..."
	apt-add-repository ppa:ansible/ansible -y
	apt-get update -y && apt-get install ansible -y
else
	echo "Ansible is already installed."
fi

# Check for Unzip
if ! command -v unzip &>/dev/null; then
	echo "Unzip is not installed. Installing Unzip..."
	apt-get install unzip -y
else
	echo "Unzip is already installed."
fi

# Check for JQ
if ! command -v jq &>/dev/null; then
	echo "JQ is not installed. Installing JQ..."
	apt-get install jq -y
else
	echo "JQ is already installed."
fi

echo "All required dependencies are now installed."