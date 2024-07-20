> [!IMPORTANT]
> Rook-Ceph is meant for enterprise-grade, multi-node clusters. Rook-Ceph in a single-node configuration is not currently supported in this project; however, the single-node content and documentation will stay in this project in case of future work dedicated to providing a test and development deployment of Rook-Ceph. Additionally, the Rook-Ceph multi-node configuration within this repository is also experimental. Deploying UDS RKE2 Rook-Ceph may require further configuration and UDS bundle overrides.

# Rook-Ceph Configuration

Rook-Ceph is the block, object and file storage solution for the RKE2 cluster init. The Ceph Cluster and storage classes are deployed (`Ready` status) prior to the permanent Zarf Docker Registry is deployed in order to provide the PVC and PV a StorageClass in the cluster.

## Usage

### Flavors

There are two _pseudo_-flavors (Zarf Variable) of the Rook-Ceph deployment available for use when creating the Zarf package. One of the following flavors _**MUST**_ be set, using the `--set FLAVOR` flag, on create:

1. `single-node` (default): is used to deploy Rook-Ceph to clusters that are not prepared for high-availability or redundancy of the cluster's resources and pods (2 or less nodes). These values are described in [the single-node values file](../packages/rook-ceph/values/single-node-cluster-values.yaml).
2. `multi-node`: is used to deploy Rook-Ceph to clusters with 3 or more nodes that can handle a high-availability and redundancy deployment. These values are described in [the multi-node values file](../packages/rook-ceph/values/multi-node-cluster-values.yaml).

More details on the configurations and values available for modification or override can be found below:

- [Ceph configuration documentation](https://docs.ceph.com/en/latest/rados/configuration/)
- [Rook-Ceph Helm chart documentation](https://github.com/rook/rook/blob/master/Documentation/Helm-Charts/helm-charts.md)
- [Rook-Ceph Helm chart consolidated values file](https://github.com/rook/rook/blob/master/deploy/charts/rook-ceph-cluster/values.yaml)

### Instructions

Usage of the storage provided by Rook-Ceph is similar to any other storage class in Kubernetes. The default storage class will be configured to be `ceph-block`.

`ceph-block` provides standard (RWO) block storage for most applications and PVC needs. You can create a PVC with the `ceph-block` storage class.

`ceph-filesystem` is the RWX capability. By default, this is turned off in the [Ceph cluster common values file](../packages/rook-ceph/common/cluster-values-common.yaml) and [Operator values file](../packages/rook-ceph/values/operator-values.yaml). To use this class, you can modify the values files and create a PVC with the `ceph-filesystem` storage class.

For an S3 compatible bucket, you can create and apply an `ObjectBucketClaim` and an `ObjectUser` according to these [examples and instructions from Rook](https://github.com/rook/rook/blob/1af97d09a8ee9a4ab7d2631585b8853cd79b4ea4/Documentation/Getting-Started/example-configurations.md#object-storage).

For using the toolbox as a means to configure the Ceph cluster or use Ceph to manipulate your node, you can follow [Rook's example toolbox job manifest](https://github.com/rook/rook/blob/master/deploy/examples/toolbox-job.yaml).

## Upgrades

Regardless of which package you used for your initial deployment, upgrades of Rook-Ceph should _typically_ be done with the "standard" Zarf package, rather than using a new custom Zarf Init package. To upgrade simply deploy the new version of the standard package and Zarf will upgrade the necessary Rook-Ceph components that need modification. If you need to upgrade the Zarf components (agent, registry, git-server, etc) you can upgrade those with a newer version of the standard Zarf Init package (`oci://ghcr.io/defenseunicorns/packages/init:$(Zarf version)`). The custom init package should only be required for your first init of the cluster.

The "standard" Zarf package for Rook-Ceph can be created using the UDS task runner and should also be publicly available as a published package on this repository's packages list in GHCR.

## Remove

Removing the Rook-Ceph package is intentionally not "automatic" to prevent unintentional data loss. In order for the package to remove successfully there must be no storage pieces utilizing the Ceph storage (i.e. no PVCs, no buckets) existing in the cluster. Assuming you used the custom init your Zarf components must be removed (i.e. `zarf destroy`) prior to Rook-Ceph itself, which means you cannot use Zarf to remove Rook-Ceph.

The full cleanup process can be achieved by following the process in [the Rook docs](https://rook.io/docs/rook/v1.11/Getting-Started/ceph-teardown/). The below is an example of how to go through the deletion process to fully wipe data, which are also wrapped together as a [shell script](../packages/rook-ceph/scripts/rook-ceph-destroy.sh) with the exception of the Zarf Init and disk file removals:

1. Patch the cephcluster to ensure data is removed:

```bash
uds zarf tools kubectl -n rook-ceph patch cephcluster rook-ceph --type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
```

2. Cleanup user created PVCs and buckets, etc. - specific to your environment and usage.
3. Run the following `delete` and `patch` commands to remove the `rook-ceph` namespace and all Rook-Ceph resources from the cluster:

```bash
alias k="uds zarf tools kubectl"

# Begins termination process on all standard Kubernetes resources
k delete all --all -n rook-ceph
k delete secrets --all -n rook-ceph
k delete configmaps --all -n rook-ceph

# Removes hanging finalizers from most Rook-Ceph CRDs
for CRD in $(k get crd -n rook-ceph | awk '/ceph.rook.io/ {print $1}'); do k get -n rook-ceph "$CRD" -o name | xargs -I {} k patch -n rook-ceph {} --type merge -p '{"metadata":{"finalizers": []}}'; done

# Removes hanging finalizers from the disaster-proof finalizers
k -n rook-ceph patch configmap rook-ceph-mon-endpoints --type merge -p '{"metadata":{"finalizers": []}}'
k -n rook-ceph patch secrets rook-ceph-mon --type merge -p '{"metadata":{"finalizers": []}}'

# Check to see that all Rook-Ceph resources are done being terminated
k api-resources --verbs=list --namespaced -o name   | xargs -n 1 k get --show-kind --ignore-not-found -n rook-ceph

# Delete the entire `rook-ceph` namespace
k delete ns rook-ceph
```

4. Remove the Zarf Init package:

```bash
uds zarf destroy --confirm
```

5. Delete the data on hosts and zap disks following the [upstream guide](https://rook.io/docs/rook/v1.11/Getting-Started/ceph-teardown/#delete-the-data-on-hosts):

```bash
# remove persistent rook operator data
rm -rf /var/lib/rook/

# replace with the name of your actual disk being wiped and zapped
export DISK="/dev/ubuntu-vg/ceph"

# wiping operations based on the disk type
# use `blkdiscard $DISK` for direct block storage on SSDs
wipefs -a -f $DISK
sgdisk --zap-all $DISK
dd if=/dev/zero of="$DISK" bs=1M count=100 oflag=direct,dsync
partprobe $DISK
```

## Additional Info

- [Rook-Ceph Repository](https://github.com/rook/rook)
- [Rook-Ceph Documentation Website](https://rook.io/docs/rook/latest-release/Getting-Started/intro/)
- [Ceph Repository](https://github.com/ceph/ceph)
- [Ceph Documentation Website](https://docs.ceph.com/en/latest/dev/developer_guide/intro/)
