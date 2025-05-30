# NVIDIA GPU Operator

The NVIDIA GPU Operator provides single-pane management resources that follow the Kubernetes operator pattern. When configured properly, capabilities like time-slicing and multi-instance GPUs can be provisioned on existing GPU resources on nodes within the cluster. Additionally, some optional components within the NVIDIA GPU Operator allow engineers to maintain NVIDIA dependencies in a Kubernetes-native way.

## Node Feature Discovery

The Kubernetes Node Feature Discovery component allows other Kubernetes resources to define and consume hardware and software resources available on a node. The NVIDIA GPU Operator requires this to be installed on the cluster beforehand so that NVIDIA GPUs can be characterized properly.

## Optional Components

> [!IMPORTANT]
> Many of the default-disabled optional components of the operator contain images/containers that are not available within IronBank and must be pulled from NVCR.

### NVIDIA Container Toolkit

The NVIDIA Container Toolkit allows containerized applications and services to consume NVIDIA GPUs as resources. This is usually pre-installed on the host node prior to air-gapping or via an internally mirrored package repository or by bringing the dependencies into the air-gap. The NVIDIA GPU Operator includes a DaemonSet that can be enabled to install the NVIDIA Container Toolkit on the host as a Kubernetes resource, allowing engineers the flexibility of deploying and updating the toolkit in a Kubernetes-native way.

If your NVIDIA Container Toolkit is pre-installed, please ensure that the `containerd` runtime was correctly configured post-toolkit installation. The `/etc/containerd/config.toml` should look something like this:

```toml
version = 2

[plugins]

  [plugins."io.containerd.grpc.v1.cri"]
    enable_cdi = true
    cdi_spec_dirs = ["/etc/cdi", "/var/run/cdi"]

    [plugins."io.containerd.grpc.v1.cri".containerd]
      default_runtime_name = "nvidia"  

      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
            BinaryName = "/usr/local/nvidia/toolkit/nvidia-container-runtime"

        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-experimental]
          privileged_without_host_devices = false
          runtime_engine = ""
          runtime_root = ""
          runtime_type = "io.containerd.runc.v2"

          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia-experimental.options]
            BinaryName = "/usr/local/nvidia/toolkit/nvidia-container-runtime-experimental"
```

### NVIDIA GPU Drivers

NVIDIA's GPU drivers are usually pre-installed on the host node, similar to the NVIDIA Container Toolkit. Upgrading GPU drivers and ensuring they remain up-to-date can be done using the NVIDIA GPU Operator as well. By providing the correct pre-compiled drivers within the [`nvidia-gpu-operator-values.yaml`](../packages/nvidia-gpu-operator/values/nvidia-gpu-operator-values.yaml), and ensuring the host meets minimum requirements for installing these drivers via a Kubernetes pod, engineers can maintain and deploy drivers to host nodes in a Kubernetes-native way.

### Multi-Instance GPUs

Multi-Instance GPU (MIG) relies on extra configuration and understanding of the deployment environment's GPUs. Please see the [MIG configuration](#configuration) guide for more details.

## Usage

### Configuration

Create and deploy-time configuration of the Zarf package is done mainly on the following components, and is dependent on the engineer's final desired configuration and the cluster's available node resources:

1. (Create-time) [NVIDIA GPU Drivers](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/precompiled-drivers.html)
2. (Deploy-time) [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
3. (Deploy-time) [Time-Slicing](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-sharing.html)
4. (Deploy-time) [Multi-Instance GPUs](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/gpu-operator-mig.html)

### Cleanup

In order to perform a fresh install after a previous deployment of the NVIDIA GPU operator, the engineer must remove the following directory from the host:

```bash
sudo rm -rf /run/nvidia
```

## Additional Info

- [NVIDIA GPU Operator Repository](https://github.com/NVIDIA/gpu-operator)
- [NVIDIA GPU Operator Documentation Website](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/overview.html)
