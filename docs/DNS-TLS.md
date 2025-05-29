# Domain Name Service (DNS) and Transport Layer Security (TLS) Certificates

## Initial Domain Context

One of the core assumptions of the original [`uds-k3d`](https://github.com/defenseunicorns/uds-k3d) package is the use of `uds.dev` as the base domain for your production environment. This assumption is integral to the DNS and network configuration provided by the package. It is based on an existing public DNS entry for `*.uds.dev` that resolves to `127.0.0.1` (localhost).

In this repository's `uds-rke2` packages and bundles, this public DNS resolution will not work. UDS RKE2's services are exposed via the host machine's IP, and not via localhost. The following section notes the `/etc/hosts` modifications required to access virtual services being served by the Istio gateways.

## Modifying Domain Name

> [!NOTE]
> Modifying the domain requires the associated TLS certificate and key creation configuration to also be modified. Please see the [`create:tls` task](../tasks/create.yaml) for more details.

In the UDS create and deploy actions, there is a `DOMAIN` variable that can be set to affect how the underlying packages are built and deployed. The `DOMAIN` is required for both stages as each package requires the setting of the domain at different steps (create or deploy-time).

An example of the shared `DOMAIN` variable in a UDS configuration file (DEV):

```yaml
shared:
  domain: uds.local
```

## Certificate Authority (CA) and TLS Certificate Management

The CA and TLS certs are all created and injected by the aforementioned `create:tls` UDS task. To modify this behavior to use your own CA and TLS certificates, you will need to copy and paste your TLS key and cert, base64 encoded, into the `uds-config-dev.yaml` or `uds-config-[LATEST_VERSION].yaml` PRIOR to running the UDS task to deploy the bundle.

The CA certs that result from this process, or the CA certs you used to sign the original TLS certs, must be available to the host machine(s) and cluster so that HTTPS errors do not show up to the end-users of the web applications and API, and so that services within the cluster (e.g., [Supabase and KeyCloak in LeapfrogAI](./LEAPFROGAI.md)) that reach out to each other via HTTPS do not error out due to CA trust issues.

Once the CA cert has been created as part of the overall `uds-rke2-local-path-core` or `uds-rke2-local-path-core-dev` tasks, you copy the CA certs into your host machine's trust store. For example, in Ubuntu the following can be executed (as root):

```bash
cp build/packages/local-path/tls/ca.pem /usr/local/share/ca-certificates/ca.crt
update-ca-certificates
```

If you are using a browser that does not use the host machine's trust store location, then you will need to upload the CA certificate into the browser's settings related to Trust, Privacy, and/or Security. Please refer to your browser's documentation for more details.

### CA Trust Bundles

UDS Core, which UDS RKE2 is reliant on, has an [outstanding issue for centralized management of CA trust bundles](https://github.com/defenseunicorns/uds-core/issues/464) within the cluster. This issue is outside the scope of UDS RKE2's base infrastructure, and any applications that have CA trust issues due to service mesh incompatibilities or communication must follow the pattern seen in the [`leapfrogAI-workarounds` package](../packages/leapfrogai/zarf.yaml).

## Host File Modifications

The default Istio Ingress gateways deployed with the UDS RKE2 bundle are assigned the following MetalLB allocated IPs, where `BASE_IP` is the IP of the host machine as identified within the MetalLB component of the UDS RKE2 Infrastructure Zarf package:

- `admin`: `<BASE_IP>.200`
- `tenant`: `<BASE_IP>.201`
- `passthrough`: `<BASE_IP>.202`

If an `/etc/hosts` file needs to be modified for access via a host's browser, then modify the `/etc/hosts` accordingly. Below is an example entry:

```toml
127.0.0.1       localhost
127.0.1.1       device-name

# UDS and LeapfrogAI subdomains
192.168.0.200   keycloak.admin.uds.dev grafana.admin.uds.dev neuvector.admin.uds.dev
192.168.0.201   leapfrogai-api.uds.dev sso.uds.dev leapfrogai.uds.dev leapfrogai-rag.uds.dev ai.uds.dev supabase-kong.uds.dev
```

## CoreDNS Loop-back Issues

When using CoreDNS in RKE2, manual modification of `/etc/resolv.conf` is typically unnecessary as CoreDNS handles cluster DNS. However, `resolv.conf` remains relevant for host-level DNS and potential CoreDNS upstream configurations. Loopback errors can occur due to misconfigured CoreDNS, `resolv.conf` pointing to localhost, NetworkManager interference, or improper kubelet (`kubelet-args`) settings. To troubleshoot, examine CoreDNS and kubelet configurations, check `resolv.conf` on host nodes, and look for NetworkManager issues.

When installing on a device or server that is located in an isolated network with its own set of DNS, ensure that the `/etc/resolv.conf` does not contain any loops (e.g., `nameserver .`) or else CoreDNS will go into a `CrashBackLoop`. Follow the steps below for editing the `/etc/resolv.conf`:

```bash
# Make changes to the entries
sudo vim /etc/systemd/resolved.conf
# Restart the service
sudo systemctl restart systemd-resolved
```

For more permanent changes that persist through system reboots, edit both the `/etc/resolv.conf` and the `/etc/systemd/resolved.conf`.

## CoreDNS Override

If any internal services require an `https://` "reach-around" in order to interact with another service's API, then the Corefile of the RKE2 CoreDNS service can be modified by following the [RKE CoreDNS Helm Chart configuration instructions](https://www.suse.com/support/kb/doc/?id=000021179).

An example CoreDNS override is seen in the [`leapfrogAI-workarounds` package](../packages/leapfrogai/zarf.yaml).

This is not a recommended approach as most, if not all, services should be capable of communicating via the secured internal Istio service mesh.

## Additional Info

- [CoreDNS K8s Documentation](https://kubernetes.io/docs/tasks/administer-cluster/coredns/)
- [RKE2 CoreDNS Customization](https://www.suse.com/support/kb/doc/?id=000021179)
