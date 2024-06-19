# Domain Name Service (DNS)

## Domain Assumptions

One of the core assumptions of the original [`uds-k3d`](https://github.com/defenseunicorns/uds-k3d) package is the use of `uds.dev` as the base domain for your production environment. This assumption is integral to the DNS and network configuration provided by the package. It is based on an existing public DNS entry for `*.uds.dev` that resolves to `127.0.0.1` (localhost).

In this repository's `uds-rke2` packages and bundles, this public DNS resolution will not work. UDS RKE2's services are exposed via the host machine's IP, and not via localhost. The following section notes the `/etc/hosts/` modifications required to access virtual services being served by the Istio gateways.

## Host File Modifications

The default Istio Ingress gateways deployed with the UDS RKE2 bundle are assigned the following MetalLB allocated IPs, where `BASE_IP` is the IP of the host machine as identified within the MetalLB component of UDS RKE2 INfrastructure Zarf package:

- `admin`: `<BASE_IP>.200`
- `tenant`: `<BASE_IP>.201`
- `passthrough`: `<BASE_IP>.202`

If an `/etc/hosts` file needs to be modified for access via a host's browser, then modify the `/etc/hosts/` accordingly. Below is an example entry:

```text
127.0.0.1       localhost
184.223.9.200   grafana.admin.uds.dev neuvector.admin.uds.dev
184.223.9.201   sso.admin.uds.dev
```

## CoreDNS Override

If any internal services require an `https://` "reach-around" in order to interact with another service's API, then the Corefile of the RKE2 CoreDNS service can be modified by following the [RKE CoreDNS Helm Chart configuration instructions](https://www.suse.com/support/kb/doc/?id=000021179).

This is not a recommended approach, as all services should be capable of communicating via the secured internal Kubernetes network.

Additionally, an Nginx service and configuration must be installed into the cluster. An example Nginx configuration for K3d can be found in the [uds-k3d repository](https://github.com/defenseunicorns/uds-k3d/blob/main/chart/templates/nginx.yaml). The Nginx configuration assumes the use of `uds.dev` as the base domain. This configuration is tailored to support the production environment setup, ensuring that Nginx correctly handles requests and routes them within the cluster, based on the `uds.dev` domain.

## Additional Info

- [CoreDNS K8s Documentation](https://kubernetes.io/docs/tasks/administer-cluster/coredns/)
- [RKE2 CoreDNS Customization](https://www.suse.com/support/kb/doc/?id=000021179)
