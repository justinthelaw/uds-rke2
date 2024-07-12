# Custom Zarf Init

<!-- TODO: renovate setup -->
**Supported Version**: v0.33.0

The custom Zarf init package comes with 3 flavors:

1. `local`: [Local Path Provisioner](./LOCAL-PATH.md) as the backing StorageClass with [MinIO](./MINIO.md) for its S3-compatible API
2. `longhorn`: [Longhorn](./LONGHORN.md) as the backing StorageClass with [MinIO](./MINIO.md) for its S3-compatible API
3. `rook`: [Rook-Ceph](./ROOK-CEPH.md) as a comprehensive block, object, and file StorageClass set with a built-in S3-compatible API

## Pre-Requisites

A properly configured host node (`Ubuntu 20.04`) is bootstrapped with an RKE2 cluster, and has at least 1 server node - this is done using the [UDS RKE2 Zarf package](../packages/uds-rke2/zarf.yaml).

## Create

The below is used to manually create the custom Zarf init package, which is usually done with [UDS tasks](../tasks.yaml) or the [UDS bundles](https://github.com/justinthelaw/uds-rke2/tree/main/bundles) in this repository.

```bash
# Create the zarf init package
uds zarf package create --architecture amd64 --confirm --set AGENT_IMAGE_TAG=$(zarf version)
```

## Additional Info

- [Zarf Repository](https://github.com/defenseunicorns/zarf)
- [Zarf Documentation Website](https://docs.zarf.dev/getting-started/)
- [Zarf Init Package](https://docs.zarf.dev/ref/init-package/)
