# Domain Name Service (DNS)

## Domain Assumptions

One of the core assumptions of the `uds-rke2` package is the use of `uds.prod` as the base domain for your production environment. This assumption is integral to the DNS and network configuration provided by the package. It is based on an existing DNS entry for `*.uds.dev` that resolves to `127.0.0.1`.

### CoreDNS Override

<!-- TODO: create configuration documentation -->

### Nginx Configuration

Additionally, the package includes Nginx configuration that assumes the use of `uds.prod` as the base domain. This configuration is tailored to support the production environment setup, ensuring that Nginx correctly handles requests and routes them within the cluster, based on the `uds.prod` domain.
