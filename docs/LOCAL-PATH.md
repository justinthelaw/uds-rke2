# Local Path Provisioner

Local Path Provisioner is an RKE2 development StorageClass meant to be used on development environments. This StorageClass is not recommended for production deployments nor environments where multi-node, high-availability and/or redundancy are requirements.

Local Path Provisioner can still be useful if paired with an operator with built-in persistence and backup capabilities, like [MySQL](https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-backups.html), and/or a disaster recovery/backup system, like [Velero](https://velero.io/docs/). Cron-jobs can also be scheduled to provide node or disk-level backups to outside services, like AWS S3, or storage hardware, like an external HDD.

## Usage

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

# Check the status local-path-provisioner pods and namespace
k -n local-path-storage get pods -l app=local-path-provisioner
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
