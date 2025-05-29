# Operating System (OS) Preparation

## Dependency Installation

On the node's host, `jq` is required for certain cluster operations. `ansible` and `unzip` are only required if you are looking to [enforce STIGs via an Ansible playbook](#os-stig).

## OS STIG

To STIG your host, you can use the Ansible playbook provided by DISA as part of their [automation content](https://public.cyber.mil/stigs/supplemental-automation-content/).

Leveraging this automation ensures that you stay as close to the source of the STIG as possible and do not have to implement all the STIG fixes/checks yourself.

The one piece not implemented in the Ansible STIG content is the enabling/installation of FIPS packages, as FIPS on Ubuntu requires a subscription.

You can use the existing scripts to perform [dependency installs](./vm/scripts/install-deps.sh) and the [STIG process](./vm/scripts/os-stig.sh).

## OS Preparation

The [OS Preparation script](../scripts/os/os-prep.sh) changes a number of things on the base OS to ensure smooth operation of RKE2 and UDS components running on top, such as [UDS Core](https://github.com/defenseunicorns/uds-core). Requirements were pulled from upstream documentation:

- SELinux requirements: [general requirements](https://docs-bigbang.dso.mil/latest/docs/prerequisites/os-preconfiguration/) and [logging-specific requirements](https://docs-bigbang.dso.mil/latest/packages/fluentbit/docs/TROUBLESHOOTING/?h=fs.inotify.max_user_watches%2F#Too-many-open-files)
- Handling prerequisite requirements: Modifying network manager and disabling services that conflict with cluster networking (see [this](https://docs.rke2.io/known_issues#firewalld-conflicts-with-default-networking) and [this](https://docs.rke2.io/known_issues#networkmanager))
