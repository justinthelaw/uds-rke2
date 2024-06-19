# Air-gapped RKE2 Installation and Configuration

## RKE2 Install

The [RKE2 install script](../packages/uds-rke2/scripts/rke2/rke2-install.sh) installs RKE2, suitable for both server and agent nodes, following the upstream [RKE2 air-gapped install guide](https://docs.rke2.io/install/airgap). The basic steps involved in our current script involve:

- Staging image tarballs: Image tarballs are downloaded and placed in the correct location for usage in an airgap (see [here](https://docs.rke2.io/install/airgap#tarball-method))
- Run the RKE2 install script from upstream: This is pulled directly from RKE2 docs [here](https://docs.rke2.io/install/airgap#rke2-installsh-script-install)

## RKE2 Configuration

The [RKE2 Configuration script](../packages/uds-rke2/scripts/rke2/rke2-config.sh) adds configurations for spinning up the RKE2 cluster in the STIG'd environment. Additionally, it injects a [RKE2 Startup script](../packages/uds-rke2/scripts/rke2/configs/rke2-startup.sh) that allows for simple, initial cluster bootstrapping via CLI.

The final portion of the build copies a few files into the image and ensures they have proper ownership for usage at runtime. The [RKE2 STIG](https://www.stigviewer.com/stig/rancher_government_solutions_rke2/2022-10-13/) is the basis for these files. The files added are:

- An audit policy adhering to [this STIG rule](https://www.stigviewer.com/stig/rancher_government_solutions_rke2/2022-10-13/finding/V-254555)
- An RKE2 config file pre-configured to meet STIG rules (note that some STIG rules are met by default with RKE2 and not included in this configuration explicitly)
- A default pod security config - this allows full privileges for running pods and is added with the expectation that a policy enforcement engine like Kyverno or Gatekeeper is being used to restrict the same things, with exceptions as necessary
- A helper script for RKE2 startup - while RKE2 can certainly be run without this, this script can be used to add the RKE2 join address, token, and other properties to the RKE2 config file. It also corrects file permissions according to the STIG guide for files that do not exist until RKE2 startup has occurred.

Additionally the etcd user and a sysctl config are added for RKE2. This follows the process documented in the [RKE2 CIS Hardening guide](https://docs.rke2.io/security/hardening_guide#ensure-etcd-is-configured-properly).

Finally, configuration of the cluster's networking and default services is provided to allow the RKE2 cluster to be compatible or replaced with the components and services setup by [UDS Core](https://github.com/defenseunicorns/uds-core).

## RKE2 Startup

> [!IMPORTANT]  
> Due to an upstream error in RKE2 and K3s, containerd is misconfigured leading to image pull errors from 127.0.0.1 (local registry). Please see the [rke2-startup.sh](../packages/uds-rke2/scripts/rke2/configs/rke2-startup.sh) script for details, and the [containerd CRI docs](https://github.com/containerd/cri/blob/master/docs/config.md) for more details.

RKE2 provides excellent tooling to build an RKE2 cluster, but when considering the STIG guides for RKE2 and deploying via IaC there is additional runtime configuration required. The [RKE2 Startup script](../packages/uds-rke2/scripts/rke2/configs/rke2-startup.sh) injected during [OS preparation](./OS.md) is not required for startup, but it abstracts away some setup complexity.

### Script Parameters

This script provides a number of optional parameters depending on your desired configuration:

- `-t <token>`: RKE2 uses a secret token to join nodes to the cluster securely. This can be generated with something like openssl to create a secure random string.
- `-s <join address>`: RKE2 initializes on a "bootstrap" node. The '-s' argument is the IP address or hostname of the bootstrap node or cluster control plane and is used by new nodes to join the cluster. When this is either unset or matches the IP of the host RKE2 is being started on, RKE2 will initialize as the bootstrap node.
- `-a`: RKE2 has server or agent nodes. Agent nodes are Kubernetes worker nodes and do not host critical services like etcd or control-plane deployments.
- `-T <dns address>`: By default cluster generated certificate is only valid for the loopback address and private IPs it can find on interfaces. When accessing cluster from a hostname or public IP, they need to be provided so they can be added to the cluster certificate.

### Script Usage

This script should be run on each node with a minimum of 3 server nodes for an HA setup, plus additional agent nodes as needed. Ideally you should also setup load-balancing for server nodes (at minimum round-robin with DNS) so that a single node failure does not cause access issues.

An example setup is provided below:

- Node1: `/root/rke2-startup.sh -t <token> -s <node1_ip> -T <rke2_lb_address>`
- Node2: `/root/rke2-startup.sh -t <token> -s <rke2_lb_address> -T <rke2_dns_address>`
- Node3: `/root/rke2-startup.sh -t <token> -s <rke2_lb_address> -T <rke2_dns_address>`
- NodeN (agent nodes): `/root/rke2-startup.sh -t <token> -s <rke2_lb_address> -a`

## Additional Info

- [RKE2 Releases](https://github.com/rancher/rke2/releases)
- [RKE2 Air-Gap Install](https://docs.rke2.io/install/airgap#tarball-method)
- [RKE2 Installation Options](https://docs.rke2.io/install/methods)
- [RKE2 Configuration File](https://docs.rke2.io/install/configuration)
- [RKE2 High-Availability](https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke2-for-rancher)
- [RKE2 Repository](https://github.com/rancher/rke2)
- [RKE2 Documentation Website](https://docs.rke2.io/install/quickstart)
