# LeapfrogAI

<!-- TODO: renovate setup -->
**Supported Version**: 0.8.0

## Supporting Packages

Supporting packages are specific to the LeapfrogAI version outlined within this document, as well as the pre-requisites and caveats surrounding the deployment of UDS RKE2 on a host environment.

### LeapfrogAI Workarounds

The following are workarounds for LeapfrogAI that must be implemented within the cluster after LeapfrogAI has been deployed.

#### RKE2 CoreDNS

Patch the RKE2 CoreDNS Corefile with the tenant and admin gateway rewrites for Supabase and KeyCloak hand-offs

The RKE2 CoreDNS service needs to proxy requests to the external Supabase's HTTPS endpoint to the internal cluster service instead, and also for the KeyCloak admin service as well. This is because the Supabase authentication handoff requires interaction with a third-party, SSO service that is served from an HTTPS endpoint. This CoreDNS workaround allows us to properly resolve the Supabase and KeyCloak HTTPS endpoints internally without leaving the cluster.

In the "LATEST" bundles and package published to GHCR domain used for the CoreDNS reroute is, by default, `uds.dev`; whereas the "DEV" bundles are `uds.local` by default. Please see the UDS [create](../tasks/create.yaml) and [deploy](../tasks/deploy.yaml) tasks for details on how to change this to a domain of your choice.

See the [DNS and TLS docs](./DNS-TLS.md) for some more detail on DNS settings and rationale.

## Additional Info

- [LeapfrogAI Repository](https://github.com/defenseunicorns/leapfrogai)
- [LeapfrogAI Documentation Website](https://docs.leapfrog.ai/docs/)
