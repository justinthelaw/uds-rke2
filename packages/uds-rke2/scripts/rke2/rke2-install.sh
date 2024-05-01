#!/bin/bash

# TODO: air-gap this in conjunction with rke2-download.sh

set -e

if [ -z "$INSTALL_RKE2_VERSION" ]; then
	echo "Error: INSTALL_RKE2_VERSION is not set." >&2
	exit 1
fi

# Function to detect the installed RKE2 version
detect_rke2_version() {
	if command -v rke2 &>/dev/null; then
		echo "$(rke2 --version | awk '{print $3}' | awk 'NR==1')"
	else
		echo "not-installed"
	fi
}

# Get the installed RKE2 version
INSTALLED_RKE2_VERSION=$(detect_rke2_version)

if [ "$INSTALLED_RKE2_VERSION" != "not-installed" ] && [ "$INSTALLED_RKE2_VERSION" = "$INSTALL_RKE2_VERSION" ]; then
	echo "RKE2 version $INSTALLED_RKE2_VERSION is already installed. Skipping installation."
	exit 0
elif [ "$INSTALLED_RKE2_VERSION" = "not-installed" ]; then
	echo "RKE2 is not installed on this system. Proceeding with installation."
else
	echo "RKE2 version $INSTALLED_RKE2_VERSION is installed, but the desired version is $INSTALL_RKE2_VERSION. Proceeding with installation."
fi

# Get image artifacts - https://docs.rke2.io/install/airgap#tarball-method
mkdir -p /var/lib/rancher/rke2/agent/images/ && cd /var/lib/rancher/rke2/agent/images/
echo "Downloading rke2-images-core.linux-amd64.tar.zst..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2-images-core.linux-amd64.tar.zst"
echo "Downloading rke2-images-canal.linux-amd64.tar.zst..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2-images-canal.linux-amd64.tar.zst"

mkdir -p /root/uds-rke2-artifacts/install && cd /root/uds-rke2-artifacts/install/
echo "Downloading rke2-images.linux-amd64.tar.zst..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2-images.linux-amd64.tar.zst"
echo "Downloading rke2.linux-amd64.tar.gz..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/rke2.linux-amd64.tar.gz"
echo "Downloading sha256sum-amd64.txt..."
curl -LOs "https://github.com/rancher/rke2/releases/download/$INSTALL_RKE2_VERSION/sha256sum-amd64.txt"
curl -sfL https://get.rke2.io --output install.sh

# Run RKE2 install script - https://docs.rke2.io/install/airgap#rke2-installsh-script-install
cd /root/uds-rke2-artifacts/install/ && chmod +x install.sh
INSTALL_RKE2_ARTIFACT_PATH=/root/uds-rke2-artifacts/install ./install.sh
