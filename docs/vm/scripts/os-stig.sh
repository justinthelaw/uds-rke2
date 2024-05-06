#!/bin/bash

set -e

# Check if the STIG enforcement script has already been executed
if [ -f "/root/.stig_applied" ]; then
	echo "STIG enforcement has already been applied. Skipping..."
	exit 0
fi

# Ensure that ansible collections needed are installed
ansible-galaxy collection install community.general --force
ansible-galaxy collection install ansible.posix --force

# Check if the STIG zip file has already been downloaded
if [ ! -f "/root/uds-rke2-artifacts/ansible.zip" ]; then
	# Pull Ansible STIGs from https://public.cyber.mil/stigs/supplemental-automation-content/
	# `curl` flag '-k' is used due to public.cyber.mil not having the correct SSL certificates
	# TODO: renovate setup
	curl -k -L -o /root/uds-rke2-artifacts/ansible.zip https://dl.dod.cyber.mil/wp-content/uploads/stigs/zip/U_CAN_Ubuntu_20-04_LTS_V1R11_STIG_Ansible.zip
else
	echo "STIG zip file already exists, skipping download."
fi

cd /root/uds-rke2-artifacts/

# Extract the STIG files
unzip ansible.zip
unzip *-ansible.zip
chmod +x enforce.sh

# Execute the STIG enforcement script
./enforce.sh

# Create a marker file to indicate that the STIG has been applied
touch /root/.stig_applied

# FIPS enabling - conditional for Ubuntu dependent on subscription
if [[ -n $UBUNTU_PRO_TOKEN ]]; then
	pro attach "$UBUNTU_PRO_TOKEN"
	if [[ $(pro status --format json | jq '.attached') == "true" ]]; then
		apt-get install ubuntu-advantage-tools -y
		pro enable fips-updates --assume-yes
		reboot
	fi
fi