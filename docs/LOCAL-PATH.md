# Local Path Provisioner

Local Path Provisioner is an RKE2 development StorageClass meant to be used on development environments. This StorageClass is not recommended for production deployments nor environments where multi-node, high-availability and/or redundancy are requirements.

Local Path Provisioner can still be useful if paired with an operator with built-in persistence and backup capabilities, like [MySQL](https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-backups.html), and/or a disaster recovery/backup system, like [Velero](https://velero.io/docs/). Cron-jobs can also be scheduled to provide node or disk-level backups to outside services, like AWS S3, or storage hardware, like an external HDD.

## Usage

### Pre-Requisites

#### Node Configuration

Node-level storage configurations are set within the [storage configuration values file](../packages/local-path/values/storage-configuration-values.yaml). The instructions for filling out the values file are within the values file. The default Zarf package expects a mounted location of `/opt/uds/` on all nodes, allowing for `ReadWriteMany` and `ReadOnlyMany` across all nodes.

When modifying or supplying a storage-configuration-values.yaml, please note that `nodePathMap` and `sharedFileSystemPath` are mutually exclusive. If `sharedFileSystemPath` is used, then `nodePathMap` must be set to `[]`.

The following are the general node-level configuration rules and information for each type of storage configuration:

1. **`nodePathMap`**: the place user can customize where to store the data on each node
    - If one node is not listed on the nodePathMap, and Kubernetes wants to create volume on it, the paths specified in
    DEFAULT_PATH_FOR_NON_LISTED_NODES will be used for provisioning.
    - If one node is listed on the nodePathMap, the specified paths will be used for provisioning.
        1. If one node is listed but with paths set to [], the provisioner will refuse to provision on this node.
        2. If more than one path was specified, the path would be chosen randomly when provisioning.
    - The configuration must obey following rules:
        1. A path must start with /, a.k.a an absolute path.
        2. Root directory (/) is prohibited.
        3. No duplicate paths allowed for one node.
        4. No duplicate node allowed.
        5. The path must not already be owned by a different system user

2. **`sharedFileSystemPath`**: allows the provisioner to use a filesystem that is mounted on all
    - nodes at the same time. In this case all access modes are supported: `ReadWriteOnce`,
    - `ReadOnlyMany` and `ReadWriteMany` for storage claims. In addition
    - `volumeBindingMode: Immediate` can be used in  StorageClass definition.

#### Storage Configuration

Ensure that the local volume mount points are accessible to the cluster. For example, the default mount point for all nodes is `/opt/uds`, which means your storage devices, logical or physical, must be mounted at point `/opt/uds` on that node. An example of a logical volume mount is as follows:

```bash
# mount the device to an existing filepath
sudo mount ubuntu/vg/extra /opt/uds

# change permissions to the nonroot or nobody user for local storage volume creation
sudo chown -Rv 65534:65534 /opt/uds
```

Issues with the mount or filesystem in general will be recorded in a `local-path-storage` helper pod within the cluster during PV provisioning.

### Zarf Package

The UDS bundle and custom Zarf Init for each flavor of the UDS RKE2 bootstrap automatically instantiates the StorageClass, Persistent Volumes, and configurations automatically. Configuration is controlled by exposed Zarf variables that modify the custom Local Path Provisioner charts.

Further customization and configurations can be found in the resources located within the [Additional Info](#additional-info) section.

### Manual Upstream

If you are installing the cluster manually Zarf package by Zarf package, you can opt to perform the installation of the Local Path Provisioner using the following:

```bash
alias k="uds zarf tools kubectl"

# Install the stable version of the Local Path Provisioner
k apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml

# Set the Local Path Provisioner storage class as the default storage class:
k patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Check the status and resources of `local-path-provisioner`
k -n kube-system get pods -l app=local-path-provisioner
k -n local-path-storage logs -f -l app=local-path-provisioner # get <pod-name>
k -n local-path-storage get pods <pod-name> -o yaml
k get storageclass local-path -o yaml

# Uninstall
k delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
```

Further customization and configurations can be found in the resources located within the [Additional Info](#additional-info) section.

## Additional Info

- [Local Path Provisioner Repository](https://github.com/rancher/local-path-provisioner)
- [Host Path Information](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath)
- [Local Store Information](https://kubernetes.io/docs/concepts/storage/volumes/#local)
- [The Difference Between `hostPath` and `local`](https://stackoverflow.com/a/63492933)
