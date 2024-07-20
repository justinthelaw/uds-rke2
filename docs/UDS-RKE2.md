# UDS RKE2 Infrastructure and Exemptions

This is an extension of the [RKE2 configuration documentation](./RKE2.md), and provides more context on the UDS RKE2-specific packages, to include the [`uds-rke2/exemptions`](../packages/uds-rke2/exemptions/zarf.yaml) and [`uds-rke2/infrastructure`](../packages/uds-rke2/infrastructure/zarf.yaml) Zarf packages.

## Infrastructure

This package deploys MetalLB and MachineID + Pause for L2 advertisement and pod/namespace integrity, respectively.

The L2 advertisement requires the network interface and IP address pool. These are supplied via variables seen in the [Zarf package deployment](../packages/uds-rke2/infrastructure/zarf.yaml) or UDS bundle deployment ([`local-path-core` bundle configuration example](../bundles/dev/local-path-core/uds-config.yaml)) manifests.

To find the interface that you would like to advertise on, use `ifconfig` and identify the local network-facing interface. An example network interface is `eth0`, when advertising to the local network via `192.168.x.x`.

## Exemptions

This package contains exemptions from UDS Pepr policies that enforce prohibitive restrictions on storage layer and cluster-level functionality. Below are optional components that can be deployed with the `--components` flag. These are based on the storage layer flavor chosen for the custom Zarf Init.

- `local-path-exemptions`
- `longhorn-exemptions`
- `rook-ceph-exemptions`

Please see this [UDS exemptions documentation](https://github.com/defenseunicorns/uds-core/blob/main/docs/CONFIGURE_POLICY_EXEMPTIONS.md) for more details on implementation.
