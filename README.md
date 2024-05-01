# UDS RKE2 Environment

> [!IMPORTANT]
> This is an unofficial sandbox repository for developing and testing a UDS RKE2 capability. Please go to the [defenseunicorns](https://github.com/defenseunicorns) organization for official UDS capabilities.

This Zarf package serves as an air-gapped production environment for deploying [UDS Core](https://github.com/defenseunicorns/uds-core), individual UDS Capabilities, and UDS capabilities aggregated (bundled) via the [UDS CLI](https://github.com/defenseunicorns/uds-cli).

## Prerequisites

### Deployment Target

- See the RKE2 documentation for host system [pre-requisites](https://docs.rke2.io/install/requirements)
- A base installation of [Ubuntu Server 20.04](https://ubuntu.com/download/server) on your host or in a VM
- [UDS CLI](https://github.com/defenseunicorns/uds-cli/blob/main/README.md#install) using the versions specified in the [UDS Common repository](https://github.com/defenseunicorns/uds-common/blob/main/README.md#supported-tool-versions)

#### Aliases for UDS CLI

Below are instructions for adding UDS CLI aliases that are useful for deployments.

For general CLI UX, put the following in your shell configuration (e.g., `/root/.bashrc`):

```bash
alias k="uds zarf tools kubectl"
alias kubectl="uds zarf tools kubectl"
alias zarf='uds zarf'
alias k9s='uds zarf tools monitor'
alias udsclean="uds zarf tools clear-cache && rm -rf ~/.uds-cache && rm -rf ~/.zarf-cache && rm -rf /tmp/uds* && rm -rf /tmp/zarf-*"
```

For fulfilling `xargs` and `kubectl` binary requirements necessary for running some of the _optional_ deployment helper scripts:

1. Create a new script file in a directory that's in the system-wide PATH, such as `/usr/local/bin`. You can name it `kubectl`:

```bash
sudo touch /usr/local/bin/kubectl
```

2. Open the new file in a text editor with root permissions and add the following:

```bash
#!/bin/bash
uds zarf tools kubectl "$@"
```

This script will pass all arguments (`"$@"`) to the `uds zarf tools kubectl` command.

3. Make the script executable:

```bash
sudo chmod +x /usr/local/bin/kubectl
```

### Local Development

- All pre-requisites listed in [Deployment Target](#deployment-target)
- [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/getting-started/installation) for running, building, and pulling images

## Create

<!-- TODO: create instructions -->

## Deploy

<!-- TODO: release-please setup -->
<!-- TODO: deploy instructions -->

## Remove

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
- [RKE2 Zarf Init](https://github.com/defenseunicorns/zarf-package-rke2-init)
- [Zarf Longhorn Init](https://github.com/defenseunicorns/zarf-init-longhorn)
- [UDS Rook-Ceph Capability](https://github.com/defenseunicorns/uds-capability-rook-ceph)
