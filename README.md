# UDS RKE2 Environment

**_Unicorn Delivery Service (UDS), Rancher Kubernetes Engine 2 (RKE2)_**

> [!IMPORTANT]
> This is an unofficial sandbox repository for developing and testing a UDS RKE2 capability. Please go to the [defenseunicorns](https://github.com/defenseunicorns) organization for official UDS capabilities.

This Zarf package serves as an air-gapped production environment for deploying [UDS Core](https://github.com/defenseunicorns/uds-core), individual UDS Capabilities, and UDS capabilities aggregated (bundled) via the [UDS CLI](https://github.com/defenseunicorns/uds-cli).

See the [UDS RKE2 Mermaid diagram](docs/DIAGRAM.md) for visual representations of the tech stack's components and order of operations.

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
alias udsclean="uds zarf tools clear-cache && rm -rf ~/.uds-cache && rm -rf /tmp/zarf-*"
```

For fulfilling `xargs` and `kubectl` binary requirements necessary for running some of the _optional_ deployment helper scripts:

```bash
touch /usr/local/bin/kubectl
echo '#!/bin/bash\nuds zarf tools kubectl "$@"' > /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
```

### Local Development

- All pre-requisites listed in [Deployment Target](#deployment-target)
- [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/getting-started/installation) for running, building, and pulling images

## Usage

### Virtual Machines

> [!CAUTION]
> Due to the the disk formatting operations, networking and STIG configurations that are applied to a node's host, it is highly recommended that the contents of this repository are not directly installed on a personal machine.

The best way to test UDS RKE2 is to spin-up one or more nodes using a containerized method, such as virtual machines or networks.

[LeapfrogAI](https://github.com/defenseunicorns/leapfrogai), the main support target of this bundle, requires GPU passthrough to all worker nodes that will have a taint for attracting pods with GPU resource and workload requirements.

Please see the [VM setup documentation](./docs/VM.md) and VM setup scripts to learn more about manually creating development VM.

VM setup may not be necessary if using Longhorn or Local Path Provisioner, but it is highly recommended when using Rook-Ceph.

### Bundles

There are 3 main "flavors" of the UDS RKE2 Core bundle, with 4 distinct flavors in total. Each flavor revolves around the storage and persistence layer of the cluster, and comes with its own documentation on configuration and installation, as linked in the bulleted list below. Please refer to that documentation for more details on each bundle flavor's recommendations and capabilities.

1. [Local Path Provisioner](./docs/LOCAL-PATH.md) + [MinIO](./docs/MINIO.md)
2. (WIP) [Longhorn](./docs/LONGHORN.md) + [MinIO](./docs/MINIO.md)
3. (WIP) [Rook-Ceph](./docs/ROOK-CEPH.md)

Each bundle can also be experimented with using the Zarf package creation and deployment commands via the UDS tasks outlined in the sections below.

### Packages

See the [Configuration section](#configuration) for more details on each specific package in each of the bundle flavors.

### UDS Tasks

This repository uses [UDS CLI](https://github.com/defenseunicorns/uds-cli)'s built-in [task runner](https://github.com/defenseunicorns/maru-runner) to perform all actions required to run, develop, and publish the UDS RKE2 tech stack.

Run the following to see all the tasks in the main [`tasks.yaml`](./tasks.yaml), and their descriptions:

```bash
uds run --list-all
```

#### Create

See the UDS [`create` tasks](./tasks/create.yaml) file for more details.

To create all packages and bundles, do the following:

```bash
# Login to Registry1 (bash)
set +o history
export REGISTRY1_USERNAME="YOUR-USERNAME-HERE"
export REGISTRY1_PASSWORD="YOUR-PASSWORD-HERE"
echo $REGISTRY1_PASSWORD | uds zarf tools registry login registry1.dso.mil --username $REGISTRY1_USERNAME --password-stdin
set -o history

# Login to ghcr (bash)
set +o history
export GHCR_USERNAME="YOUR-USERNAME-HERE"
export GHCR_PASSWORD="YOUR-PASSWORD-HERE"
echo $GHCR_PASSWORD | uds zarf tools registry login ghcr.io --username $GHCR_USERNAME --password-stdin
set -o history

uds run create:all
```

#### Deploy

> [!NOTE]
> The pre-deployment setup of the host machine is storage solution-dependent, so be sure to check the documentation for the package flavor you are deploying: [`local-path`](./docs/LOCAL-PATH.md), [`longhorn`](./docs/LONGHORN.md), or [`rook-ceph`](./docs/ROOK-CEPH.md).

See the UDS [`deploy` tasks](./tasks/deploy.yaml) file for more details.

For example, to deploy the UDS RKE2 bootstrap bundle with `local-path` flavor, do the following:

```bash
# create the /opt/uds directory on an existing mounted LVM
sudo mkdir /opt/uds

# change permissions to the nonroot or nobody user for local storage volume creation
sudo chown -Rv 65534:65534 /opt/uds

# deploy the local dev version
uds run uds-rke2-local-path-core-dev
```

Please note that the above steps vary from the original [`local-path`](./docs/LOCAL-PATH.md) instructions for simplicity sake.

#### Publish

See the UDS [`publish` tasks](./tasks/publish.yaml) file for more details. Also see the `release` task in the main [`tasks.yaml`](./tasks.yaml).

To publish all packages and bundles, do the following:

```bash
# Login to GHCR
set +o history
export GHCR_USERNAME="YOUR-USERNAME-HERE"
export GHCR_PASSWORD="YOUR-PASSWORD-HERE"
echo $GHCR_PASSWORD | zarf tools registry login ghcr.io --username $GHCR_USERNAME --password-stdin
set -o history

# if create:all was already run
uds run publish:all

# if create:all was not already run
uds run release
```

#### Remove

Run the following to remove all Docker, Zarf and UDS artifacts from the host:

```bash
uds run setup:clean
```

Run the following to completely destroy the UDS RKE2 node and all of UDS RKE2's artifacts from the node's host:

```bash
uds run setup:uds-rke2-destroy
```

#### Test

The GitHub CI workflow uses UDS tasks to run deployments of the package components within this repository, but not on the UDS Core components.

To run this test locally, you can run the following:

```bash
uds run uds-rke2-local-path-core-dev
```

Then, modify your `/etc/hosts` according to your base IP on the Istio Tenant gateway, with a redirect for `sso.local.uds.dev`.

Finally, go to `sso.local.uds.dev` to see if the KeyCloak SSO panel is accessible via your browser.

## Additional Info

Below are resources to explain some of the rationale and inner workings of the RKE2 cluster's infrastructure.

### Configuration

- [Operating System Configuration](docs/OS.md)
- [RKE2-Specific Configuration](docs/RKE2.md)
- [UDS-RKE2 Infrastructure and Exemptions](docs/UDS-RKE2.md)
- [MinIO Configuration](docs/MINIO.md)
- [Rook-Ceph Configuration](docs/ROOK-CEPH.md)
- [Longhorn Configuration](docs/LONGHORN.md)
- [Local Path Provisioner](docs/LOCAL-PATH.md)
- [Custom Zarf Init](docs/INIT.md)

### Application-Specific

- [UDS Core](UDS-CORE.md)
- [LeapfrogAI](docs/LEAPFROGAI.md)

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
