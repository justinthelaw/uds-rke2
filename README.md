# UDS RKE2 Environment

> [!IMPORTANT]
> This is an unofficial sandbox repository for developing and testing a UDS RKE2 capability. Please go to the [defenseunicorns](https://github.com/defenseunicorns) organization for official UDS capabilities.

This Zarf package serves as an air-gapped production environment for deploying [UDS Core](https://github.com/defenseunicorns/uds-core), individual UDS Capabilities, and UDS capabilities aggregated (bundled) via the [UDS CLI](https://github.com/defenseunicorns/uds-cli).

## Pre-Requisites

### Deployment Target

- A base installation of [Ubuntu Server 20.04+](https://ubuntu.com/download/server) on the node's host system
- [UDS CLI](https://github.com/defenseunicorns/uds-cli/blob/main/README.md#install) using the versions specified in the [UDS Common repository](https://github.com/defenseunicorns/uds-common/blob/main/README.md#supported-tool-versions)
- See the RKE2 documentation for host system [pre-requisites](https://docs.rke2.io/install/requirements)
- See the Rook-Ceph documentation for the host system [pre-requisites](https://rook.io/docs/rook/latest-release/Getting-Started/Prerequisites/prerequisites/) based on the node's role and the cluster's configurations

### UDS CLI Aliasing

Below are instructions for adding UDS CLI aliases that are useful for deployments that occur in an air-gap with only the UDS CLI binary available to the delivery engineer.

For general CLI UX, put the following in your shell configuration (e.g., `/root/.bashrc`):

```bash
alias k="uds zarf tools kubectl"
alias kubectl="uds zarf tools kubectl"
alias zarf='uds zarf'
alias k9s='uds zarf tools monitor'
alias udsclean="uds zarf tools clear-cache && rm -rf ~/.uds-cache && rm -rf ~/.zarf-cache && rm -rf /tmp/uds* && rm -rf /tmp/zarf-*"
```

For fulfilling `xargs` and `kubectl` binary requirements necessary for running some of the _optional_ deployment helper scripts:

```bash
touch /usr/local/bin/kubectl 
echo -e "#!/bin/bash\nuds zarf tools kubectl \"\$@\"" > /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
```

### Local Development

- All pre-requisites listed in [Deployment Target](#deployment-target)
- [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/getting-started/installation) for running, building, and pulling images

## Usage

### Virtual Machines

> [!CAUTION]
> Due to the the disk formatting operations, networking and STIG'ing configurations that are applied to a node's host, it is highly recommended that the contents of this repository are not directly installed on a personal machine.

The best way to test UDS RKE2 is to spin-up 1 or more nodes using virtual machines or networks.

[LeapfrogAI](https://github.com/defenseunicorns/leapfrogai), the main support target of this bundle, requires GPU passthrough to all worker nodes that will have a taint for attracting pods with GPU resource and workload requirements.

Please see the [VM setup documentation](./docs/VM.md) and VM setup scripts to learn more about manually creating development VM.

### Bundles

There are 3 main "flavors" of the UDS RKE2 Core bundle, with 4 distinct flavors in total. Each flavor revolves around the storage and persistence layer of the cluster, and comes with its own documentation on configuration and installation, as linked in the bulleted list below. Please refer to that documentation for more details on each bundle flavor's recommendations and capabilities.

1. [Local Path Provisioner](./docs/LOCAL-PATH.md) + [MinIO](./docs/MINIO.md)
2. [Longhorn](./docs/LONGHORN.md) + [MinIO](./docs/MINIO.md)
3. [Rook-Ceph](./docs/ROOK-CEPH.md)

### Create

<!-- TODO: create instructions -->

### Deploy

<!-- TODO: deploy instructions -->

### Remove

<!-- TODO: remove instructions -->

## Additional Info

Below are resources to explain some of the rationale and inner workings of the RKE2 cluster's infrastructure.

### Configuration

- [Operating System Configuration Scripts](docs/OS.md)
- [RKE2-Specific Configuration Scripts](docs/RKE2.md)
- [DNS Configuration and Assumptions](docs/DNS.md)
- [MinIO Configuration](docs/MINIO.md)
- [Rook-Ceph Configuration](docs/ROOK-CEPH.md)
- [Longhorn Configuration](docs/LONGHORN.md)
- [Local Path Provisioner](docs/LOCAL-PATH.md)
- [Custom Zarf Init](docs/INIT.md)

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
