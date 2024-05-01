# Custom Zarf Init

The custom Zarf init package comes with MinIO, for its feature-rich S3-compatible API, and Rook-Ceph as the backing S3-compatible object storage solution.

## Order of Deployment

1. A Zarf seed registry, and its contents, are bootstrapped (persistent volume) to the host file system
2. Rook-Ceph is deployed and configured to provide block, file, and object storage classes
3. Zarf seed registry contents to pushed permanent Zarf docker registry, which is now bound to the newly deployed Rook-Ceph storage class
4. MinIO is deployed and configured to provide an S3-like API layer on top of Rook-Ceph's object storage class

## Pre-Requisites

1. A properly configured host node (`Ubuntu 20.04`) is bootstrapped with an RKE2 cluster, and has at least 1 server node - this is done using the [UDS RKE2 Zarf package](../packages/uds-rke2/zarf.yaml).

2. All of the host nod's required dependencies, as listed below, are setup using [`install-deps.sh`](../packages/rook-ceph/scripts/install-deps.sh). In particular rook-ceph requires the following:
    1. LVM2
    2. Ceph Common

## Create

The below is used to manually create the custom Zarf init package, which is usually done with the UDS RKE2 [standard](../bundles/rke2-standard/uds-bundle.yaml) or [slim](../bundles/rke2-slim/uds-bundle.yaml).

```bash
# Login to registry1
set +o history
export REGISTRY1_USERNAME="YOUR-USERNAME-HERE"
export REGISTRY1_PASSWORD="YOUR-PASSWORD-HERE"
echo $REGISTRY1_PASSWORD | zarf tools registry login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin
set -o history

# Create the zarf init package
zarf package create --architecture amd64 --confirm --set AGENT_IMAGE_TAG=$(zarf version)
```
