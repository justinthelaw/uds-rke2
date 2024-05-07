#!/bin/bash

set -e

# Run RKE2 install script - https://docs.rke2.io/install/airgap#rke2-installsh-script-install
cd /root/uds-rke2-artifacts/install/ && chmod +x install.sh
INSTALL_RKE2_ARTIFACT_PATH=/root/uds-rke2-artifacts/install ./install.sh