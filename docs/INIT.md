# Custom Zarf Init

The custom Zarf init package comes with 3 flavors:

1. `local-path`: [Local Path Provisioner](./LOCAL-PATH.md) as the backing StorageClass with MinIO for its S3-compatible API
2. `longhorn`: [Longhorn](./LONGHORN.md) as the backing StorageClass with MinIO for its S3-compatible API
3. `rook-ceph`: [Rook-Ceph](./ROOK-CEPH.md) as a comprehensive block, object, and file StorageClass set with a built-in S3-compatible API

## Order of Deployment

1. A Zarf seed registry, and its contents, are bootstrapped (persistent volume) to the host file system
2. Rook-Ceph is deployed and configured to provide block, file, and object storage classes
3. Zarf seed registry contents to pushed permanent Zarf docker registry, which is now bound to the newly deployed Rook-Ceph storage class
4. MinIO is deployed and configured to provide an S3-like API layer on top of Rook-Ceph's object storage class

## Pre-Requisites

A properly configured host node (`Ubuntu 20.04`) is bootstrapped with an RKE2 cluster, and has at least 1 server node - this is done using the [UDS RKE2 Zarf package](../packages/uds-rke2/zarf.yaml).

## Create

The below is used to manually create the custom Zarf init package, which is usually done with [UDS tasks](../tasks.yaml) or the [UDS bundles](https://github.com/justinthelaw/uds-rke2/tree/main/bundles) in this repository.

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
