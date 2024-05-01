# Ubuntu VM with NVIDIA GPU Passthrough

> [!IMPORTANT]
> These instructions are currently only scoped for Linux-based distributions with at least 1 NVIDIA GPU. Multiple GPUs, alternative computer architectures and operating systems require extra or different steps for host setup and device passthrough and virtualization. Refer to [Credits & Resources](#credits-and-resources) for more details.

These are manual instructions meant to build a sandboxed Virtual Machine with GPU passthrough. The VM can emulate resource constrained, locked-down, and/or air-gapped systems for installation, functional and performance tests.

## Instructions

### Setup the Host

Install the required dependencies:

```bash
sudo apt install libvirt-daemon-system libvirt-clients qemu-kvm qemu-utils virt-manager ovmf
```

Enable IOMMU features and CPU virtualization:

- Restart your machine and boot into BIOS. Enable a feature called `IOMMU` and also CPU virtualization, `VT-d` for Intel chip-sets.

Once you've booted into the host, make sure that IOMMU and CPU virtualization are enabled:

```bash
# both should provide hardware message outputs
sudo dmesg | grep IOMMU
sudo dmesg | grep VT-d
```

Pass the hardware-enabled IOMMU functionality into the kernel by editing the `/etc/default/grub` file with `root` permissions and including the kernel parameter as follows:

```grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on"
```

Dynamically unbind the NVIDIA drivers and bind the VFIO drivers right before the VM starts and subsequently reversing these actions when the VM stops. This ensures that, whenever the VM isn't in use, the GPU is available to the host machine to do work on its native drivers

To determine your IOMMU grouping, use the following script: [`iommu.sh`](vm/iommu.sh)

For Intel systems, here's some sample output:

```bash
IOMMU Group * 00:00.0 Host bridge [0600]: Intel Corporation Device [8086:a702] (rev 01)
...
00:1f.5 Serial bus controller [0c80]: Intel Corporation Device [8086:7a24] (rev 11)
00:1f.6 Ethernet controller [0200]: Intel Corporation Device [8086:0dc8] (rev 11)
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation Device [10de:2820] (rev a1)
01:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:22bd] (rev a1)
...
02:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd NVMe SSD Controller PM9A1/PM9A3/980PRO [144d:a80a]
```

### Prepare the VM OS

Download OS ISO files:

Go to the [Ubuntu Server Downloads](https://ubuntu.com/download/server) page to find the proper ISO for installation.

The version required for full compatibility and STIG scripting is [Ubuntu Server 20.04.6](https://ubuntu.com/download/server/thank-you?version=20.04.6&architecture=amd64).

### Setup VM Hooks

Setup emulation hook helper from upstream binary:

```bash
sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' -O /etc/libvirt/hooks/qemu
sudo chmod +x /etc/libvirt/hooks/qemu
```

Go ahead and restart libvirt to use the newly installed hook helper:

```bash
sudo service libvirtd restart
```

QEMU hook directory schema:

```bash
export VM_NAME=uds-rke2
# Before a VM is started, before resources are allocated:
/etc/libvirt/hooks/qemu.d/$VM_NAME/prepare/begin/*

# Before a VM is started, after resources are allocated:
/etc/libvirt/hooks/qemu.d/$VM_NAME/start/begin/*

# After a VM has started up:
/etc/libvirt/hooks/qemu.d/$VM_NAME/started/begin/*

# After a VM has shut down, before releasing its resources:
/etc/libvirt/hooks/qemu.d/$VM_NAME/stopped/end/*

# After a VM has shut down, after resources are released:
/etc/libvirt/hooks/qemu.d/$VM_NAME/release/end/*
```

If we place an executable script in one of these directories, the hook manager will take care of everything else. I've chosen to name my VM to be "uds-rke2":

```bash
$ tree /etc/libvirt/hooks/
/etc/libvirt/hooks/
├── qemu
└── qemu.d
    └── uds-rke2
        ├── prepare
        │   └── begin
        └── release
            └── end
```

Create a file named `kvm.conf` ([example here](vm/configs/kvm.conf)) and place it under `/etc/libvirt/hooks/`. Add entries to the file vy translating the address for each device as follows: `IOMMU Group 1 01:00.0 ...` --> `VIRSH_...=pci_0000_01_00_0`.

Make sure to substitute the correct bus addresses for the devices you'd like to passthrough to your VM (in my case a GPU and SSD). Just in case it's still unclear, you get the virsh PCI device IDs from the [`iommu.sh`](vm/iommu.sh) script's output.

The following script is used to bind the GPU to the VM: [`bind_vfio.sh`](vm/bind_vfio.sh)

The following script is used to unbind the GPU from the VM: [`unbind_vfio.sh`](vm/unbind_vfio.sh)

Don't forget to make these scripts executable with `chmod +x <script_name>`. Then place these scripts so that your directory structure looks like this:

```bash
$ tree /etc/libvirt/hooks/
/etc/libvirt/hooks/
├── kvm.conf
├── qemu
└── qemu.d
    └── uds-rke2
        ├── prepare
        │   └── begin
        │       └── bind_vfio.sh
        └── release
            └── end
                └── unbind_vfio.sh
```

### Create the VM

Use [virt-manager](https://virt-manager.org/) to setup a VM using a GUI. Virt-manager essentially builds on-top of the QEMU base-layer and adds other features/complexity. Important things to note:

- Allocate the right amount of Storage, RAM and CPU
  - For a minimum RKE2 cluster, UDS-Core and LeapfrogAI stack:
    - 300Gb storage
    - 16 CPUs
    - 32 Gb RAM
- Use the "Add Hardware" button to mount your NVIDIA GPU, and other devices (like SSDs) to the VM
- Under "CPU", enable available CPU security flaw mitigations on the CPUs
- Under "Boot Options", enable the boot menu and reorder devices to choose your preferred default boot option
- Remove any extraneous hardware or components that are automatically populated by `virt-manager`

## Credits and Resources

- Docs
  - Libvirt
    - [VM Lifecycle](https://wiki.libvirt.org/page/VM_lifecycle)
    - [Domain XML](https://libvirt.org/formatdomain.html)
    - [Hooks](https://libvirt.org/hooks.html)
    - [libvirtd](https://libvirt.org/manpages/libvirtd.html)
    - [virsh](https://libvirt.org/manpages/virsh.html)
    - [virtIO](https://wiki.libvirt.org/page/Virtio)
    - [virtio-blk vs. virtio-scsi](https://mpolednik.github.io/2017/01/23/virtio-blk-vs-virtio-scsi/)
  - Linux Kernel
    - [KVM](https://www.kernel.org/doc/html/latest/virt/kvm/index.html)
    - [VFIO](https://www.kernel.org/doc/html/latest/driver-api/vfio.html?highlight=vfio%20pci)
- Tutorials
  - [Bryan Steiner's GPU Passthrough for Windows and Ubuntu](https://github.com/bryansteiner/gpu-passthrough-tutorial)
  - [Mental Outlaw's GPU Pass-through On Linux/Virt-Manager](https://youtu.be/KVDUs019IB8?si=QI5OqyeiuhkoRVL-)
  - [Yuri Alek's GPU Passthrough Scripts](https://gitlab.com/YuriAlek/vfio)
