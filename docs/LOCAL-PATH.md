# Local Path Provisioner

Local Path Provisioner is an RKE2 development Storage Class meant to be used on development environments. This storage class is not recommended for production deployments nor environments where multi-node, high-availability and/or redundancy are requirements.

Local Path Provisioner can still be useful if paired with an operator with built-in persistence and backup capabilities, like [MySQL](https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-backups.html), and/or a disaster recovery/backup system, like [Velero](https://velero.io/docs/).

## Usage

The UDS bundle and custom Zarf Init for each flavor of the UDS RKE2 bootstrap automatically instantiates the associated resources and StorageClass automatically. If you are installing the cluster manually Zarf package by Zarf package, you can opt to perform the installation of the Local Path Provisioner using the following:

```bash
# Install the stable version of the Local Path Provisioner
uds zarf tools kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml

# Set the Local Path Provisioner storage class as the default storage class:
uds zarf tools kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Uninstall
uds zarf tools kubectl delete -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.26/deploy/local-path-storage.yaml
```

Further customization of the StorageClass and instantiations of PVs or PVCs can be found in [Additional Info](#additional-info) section.

## Additional Info

- [Local Path Provisioner Repository](https://github.com/rancher/local-path-provisioner)
