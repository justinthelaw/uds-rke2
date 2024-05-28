# UDS RKE2 Infrastructure and Exemptions

This is an extension of the [RKE2 configuration documentation](./RKE2.md), and provides more context on the UDS RKE2-specific packages, to include the [`uds-rke2/exemptions`](../packages/uds-rke2/exemptions/zarf.yaml) and [`uds-rke2/infrastructure`](../packages/uds-rke2/infrastructure/zarf.yaml) Zarf packages.

## Infrastructure

This package deploys MetalLB, Nginx, and a CoreDNS override, all of which are necessary for ingress/egress access to the cluster's services.

### DNS Assumptions

One of the core assumptions of the `uds-rke2` package is the use of `uds.prod` as the base domain for your production environment. This assumption is integral to the DNS and network configuration provided by the package. It is based on an existing DNS entry for `*.uds.prod` that resolves to `127.0.0.1`.

### CoreDNS Override

The package includes a CoreDNS configuration override designed to rewrite requests for `*.uds.prod` to `host.rke2.internal`. This rewrite ensures that any DNS resolution request within the cluster targeting a `*.uds.prod` address will be correctly routed to `host.rke2.internal` which is an internal rke2 alias that resolves to the host gateway.

The outcome of this is a pods in the cluster can resolve domains like sso.uds.prod to an address (not 127.0.0.1) that will ultimately get routed correctly.

### Nginx Configuration

Additionally, the package includes Nginx configuration that assumes the use of `uds.prod` as the base domain. This configuration is tailored to support the production environment setup, ensuring that Nginx correctly handles requests and routes them within the cluster, based on the `uds.prod` domain.

## Exemptions

This package contains exemptions from UDS Pepr policies that enforce prohibitive restrictions on storage layer and cluster-level functionality. Below are optional components that can be deployed with the `--components` flag. These are based on the storage layer flavor chosen for the custom Zarf Init.

- `local-path-exemptions`
- `longhorn-exemptions`
- `rook-ceph-exemptions`

Please see this [UDS exemptions documentation](https://github.com/defenseunicorns/uds-core/blob/main/docs/CONFIGURE_POLICY_EXEMPTIONS.md) for more details on implementation.
