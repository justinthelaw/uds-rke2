# UDS RKE2 Infrastructure and Exemptions

This document extends the [RKE2 configuration documentation](./RKE2.md) and provides more context on the UDS RKE2-specific packages, including the [`uds-rke2/exemptions`](../packages/uds-rke2/exemptions/zarf.yaml) and [`uds-rke2/infrastructure`](../packages/uds-rke2/infrastructure/zarf.yaml) Zarf packages.

## Infrastructure

This package deploys MetalLB and MachineID + Pause for L2 advertisement and pod/namespace integrity, respectively.

L2 advertisement requires the network interface and IP address pool. These are supplied via variables as seen in the [Zarf package deployment](../packages/uds-rke2/infrastructure/zarf.yaml) or UDS bundle deployment ([`local-path-core` bundle configuration example](../bundles/dev/local-path-core/uds-config.yaml)) manifests.

To find the interface you would like to advertise on, use `ifconfig` and identify the local network-facing interface. An example network interface is `eth0` when advertising to the local network via `192.168.x.x`.

### MetalLB

The defaults for MetalLB L2 advertisement are set within the [UDS Infrastructure Zarf Package](../packages/uds-rke2/infrastructure/zarf.yaml) as Zarf variables. These can be influenced via `--set` if deploying the Zarf package standalone, or by using a `uds-config.yaml` that contains the Zarf variables under the `infrastructure` field.

`BASE_IP` is set using an automated process that extracts the server node's base IP; however, this can be manually overridden pre- or post-deployment via the [metallb-l2-values file](../packages/uds-rke2/infrastructure/values/metallb-l2-values.yaml).

If IP reservations for L2 advertisement contain skips, you can specify whether a service or gateway grabs a specific IP via an annotation. An example is below:

```yaml
# Example istio-admin-gateway service
apiVersion: v1
kind: Service
metadata:
  annotations:
    metallb.universe.tf/loadBalancerIPs: "192.168.1.100"  # Add annotation and replace with your desired IP
```

If you must use only specific IPs (e.g., 192.168.1.100, 192.168.1.105, and 192.168.1.110), you must modify the `ipaddresspool` CR to contain full CIDR addresses. An example is below:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ip-address-pool
  namespace: uds-rke2-infrastructure
spec:
  addresses:
  - 192.168.1.100/32
  - 192.168.1.105/32
  - 192.168.1.110/32
```

## Exemptions

This package contains exemptions from UDS Pepr policies that enforce prohibitive restrictions on storage layer and cluster-level functionality. Below are optional components that can be deployed with the `--components` flag. These are based on the storage layer flavor chosen for the custom Zarf Init.

- `local-path-exemptions`
- `longhorn-exemptions`
- `rook-ceph-exemptions`

Please see the [UDS exemptions documentation](https://github.com/defenseunicorns/uds-core/blob/main/docs/CONFIGURE_POLICY_EXEMPTIONS.md) for more details on implementation.
