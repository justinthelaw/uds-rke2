# LeapfrogAI

<!-- TODO: renovate setup -->
**Supported Version**: 0.9.1

## Supporting Packages

Supporting packages are specific to the LeapfrogAI version outlined within this document, as well as the prerequisites and caveats surrounding the deployment of UDS RKE2 on a host environment.

### LeapfrogAI Workarounds

The following are workarounds for LeapfrogAI that must be implemented within the cluster after LeapfrogAI has been deployed.

#### RKE2 CoreDNS

Patch the RKE2 CoreDNS Corefile with the tenant and admin gateway rewrites for Supabase and KeyCloak hand-offs.

The RKE2 CoreDNS service needs to proxy requests to the external Supabase's HTTPS endpoint to the internal cluster service instead, and also for the KeyCloak admin service as well. This is because the Supabase authentication handoff requires interaction with a third-party SSO service that is served from an HTTPS endpoint. This CoreDNS workaround allows us to properly resolve the Supabase and KeyCloak HTTPS endpoints internally without leaving the cluster.

In the "LATEST" bundles and packages published to GHCR, the domain used for the CoreDNS reroute is, by default, `uds.dev`; whereas the "DEV" bundles use `uds.local` by default. Please see the UDS [create](../tasks/create.yaml) and [deploy](../tasks/deploy.yaml) tasks for details on how to change this to a domain of your choice.

See the [DNS and TLS docs](./DNS-TLS.md) for more detail on rationale, and the [CA Certificates for Supabase section](#ca-certificates-for-supabase) for some workarounds required when the Domain, CA cert, and/or the TLS cert/key are changed for a particular deployment environment.

#### CA Certificates for Supabase

As mentioned in the previous section, the CA certificate used to sign the TLS certificates in the Istio Gateways (tenant and admin) must be provided to services that interact with Supabase via HTTPS protocol.

The workarounds package contains a method for supplying these CA certificates to the containers that communicate over HTTPS to/from Supabase containers (i.e., `keycloak` -> `supabase-auth` -> `leapfrogai-ui`).

## Additional Info

- [LeapfrogAI Repository](https://github.com/defenseunicorns/leapfrogai)
- [LeapfrogAI Documentation Website](https://docs.leapfrog.ai/docs/)
