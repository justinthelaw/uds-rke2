# UDS RKE2 Diagram

Below is an diagram showing an example deployment of UDS RKE2 with the `local-path` flavor custom Zarf Init, NVIDIA GPU Operator and LeapfrogAI deployed on top. The dependency chain and installation order are from bottom to top.

```mermaid
flowchart
    subgraph "Example UDS RKE2 + LeapfrogAI Deployment"

        subgraph "LeapfrogAI"
            lfai_package["Zarf Package: leapfrogai"]
            lfai_workarounds["Zarf Package: leapfrogai-workarounds"]

            direction BT
            lfai_workarounds --> lfai_package
        end

        init["Zarf Package: nvidia-gpu-operator"]
        subgraph "NVIDIA GPU Operator"
            nfd["Zarf Component: node-feature-discovery"]
            nvidia["Zarf Component: nvidia-gpu-operator"]

            direction BT
            nfd --> nvidia
        end

        subgraph "UDS RKE2 Exemptions"
            exemptions["
                Zarf Package: uds-rke2-exemptions-local-path

                - uds-rke2-infrastructure-exemptions
                - local-path-exemptions
                - nvidia-gpu-operator-exemptions
            "]
        end

        subgraph "UDS Core Package"
            core["
                Zarf Package: UDS Core

                - Authservice
                - Grafana
                - Istio
                - KeyCloak
                - Kiali
                - Loki
                - Metrics-Server
                - Neuvector
                - Pepr
                - Prometheus
                - Promtail
                - Tempo
                - Velero
            "]
        end

        subgraph "UDS RKE2 Infrastructure"
            infrastructure["
                Zarf Package: infrastructure

                - MetalLB
                - MachineID, Pause
            "]
        end

        init["Zarf Package: init"]
        subgraph "Custom Zarf Init"
            init["Zarf Package: init"]
            local["Zarf Package: local-path"]
            minio["Zarf Package: minio"]

            direction LR
            init --> local
            local --> minio
            minio --> init
        end

        subgraph "UDS RKE2 Bootstrap"
            bootstrap["
                Zarf Package: uds-rke2-bootstrap

                - RKE2
                - os_prep.sh
                - rke2_install.sh
                - rke2_config.sh
                - rke2_startup.sh
                - rke2_destroy.sh
            "]
        end

    end
```
