# Operating System (OS) Preparation

## Host System Configuration

Should be performed before entering the airgap or already performed by the system administrators of the server.

### Dependency Installation

The [Dependency Install script](../scripts/os/install-deps.sh) will install the `jq`, `ansible` and `unzip` and Ansible for package creation and installation and scripting for system-level configurations.

### OS STIG

The [OS STIG script](../scripts/os/os-stig.sh) leverages Ansible provided by DISA as part of their [automation content](https://public.cyber.mil/stigs/supplemental-automation-content/).

Leveraging this automation ensures that we stay as close to the source of the STIG as possible, and do not have to implement all the STIG fixes/checks ourselves.

The one piece not implemented in the Ansible STIG content is the enabling/installation of FIPS packages. Lightweight logic has been added to enable FIPS (note that FIPS on Ubuntu requires a subscription).

### OS Preparation

The [OS Preparation script](../scripts/os/os-prep.sh) changes a number of things on the base OS to ensure smooth operation of RKE2 and UDS pieces running on top such as [UDS Core](https://github.com/defenseunicorns/uds-core). Requirements were pulled from upstream documentation:

- SELinux requirements: [general requirements](https://docs-bigbang.dso.mil/latest/docs/prerequisites/os-preconfiguration/) and [logging specific requirements](https://docs-bigbang.dso.mil/latest/packages/fluentbit/docs/TROUBLESHOOTING/?h=fs.inotify.max_user_watches%2F#Too-many-open-files)
- Handling prerequisite requirements: Modifying network manager and disabling services that conflict with cluster networking (see [this](https://docs.rke2.io/known_issues#firewalld-conflicts-with-default-networking) and [this](https://docs.rke2.io/known_issues#networkmanager))
