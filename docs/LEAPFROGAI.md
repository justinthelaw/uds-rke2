# LeapfrogAI

<!-- TODO: renovate setup -->
**Supported Version**: 0.7.2

## Supporting Packages

Supporting packages are specific to the LeapfrogAI version outlined within this document, as well as the pre-requisites and caveats surrounding the deployment of UDS RKE2 on a host environment.

### NVIDIA GPU Operator

<!-- TODO: docs for NVIDIA GPU Operator -->

### LeapfrogAI Workarounds

The following are workarounds for LeapfrogAI that must be implemented within the cluster after LeapfrogAI has been deployed.

#### RKE2 CoreDNS

Patch the RKE2 CoreDNS Corefile with the tenant and admin gateway rewrites for Supabase and KeyCloak hand-offs

The RKE2 CoreDNS service needs to proxy requests to the external Supabase's HTTPS endpoint to the internal cluster service instead, and also for the KeyCloak admin service as well. This is because the Supabase authentication handoff requires interaction with a third-party, SSO service that is served from an HTTPS endpoint. This CoreDNS workaround allows us to properly resolve the Supabase and KeyCloak HTTPS endpoints internally without leaving the cluster.

#### Supabase URL

Patch the Supabase URL in the Supabase Studio ConfigMap

The Supabase public URL within the Supabase Studio ConfigMap is missing due to a failed helm replacement of the Zarf variable. This patch goes in and ensures the global Domain variable is inserted into the Supabase public URL. Without this variable, Supabase Studio
dashboards fail to function properly.
