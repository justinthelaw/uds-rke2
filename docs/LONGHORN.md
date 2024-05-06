# Longhorn Configuration

Longhorn


## Prerequisites
Must install x and y on the host node.

The following packages must be installed on all nodes in the cluster:
- `curl`
- `findmnt`
- `grep`
- `awk`
- `blkid`

Furthermore, you must ensure that `open-iscsi` has been installed and that the `iscsid` daemon is running on all nodes in the cluster (Ubuntu OS should already contain `open-iscsi`).

## Usage

### Flavors

There are two _pseudo_-flavors (Zarf Variable) of the Rook-Ceph deployment available for use when creating the Zarf package. One of the following flavors _**MUST**_ be set, using the `--set FLAVOR` flag, on create:

1. `single-node` (default): is used to deploy Longhorn to clusters that are not prepared for high-availability or redundancy of the cluster's resources and pods (2 or less nodes). These values are described in [the single-node values file](../packages/longhorn/values/single-node-cluster-values.yaml).
2. `multi-node`: is used to deploy Longhorn to clusters with 3 or more nodes that can handle a high-availability and redundancy deployment. These values are described in [the multi-node values file](../packages/longhorn/values/multi-node-cluster-values.yaml).





### Notes

- Helm chart should be installed into the `longhorn-system` namespace only.

- Table of the Longhorn values files fields: https://github.com/longhorn/longhorn/tree/master/chart#values

