#!/bin/bash
set -e

# Setup RKE2 configuration files
CONFIG_DIR=/etc/rancher/rke2
CONFIG_FILE=$CONFIG_DIR/config.yaml
LOCAL_DIR=/root/uds-rke2-artifacts
mkdir -p $CONFIG_DIR

# Stage startup helper script
chmod +x $LOCAL_DIR/rke2-startup.sh
chown root:root $LOCAL_DIR/rke2-startup.sh

# Stage STIG config files
cp -f $LOCAL_DIR/rke2-config.yaml $CONFIG_FILE
chown -R root:root $CONFIG_FILE
cp -f $LOCAL_DIR/audit-policy.yaml $CONFIG_DIR/audit-policy.yaml
chown -R root:root $CONFIG_DIR/audit-policy.yaml
cp -f $LOCAL_DIR/default-pss.yaml $CONFIG_DIR/default-pss.yaml
chown -R root:root $CONFIG_DIR/default-pss.yaml

# Configure settings needed by CIS profile and add etcd user
sudo cp -f /usr/local/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
sudo systemctl restart systemd-sysctl

if id "etcd" >/dev/null 2>&1; then
	echo "etcd user already exists, modifying it..."
	sudo usermod -c "etcd user" -s /sbin/nologin -U etcd 2>/dev/null
else
	echo "Creating etcd user..."
	sudo useradd -r -c "etcd user" -s /sbin/nologin -M etcd -U
fi
