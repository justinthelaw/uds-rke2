# Development

> [!IMPORTANT]
> This entire repository assumes that you have root access, and all scripts and actions are run as root. Use `sudo su` to activate a root shell.

The purpose of this document is to describe how to run a development loop on the tech stack, using the `local-path` flavored bundle.

## Contributing

The [CONTRIBUTING.md](../.github/CONTRIBUTING.md) is the source of truth for actions to be performed prior to committing to a branch in the repository. Read that first before following the rest of this guide.

### Local Development

The following are requirements for building images locally for development and testing.

- All pre-requisites listed in the `Deployment` section of the [README.md](../README.md)
- [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/getting-started/installation) for running, building, and pulling images

## UDS CLI Aliasing

Below are instructions for adding UDS CLI aliases that are useful for deployments that occur in an air-gap with only the UDS CLI binary available to the delivery engineer.

For general CLI UX, put the following in your shell configuration (e.g., `/root/.bashrc`):

```bash
alias k="uds zarf tools kubectl"
alias kubectl="uds zarf tools kubectl"
alias zarf='uds zarf'
alias k9s='uds zarf tools monitor'
alias udsclean="uds zarf tools clear-cache && rm -rf ~/.uds-cache && rm -rf /tmp/zarf-*"
```

For fulfilling `xargs` and `kubectl` binary requirements necessary for running some of the _optional_ deployment helper scripts and for full functionality within `uds zarf tools monitor`:

```bash
touch /usr/local/bin/kubectl
echo -e '#!/bin/bash\nuds zarf tools kubectl "$@"' > /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
```

## Tasks

Task files contain `variables` that are passed throughout the files, and affect deploy-time variables that configure the values (and therefore, Helm charts) of the services or applications being deployed.

Individual may also contain `inputs`, which means they are supposed to be a re-useable sub-task meant to be consumed by another task. These tasks with inputs cannot be used unless they are consumed by a a parent task that provides the required inputs.

Run the following to see all the tasks in the "root" [`tasks.yaml`](./tasks.yaml), and their descriptions:

```bash
uds run --list-all
```

