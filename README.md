# UDS RKE2 Environment

**_Unicorn Delivery Service (UDS), Rancher Kubernetes Engine 2 (RKE2)_**

> [!IMPORTANT]
> This is an unofficial sandbox repository for developing and testing a UDS RKE2 capability. Please go to the [defenseunicorns](https://github.com/defenseunicorns) organization for official UDS capabilities.

This Zarf package serves as an air-gapped production environment for deploying [UDS Core](https://github.com/defenseunicorns/uds-core), individual UDS Capabilities, and UDS capabilities aggregated (bundled) via the [UDS CLI](https://github.com/defenseunicorns/uds-cli).

See the [UDS RKE2 Mermaid diagram](docs/DIAGRAM.md) for visual representations of the tech stack's components and order of operations.

## Table of Contents

1. [Pre-Requisites](#pre-requisites)
2. [Usage](#usage)
    - [Virtual Machines](#virtual-machines)
    - [Bundles](#bundles)
    - [Quick Start](#quick-start)
        - [Latest](#latest)
        - [Development](#development)
3. [Additional Info](#additional-info)

## Pre-Requisites

The following are requirements for an environment where a user is deploying UDS RKE2 and its custom components and applications.

- A base installation of [Ubuntu 20.04 or 22.04](https://ubuntu.com/download/server) on the node's host system (server or desktop)
- [UDS CLI](https://github.com/defenseunicorns/uds-cli/blob/main/README.md#install) using the versions specified in the [UDS Common repository](https://github.com/defenseunicorns/uds-common/blob/main/README.md#supported-tool-versions)
- See the RKE2 documentation for host system [pre-requisites](https://docs.rke2.io/install/requirements)
- See the [Application-Specific](#application-specific) and [Flavor-Specific Infrastructure](#flavor-specific-infrastructure) configuration sections for instruction on setup based on what is deployed atop UDS RKE2

## Usage

> [!IMPORTANT]
> This entire repository assumes that you have root access, and all scripts and actions are run as root. Use `sudo su` to activate a root shell.

This section provides minimal context and instructions for quickly deploying the base UDS RKE2 capability. See the [DEVELOPMENT.md](docs/DEVELOPMENT.md) for instructions on how to further develop UDS RKE2.

### Virtual Machines

> [!CAUTION]
> Due to the the disk formatting and mount operations, networking and STIG configurations that are applied to a node's host, it is highly recommended that the contents of this repository are not directly installed on a personal machine.

The best way to test UDS RKE2 is to spin-up one or more nodes using a containerized method, such as virtual machines or networks.

[LeapfrogAI](https://github.com/defenseunicorns/leapfrogai), the main support target of this bundle, requires GPU passthrough to all worker nodes that will have a taint for attracting pods with GPU resource and workload requirements.

Please see the [VM setup documentation](./docs/VM.md) and VM setup scripts to learn more about manually creating development VM..

### Bundles

There are 3 main "flavors" of the UDS RKE2 Core bundle, with 4 distinct flavors in total. Each flavor revolves around the storage and persistence layer of the cluster, and comes with its own documentation on configuration and installation, as linked in the bulleted list below. Please refer to that documentation for more details on each bundle flavor's recommendations and capabilities.

1. [Local Path Provisioner](./docs/LOCAL-PATH.md) + [MinIO](./docs/MINIO.md)
2. (WIP) [Longhorn](./docs/LONGHORN.md) + [MinIO](./docs/MINIO.md)
3. (WIP) [Rook-Ceph](./docs/ROOK-CEPH.md)

### Quick Start

The following are quick starts for the `local-path` flavored UDS RKE2 bundle. This does not include the optional NVIDIA GPU operator and LeapfrogAI workarounds Zarf packages.

#### Latest

1. Change directory to the bundle and deploy the bundle:

```bash
# use `ifconfig` to identify the NETWORK_INTERFACES for L2 advertisement
uds run uds-rke2-local-path-core --set NETWORK_INTERFACES="eth0" --set IP_ADDRESS_POOL="200, 201, 202, 203"
```

2. Modify your `/etc/hosts` according to your base IP on the Istio Tenant gateway

```bash
# /etc/hosts

192.168.0.200   keycloak.admin.uds.dev grafana.admin.uds.dev neuvector.admin.uds.dev
192.168.0.201   sso.uds.dev
```

#### Development

1. Login to GitHub Container Registry (GHCR) and [DoD's Registry1](https://registry1.dso.mil/):

```bash
# Login to GHCR
set +o history
export GHCR_USERNAME="YOUR-USERNAME-HERE"
export GHCR_PASSWORD="YOUR-PASSWORD-HERE"
echo $GHCR_PASSWORD | uds zarf tools registry login ghcr.io --username $GHCR_USERNAME --password-stdin
set -o history

# Login to Registry1
set +o history
export REGISTRY1_USERNAME="YOUR-USERNAME-HERE"
export REGISTRY1_PASSWORD="YOUR-PASSWORD-HERE"
echo $REGISTRY1_PASSWORD | uds zarf tools registry login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin
set -o history
```

2. Build all necessary packages and then create and deploy the bundle

```bash
# use `ifconfig` to identify the NETWORK_INTERFACES for L2 advertisement
uds run uds-rke2-local-path-core-dev --set NETWORK_INTERFACES="eth0" --set IP_ADDRESS_POOL="200, 201, 202, 203"
```

3. Modify your `/etc/hosts` according to your base IP on the Istio Tenant gateway

```bash
# /etc/hosts

192.168.0.200   keycloak.admin.uds.local grafana.admin.uds.local neuvector.admin.uds.local
192.168.0.201   sso.uds.local
```

## Additional Info

The following sub-sections outlines all of the configuration documentation, which includes additional information, optional Zarf packages, and customization options for each component of UDS RKE2.

### Base Infrastructure

- [Operating System](docs/OS.md)
- [RKE2-Specific](docs/RKE2.md)
- [UDS-RKE2 Infrastructure and Exemptions](docs/UDS-RKE2.md)
- [Hosts, DNS and TLS Configuration](docs/DNS-TLS.md)

### Flavor-Specific Infrastructure

- [Rook-Ceph](docs/ROOK-CEPH.md)
- [Longhorn](docs/LONGHORN.md)
- [Local Path Provisioner](docs/LOCAL-PATH.md)
- [Custom Zarf Init](docs/INIT.md)
- [MinIO](docs/MINIO.md)

### Application-Specific

- [UDS Core](UDS-CORE.md)
- [LeapfrogAI Workarounds](docs/LEAPFROGAI.md)
- [NVIDIA GPU Operator](docs/NVIDIA-GPU-OPERATOR.md)

### Virtual Machine Setup and Testing

- [Ubuntu VM with NVIDIA GPU Passthrough](docs/VM.md)

### Credits and Resources

- [Zarf](https://github.com/defenseunicorns/zarf)
- [UDS CLI](https://github.com/defenseunicorns/uds-cli)
- [UDS Common](https://github.com/defenseunicorns/uds-common)
- [UDS Core](https://github.com/defenseunicorns/uds-core)
- [UDS K3D](https://github.com/defenseunicorns/uds-k3d)
- [UDS RKE2 Image Builder](https://github.com/defenseunicorns/uds-rke2-image-builder)
- [Experimental UDS RKE2 Core Bundle](https://github.com/docandrew/uds-core-rke2)
- [RKE2 Zarf Init](https://github.com/defenseunicorns/zarf-package-rke2-init)
- [Zarf Longhorn Init](https://github.com/defenseunicorns/zarf-init-longhorn)
- [UDS Rook-Ceph Capability](https://github.com/defenseunicorns/uds-capability-rook-ceph)
- [UDS Nutanix SWF Bundle](https://github.com/defenseunicorns/uds-bundle-software-factory-nutanix/tree/main)
