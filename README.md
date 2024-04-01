# UDS RKE2 Environment

> [!IMPORTANT]
> This is an unofficial sandbox repository for developing and testing a UDS RKE2 capability. Please go to the defenseunicorns organization for official UDS capabilities.

This zarf package serves as a universal dev (local & remote) and test environment for testing [UDS Core](https://github.com/defenseunicorns/uds-core), invidual UDS Capabilities, and UDS capabilities aggregated via the [UDS CLI](https://github.com/defenseunicorns/uds-cli).

## Prerequisites

- [UDS cli](https://github.com/defenseunicorns/uds-cli/blob/main/README.md#install) using the versions specified in the [uds-common repo](https://github.com/defenseunicorns/uds-common/blob/main/README.md#supported-tool-versions)
- [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/getting-started/installation) for running building and pulling images
- See the RKE2 documentation for host system [pre-requisites](https://docs.rke2.io/install/requirements)

## Deploy

<!-- x-release-please-start-version -->

`uds zarf package deploy oci://justinthelaw/uds-rke2-sandbox:0.1.0`

<!-- x-release-please-end -->

## Create

This package is published via CI, but can be created locally with the following command:

`uds zarf package create`

## Remove

TODO: Write an automated cluster removal script

## Additional Info

TODO: Add advanced node networking and security configurations

### Setup Virtual Machine Sandbox

- [Ubuntu VM with NVIDIA GPU Passthrough](docs/vm/README.md)

### Configure MinIO

- [Configuring Minio](docs/MINIO.md)

### DNS Assumptions

- [DNS Assumptions](docs/DNS.md)
