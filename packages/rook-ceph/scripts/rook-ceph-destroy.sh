#!/bin/bash
set -e

echo ""
echo "********************************************************"
echo "*** WARNING: This will DESTROY node and cluster data ***"
echo "********************************************************"
echo ""
echo "********************************************************"
echo "****** WARNING: Press Ctrl-C to cancel operation *******"
echo "********************************************************"
echo ""

sleep 5

# Check if the rook-ceph namespace exists
if ! kubectl get namespace rook-ceph >/dev/null 2>&1; then
	echo "The rook-ceph namespace does not exist. Skipping further operations."
	exit 0
fi

# Patch manual confirmation for data destruction
kubectl -n rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'

# Removes hanging finalizers from the disaster-proof finalizers
kubectl -n rook-ceph patch configmap rook-ceph-mon-endpoints --type merge -p '{"metadata":{"finalizers": []}}'
kubectl -n rook-ceph patch secrets rook-ceph-mon --type merge -p '{"metadata":{"finalizers": []}}'

# Removes hanging finalizers from most Rook-Ceph CRDs
for CRD in $(kubectl get crd -n rook-ceph | awk '/ceph.rook.io/ {print $1}'); do
	kubectl get -n rook-ceph "$CRD" -o name | xargs -I {} kubectl patch -n rook-ceph {} --type merge -p '{"metadata":{"finalizers": []}}'
	kubectl delete crd $CRD
done

# Termination of all Rook-Ceph resources
kubectl delete all --all -n rook-ceph
kubectl delete secrets --all -n rook-ceph
kubectl delete configmaps --all -n rook-ceph

# Delete the entire `rook-ceph` namespace
kubectl delete ns rook-ceph

# Remove the remaining Rook-Ceph data on the host
if [ -b "$DISK_NAME" ]; then
    wipefs -a -f $DISK_NAME
    sgdisk --zap-all $DISK_NAME
    dd if=/dev/zero of="$DISK_NAME" bs=1M count=100 oflag=direct,dsync
    blkdiscard $DISK_NAME
    partprobe $DISK_NAME
else
    echo "The disk "$DISK_NAME" does not exist. Skipping wiping operations."
fi


rm -rf /var/lib/rook/
