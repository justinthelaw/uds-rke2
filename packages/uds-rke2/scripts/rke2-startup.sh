#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Script must be run as root"
	exit 1
fi

if [ $# -eq 0 ]; then
	echo "No arguments provided to script, see RKE2.md docs for more details"
	exit 1
fi

while getopts "t:T:s:a" o; do
	case "${o}" in
	t) TOKEN=${OPTARG} ;;
	T) TLS_SANS=${OPTARG} ;;
	s) SERVER_HOST=${OPTARG} ;;
	a) AGENT=1 ;;
	*) exit 1 ;;
	esac
done

# Setup config file server, TOKEN, and TLS SANs
echo "Updating RKE2 Config file"

CONFIG_FILE=/etc/rancher/rke2/config.yaml
NODE_IP=$(ip route get $(ip route show 0.0.0.0/0 | grep -oP 'via \K\S+') | grep -oP 'src \K\S+')

if [ -n "${SERVER_HOST}" ] && [ "${SERVER_HOST}" != "" ]; then
	# Check if the "server:" key already exists in the config.yaml file
	if grep -q "^server:" "$CONFIG_FILE"; then
		# If the key exists, update the value
		sed -i "s#^server:.*#server: https://${SERVER_HOST}:9345#" "$CONFIG_FILE"
		echo "Updating Cluster Join Server IP: ${SERVER_HOST}"
	else
		# If the key doesn't exist, append the new line
		echo "server: https://${SERVER_HOST}:9345" >>"$CONFIG_FILE"
		echo "Adding Cluster Join Server IP: ${SERVER_HOST}"
	fi
fi

if [ -n "${TOKEN}" ] && [ "${TOKEN}" != "" ]; then
	# Check if the "token:" key already exists in the config.yaml file
	if grep -q "^token:" "$CONFIG_FILE"; then
		# If the key exists, update the value
		sed -i "s#^token:.*#token: ${TOKEN}#" "$CONFIG_FILE"
		echo "Updating Token"
	else
		# If the key doesn't exist, append the new line
		echo "token: ${TOKEN}" >>"$CONFIG_FILE"
		echo "Adding Token"
	fi
fi

if [ -n "${TLS_SANS}" ] && [ "${TLS_SANS}" != "" ]; then
	# Check if the "tls-san:" key already exists in the config.yaml file
	if grep -q "^tls-san:" "$CONFIG_FILE"; then
		# If the key exists, update the values
		sed -i "/^tls-san:/d" "$CONFIG_FILE"
		echo "tls-san:" >>"$CONFIG_FILE"
		for san in $TLS_SANS; do
			echo " - \"${san}\"" >>"$CONFIG_FILE"
		done
		echo "Updating TLS SANs"
	else
		# If the key doesn't exist, append the new lines
		echo "tls-san:" >>"$CONFIG_FILE"
		for san in $TLS_SANS; do
			echo " - \"${san}\"" >>"$CONFIG_FILE"
		done
		echo "Adding TLS SANs"
	fi
fi

# Workaround for upstream RKE2 and K3s containerd issue
mkdir -p /var/lib/rancher/rke2/agent/etc/containerd
cat <<EOF >/var/lib/rancher/rke2/agent/etc/containerd/config.toml.tmpl
version = 2

[plugins."io.containerd.internal.v1.opt"]
  path = "/var/lib/rancher/rke2/agent/containerd"

[plugins."io.containerd.grpc.v1.cri"]
  stream_server_address = "127.0.0.1"
  stream_server_port = "10010"
  enable_selinux = false
  enable_unprivileged_ports = true
  enable_unprivileged_icmp = true
  sandbox_image = "registry1.dso.mil/ironbank/opensource/pause/pause:3.9"

[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"
  disable_snapshot_annotations = true

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
	privileged_without_host_devices = false
	runtime_engine = ""
	runtime_root = ""
	runtime_type = "io.containerd.runc.v2"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
	BinaryName = "/usr/local/nvidia/toolkit/nvidia-container-runtime"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-experimental]
	privileged_without_host_devices = false
	runtime_engine = ""
	runtime_root = ""
	runtime_type = "io.containerd.runc.v2"

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-experimental.options]
	BinaryName = "/usr/local/nvidia/toolkit/nvidia-container-runtime-experimental"
EOF

# Start RKE2
echo "Starting RKE2 service"

if [ -z ${AGENT} ]; then
	systemctl enable rke2-server.service
	systemctl start rke2-server.service
else
	systemctl enable rke2-agent.service
	systemctl start rke2-agent.service
fi

# Ensure file permissions match STIG rules - https://www.stigviewer.com/stig/rancher_government_solutions_rke2/2022-10-13/finding/V-254564
echo "Fixing RKE2 file permissions for STIG"

# Need to await to ensure service creates these directories before we modify them for hardening purposes
DIR=/etc/rancher/rke2
while ! [ -d "$DIR" ]; do
	echo "Directory $DIR does not exist. Waiting for 5 seconds..."
	sleep 5
done
chmod -R 0600 $DIR/*
chown -R root:root $DIR/*

DIR=/var/lib/rancher/rke2
while ! [ -d "$DIR" ]; do
	echo "Directory $DIR does not exist. Waiting for 5 seconds..."
	sleep 5
done
chown root:root $DIR/*

DIR=/var/lib/rancher/rke2/agent
while ! [ -d "$DIR" ]; do
	echo "Directory $DIR does not exist. Waiting for 5 seconds..."
	sleep 5
done
chown root:root $DIR/*
chmod 0700 $DIR/pod-manifests
chmod 0700 $DIR/etc

find /var/lib/rancher/rke2 -maxdepth 1 -type f -name "*.kubeconfig" -exec chmod 0640 {} \;
find /var/lib/rancher/rke2 -maxdepth 1 -type f -name "*.crt" -exec chmod 0600 {} \;
find /var/lib/rancher/rke2 -maxdepth 1 -type f -name "*.key" -exec chmod 0600 {} \;

DIR=/var/lib/rancher/rke2/bin
while ! [ -d "$DIR" ]; do
	echo "Directory $DIR does not exist. Waiting for 5 seconds..."
	sleep 5
done
chown root:root $DIR/*
chmod 0750 $DIR/*

DIR=/var/lib/rancher/rke2/data
while ! [ -d "$DIR" ]; do
	echo "Directory $DIR does not exist. Waiting for 5 seconds..."
	sleep 5
done
chown root:root $DIR
chmod 0750 $DIR
chown root:root $DIR/*
chmod 0640 $DIR/*

DIR=/var/lib/rancher/rke2/server
while ! [ -d "$DIR" ]; do
	echo "Directory $DIR does not exist. Waiting for 5 seconds..."
	sleep 5
done
chown root:root $DIR/*
chmod 0700 $DIR/cred
chmod 0700 $DIR/db
chmod 0700 $DIR/tls
chmod 0751 $DIR/manifests
chmod 0750 $DIR/logs
chmod 0600 $DIR/token

# Set the user's kube context
echo "Setting KUBECONFIG for new RKE2 cluster"
mkdir -p /root/.kube/
cp /etc/rancher/rke2/rke2.yaml /root/.kube/config