In the following sub-sections, we dive into each of the sub-task files and types, and provide examples for each. In the next sections, [Bundle Development](#bundle-development) and [Package Development](#package-development), the instructions for how to use UDS tasks to perform full dev-loops on UDS RKE2 bundles and packages are detailed.

### Deploy

> [!NOTE]
> The pre-deployment setup of the host machine is storage solution-dependent, so be sure to check the documentation for the package flavor you are deploying: [`local-path`](./docs/LOCAL-PATH.md), [`longhorn`](./docs/LONGHORN.md), or [`rook-ceph`](./docs/ROOK-CEPH.md).

See the UDS [`deploy` tasks](./tasks/deploy.yaml) file for more details.

For example, to deploy the UDS RKE2 bootstrap bundle with `local-path` flavor, do the following:

```bash
# create and deploy the local dev version, with /opt/uds as the PV mount, and
# the network interface for L2 advertisement on eth0
uds run uds-rke2-local-path-core-dev --set NETWORK_INTERFACE=eth0

# below are examples of dev version deployments of optional packages
uds run deploy:leapfrogai-workarounds --set VERSION=dev
uds run deploy:nvidia-gpu-operator --set VERSION=dev
```

### Create

See the UDS [`create` tasks](./tasks/create.yaml) file for more details.

To create individual packages and bundles, reference the following example for NVIDIA GPU Operator:

```bash
# create the local dev version of the Zarf package
uds run create:nvidia-gpu-operator --set VERSION=dev
```

### Publish

See the UDS [`publish` tasks](./tasks/publish.yaml) file for more details. Also see the `release` task in the main [`tasks.yaml`](./tasks.yaml).

To publish all packages and bundles, do the following:

```bash
# release all packages with a `dev` version
uds run release-dev
```

### Remove

Run the following to remove all Docker, Zarf and UDS artifacts from the host:

```bash
uds run setup:clean
```

Run the following to completely destroy the UDS RKE2 node and all of UDS RKE2's artifacts from the node's host:

```bash
uds run setup:uds-rke2-destroy
```

## Bundle Development

To build and deploy an ENTIRE bundle, use the tasks located in the `CREATE AND DEPLOY BUNDLES` section of the [tasks.yaml](../tasks.yaml). Be careful to note the difference between pulling the LATEST remote packages and bundle, and creating + deploying the local DEV versions of the packages and bundle.

If you have modified the deploy-time variables in a [uds-config.yaml](bundles/dev/local-path-core/uds-config.yaml), but none of the bundle components, and want to complete a re-deployment, you will need to run the TLS creation and injection step again:

```bash
# recreate the dev TLS certs and inject into the modified uds-config.yaml
uds run create-tls-local-path-dev

# deploy the pre-created UDS bundle with the modified uds-config.yaml
uds run deploy:local-path-core-bundle-dev
```

If you modified an individual package within the bundle, and want to do an integrated install again, you can just create the modified package again, and re-create the bundle:

```bash
# recreate the local-path-init package
uds run create:local-path-init --set VERSION=dev

# recreate the bundle and deploy
uds run create:local-path-core-bundle-dev
uds run deploy:local-path-core-bundle-dev
```

## Package Development

If you don't want to build an entire bundle, or you want to dev-loop on a single package in an existing, Zarf-init'd cluster, you can do so by performing a `uds zarf package remove [PACKAGE_NAME]` and re-deploying the package into the cluster.

To build a single package, use the tasks located in the `STANDARD PACKAGES`, `INIT PACKAGES`, or `APP-SPECIFIC PACKAGES` sections of the [create.yaml](../create.yaml). Be careful to note the difference between building the LATEST packages and creating + deploying the local DEV versions of the packages.

For example, this is how you build and deploy a local DEV version of a package:

```bash
# if package is already in the cluster, and you are deploying a new one
uds zarf package remove nvidia-gpu-operator --confirm

# create and deploy the new package
uds run create:nvidia-gpu-operator --set VERSION=dev
uds run deploy:nvidia-gpu-operator --set VERSION=dev
```

For example, this is how you pull and deploy a LATEST version of a package:

```bash
# pull and deploy latest versions
uds zarf package pull oci://ghcr.io/justinthelaw/packages/uds/uds-rke2/nvidia-gpu-operator:latest -a amd64
uds run deploy:nvidia-gpu-operator
```

## Airgap Testing

### Pre-Cluster/Node Bootstrapping

This sub-section is mainly for the pre-cluster or node bootstrapping steps, and targets the testing of the air-gapped bootstrapping of UDS RKE2 infrastructure.

You can use the [air-gapping script](./vm/scripts/airgap.sh) in the VM documentation directory to perform an IP tables manipulation to emulate an airgap. Modify the following lines, which allow local area network traffic, in the script based on your LAN configuration:

```bash
# Allow local network traffic - adjust to match your local network
iptables -A OUTPUT -d 192.168.1.0/24 -j ACCEPT
iptables -A OUTPUT -d 10.42.0.0/24 -j ACCEPT
```

To reverse this effect, just execute the [airgap reversion script](./vm/scripts/reverse-airgap.sh).

> [!CAUTION]
> Please note that the airgap reversion script flushes ALL existing rules, so modify the script or manually reset your IP table rules if the script does not work for your configuration.

### Post-Cluster/Node Bootstrapping

<!-- TODO: fill this in when Istio, MetalLB and CoreDNS air-gap in-cluster configurations are setup -->

## Troubleshooting

If your RKE2 cluster is failing to spin up in the first place, you can use `journalctl` to monitor the progress. Please note that it may take up to 10 minutes for the cluster spin-up and move on to the next step of the UDS RKE2 bundle deployment.

```bash
journalctl -xef -u rke2-server
```

Occasionally, a package you are trying to re-deploy, or a namespace you are trying to delete, may hang. To workaround this, be sure to check the events and logs of all resources, to include pods, deployments, daemonsets, clusterpolicies, etc. There may be finalizers, Pepr hooks, and etc. causing the re-deployment or deletion to fail. Use the `k9s` and `kubectl` tools that are vendored with UDS CLI, like in the examples below:

```bash
# k9s CLI for debugging
uds zarf tools monitor

# kubectl command for logs
uds zarf tools kubectl logs DaemonSet/metallb-speaker -n uds-rke2-infrastructure --follow
```

To describe node-level data, like resource usage, non-terminated pods, taints, etc. run the following command:

```bash
uds zarf tools kubectl describe node
```

To check which pods are sucking up GPUs in particular, you can run the following `yq` command:

```bash
uds zarf tools kubectl get pods \
--all-namespaces \
--output=yaml \
| uds zarf tools yq eval -o=json '
  ["Pod", "Namespace", "Container", "GPU"] as $header |
  [$header] + [
    .items[] |
    .metadata as $metadata |
    .spec.containers[] |
    select(.resources.requests["nvidia.com/gpu"]) |
    [
      $metadata.name,
      $metadata.namespace,
      .name,
      .resources.requests["nvidia.com/gpu"]
    ]
  ]' - \
| jq -r '(.[0] | @tsv), (.[1:][] | @tsv)' \
| column -t -s $'\t'
```
