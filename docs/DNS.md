# Domain Name Service (DNS)

## Domain Assumptions

One of the core assumptions of the `uds-rke2` package is the use of `uds.prod` as the base domain for your production environment. This assumption is integral to the DNS and network configuration provided by the package. It is based on an existing DNS entry for `*.uds.prod` that resolves to `127.0.0.1`.

### CoreDNS Override

The package includes a CoreDNS configuration override designed to rewrite requests for `*.uds.prod` to `host.rke2.internal`. This rewrite ensures that any DNS resolution request within the cluster targeting a `*.uds.prod` address will be correctly routed to `host.rke2.internal` which is an internal rke2 alias which resolves to the host gateway.

The outcome of this is a pods in the cluster can resolve domains like sso.uds.prod to an address (not 127.0.0.1) that will ultimately get routed correctly.

### Nginx Configuration

Additionally, the package includes Nginx configuration that assumes the use of `uds.prod` as the base domain. This configuration is tailored to support the production environment setup, ensuring that Nginx correctly handles requests and routes them within the cluster, based on the `uds.prod` domain.
