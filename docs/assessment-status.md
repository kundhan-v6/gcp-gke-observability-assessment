# GCP GKE Observability Assessment Status

## Architecture Constraint Note

The final GKE topology intentionally uses two zonal GKE Standard clusters in separate regions (`us-central1-a` and `us-east1-b`) instead of rebuilding the environment as two regional clusters. The Google Cloud Free Trial project is limited by a project-wide `CPUS_ALL_REGIONS` quota of 12 vCPUs. A full production-style two-region design with regional clusters and multi-zone worker-node distribution would require substantially more capacity, particularly when maintaining separate general-purpose and application node pools.

To remain within the Free Trial quota while still demonstrating high-availability and multi-region DevOps concepts, the solution uses two independent clusters in different regions, replicated App A/App B workloads, MultiClusterService, MultiClusterIngress, health checks, global load balancing, Cloud Armor, HTTPS, DNS, HPA, Workload Identity, Secret Manager CSI, and centralized observability. This provides cross-region redundancy, while the additional zone-level control-plane and worker-node resilience of regional clusters is documented as the production target when standard quotas are available.

Because the assessment deadline is approaching and the current environment is already stable, deployed, and validated end to end, no late-stage cluster redesign is being introduced. This avoids unnecessary migration risk while keeping the quota-driven architectural tradeoff explicit and technically justified.

| # | Area | Assessment requested | What we actually delivered | Status | Evidence / important note |
|---:|---|---|---|---|---|
| 1 | Assignment | Open-book assignment | Completed as an open-book implementation | ✅ | Full GitHub project created |
| 2 | Assignment | Complete within 1 week | Work completed within the assessment workflow | ✅ | Project history/commits |
| 3 | Assignment | Share personal Git repository/link | Personal GitHub repository exists with complete project | ✅ | `kundhan-v6/gcp-gke-observability-assessment` |
| 4 | Assignment exception | Features unavailable because of free-tier/service limitations may be skipped | We used the assessment allowance where the Free Trial quota materially constrained production-style topology. The clearest example is the regional GKE design: the project-wide `CPUS_ALL_REGIONS` quota is 12 vCPUs, so the solution prioritizes two-region redundancy within the available quota instead of deploying a larger regional/multi-zone worker footprint that would exceed the limit. | ➖ | Constraint is documented transparently; no capability is being claimed as implemented when it is not. |
| 5 | Project/Governance | Create/use a GCP project | Created and used `gcp-gke-assessment` | ✅ | Entire environment uses this project |
| 6 | Project/Governance | Folder → Project governance hierarchy | Project exists, but an Organization/Folder hierarchy was **not** created | 🟡 | Standalone project used |
| 7 | IAM | Dev IAM/persona | No dedicated human `Dev` identity/persona created | 🟡 | Runtime/automation identities exist instead |
| 8 | IAM | Ops IAM/persona | No dedicated human `Ops` identity/persona created | 🟡 | Same caveat |
| 9 | IAM | SRE IAM/persona | No dedicated human `SRE` identity/persona created | 🟡 | Same caveat |
| 10 | IAM | CI/CD IAM identity | Dedicated GitHub/Terraform deployment identities and Workload Identity Federation implemented | ✅ | GitHub Actions uses OIDC/WIF |
| 11 | IAM | Least-privilege service identities | App runtime and Grafana reader identities created | ✅ | `app-runtime-identity.tf`, `grafana-access.tf` |
| 12 | Networking | Custom VPC | `gke-assessment-vpc` created | ✅ | `terraform/network.tf` |
| 13 | Networking | Segregated network/subnets | Separate primary and secondary GKE subnets created | ✅ | `10.10.0.0/20`, `10.40.0.0/20` |
| 14 | Networking | Dedicated GKE subnet(s) | One dedicated subnet per cluster/region | ✅ | `gke-primary-subnet`, `gke-secondary-subnet` |
| 15 | Networking | Dedicated LB subnet | No separate dedicated load-balancer subnet | 🟡 | Global external LB/MCI does not use a dedicated subnet here |
| 16 | Networking | Dedicated monitoring/operations subnet | No separate monitoring subnet | 🟡 | Observability uses managed GCP services |
| 17 | Networking | VPC-native / alias IP ranges | Pod and Service secondary ranges configured for both clusters | ✅ | `10.20/16`, `10.30/20`, `10.50/16`, `10.60/20` |
| 18 | Networking | Private Google Access | Enabled on both subnets | ✅ | `private_ip_google_access = true` |
| 19 | Networking | Private Service Access | Reserved `10.70.0.0/16` range and Service Networking peering configured | ✅ | `nat-private-service-access.tf` |
| 20 | Networking | Cloud NAT | Cloud NAT deployed in both regions | ✅ | Primary and secondary routers/NAT |
| 21 | Networking | NAT logging | Enabled | ✅ | `log_config { enable = true }` |
| 22 | Networking | Firewall rules | Terraform-managed firewall configuration implemented | ✅ | `terraform/firewall.tf` |
| 23 | Networking | VPC Flow Logs | Enabled on both subnets | ✅ | `network.tf` |
| 24 | Networking — optional | Shared VPC | Not implemented | ⚪ | Explicitly optional |
| 25 | GKE | Two GKE clusters | `gke-primary` and `gke-secondary` | ✅ | Both operational |
| 26 | GKE | Clusters in separate regions | One in `us-central1-a`, one in `us-east1-b` | ✅ | Geographic separation achieved |
| 27 | GKE | **Regional** GKE clusters | Two zonal GKE Standard clusters were deliberately used in separate regions because the Google Cloud Free Trial project has a project-wide `CPUS_ALL_REGIONS` quota of only 12 vCPUs. A full two-region regional/multi-zone worker topology with separate general-purpose and application node pools would exceed that quota. The implemented design still provides multi-region redundancy through independent clusters in `us-central1-a` and `us-east1-b`, replicated workloads, MCS/MCI, health checks, and global routing. | 🟡 | Deliberate quota-constrained design choice, not an implementation failure. In a production environment with standard quotas, each cluster would be regional with multi-zone worker distribution for additional zone-level control-plane and workload HA. |
| 28 | GKE | Standard or Autopilot | GKE Standard selected | ✅ | `terraform/gke.tf` |
| 29 | GKE | General-purpose/default node capacity | Default GKE nodes exist | ✅ | `e2-medium` |
| 30 | GKE | Application node pool | Dedicated `apps-pool` created in each cluster | ✅ | `e2-standard-2` |
| 31 | GKE — optional | Dedicated system node pool | No separately named system-only node pool | ⚪ | Explicitly optional |
| 32 | GKE | Multi-region operating model such as active-active/passive/blue-green | Same applications registered across both clusters through MCS/MCI; effectively active-active backend architecture | ✅ | Both clusters registered |
| 33 | GKE | Workloads replicated across clusters | Same apps deployed automatically to both clusters | ✅ | GitHub Actions deployment |
| 34 | GKE | Cloud DNS | Cloud DNS is implemented for `gke.kundhanphotography.com` | ✅ | A record points to global IP `8.232.28.44`; DNS record is now adopted by Terraform |
| 35 | GKE/networking | Internal load balancing where requested | Application Services use `ClusterIP`; no separate GCP Internal Load Balancer | 🟡 | Chosen because global MCI fronts the apps |
| 36 | Applications | Two independent web applications | App A and App B created | ✅ | `apps/app-a`, `apps/app-b` |
| 37 | Applications | Stateless applications | Both applications are stateless Flask services | ✅ | Deliberate architecture decision |
| 38 | Applications | Containerized | Dockerfiles created for both | ✅ | Artifact Registry workflow |
| 39 | Applications | Multiple Pods / replicas | Each Deployment starts with 2 replicas | ✅ | `kubernetes/apps.yaml` |
| 40 | Applications | Kubernetes Deployment resources | App A and App B Deployments implemented | ✅ | `apps.yaml` |
| 41 | Applications | Kubernetes Services | ClusterIP Services implemented | ✅ | App A + App B |
| 42 | Applications | ConfigMaps | `app-config` ConfigMap implemented | ✅ | Environment + log level |
| 43 | Applications | Secrets | Applications consume the runtime secret through the GKE Secret Manager CSI integration | ✅ | Mounted read-only as `/var/secrets/DEMO_SECRET`; old Kubernetes `app-secrets` object is removed after validation |
| 44 | Applications/Security | Secret Manager | Secret Manager resource, version, IAM access and direct GKE workload consumption implemented | ✅ | `SecretProviderClass` uses `provider: gke`; Apps A/B mount `assessment-runtime-secret/versions/latest` through `secrets-store-gke.csi.k8s.io` |
| 45 | Applications | Resource requests/limits | CPU/memory requests and limits configured | ✅ | `100m/128Mi` requests etc. |
| 46 | Applications | Health/readiness checks | Liveness and readiness probes configured | ✅ | `/health` |
| 47 | Applications | Horizontal Pod Autoscaler | App A and App B HPAs implemented | ✅ | min 2, max 4, CPU 70% |
| 48 | Applications | Demonstrate autoscaling | HPA was validated during testing from `2 → 4 → 2` | ✅ | Runtime validation performed |
| 49 | Applications | Cross-service communication | App A calls App B through `/app-a/trace-demo` | ✅ | Distributed trace validated |
| 50 | Applications — optional | Pub/Sub | Not implemented | ⚪ | Optional |
| 51 | Applications — optional | Cloud SQL | Not implemented | ⚪ | Optional; applications intentionally stateless |
| 52 | Applications — optional | Redis | Not implemented | ⚪ | Optional |
| 53 | Applications — optional | Service Mesh / Anthos Service Mesh | Not implemented | ⚪ | Explicitly optional |
| 54 | Global traffic | Global external Load Balancer | Global Google load-balancing architecture created by MCI | ✅ | Global IP + MCI |
| 55 | Global traffic | **HTTPS** Load Balancer | Global HTTPS endpoint is implemented and serving both applications | ✅ | `https://gke.kundhanphotography.com`; HTTP redirects permanently to HTTPS |
| 56 | Global traffic | Single global IP | `8.232.28.44` | ✅ | Terraform global static IP |
| 57 | Global traffic | SSL/TLS termination | Google-managed TLS certificate is active and attached to the global frontend | ✅ | `gke-kundhanphotography-cert` for `gke.kundhanphotography.com`; managed by/adopted into Terraform |
| 58 | Global traffic | Cloud DNS/custom DNS routing | Custom DNS routing implemented | ✅ | `gke.kundhanphotography.com` resolves to `8.232.28.44`; DNS A record adopted into Terraform |
| 59 | Global traffic | MultiClusterIngress | Implemented | ✅ | `kubernetes/multicluster-ingress.yaml` |
| 60 | Global traffic | MultiClusterService | App A and App B MCS implemented | ✅ | Both clusters registered |
| 61 | Global traffic | Health checks | `/app-a/health` and `/app-b/health` BackendConfig health checks | ✅ | Health endpoints return 200 |
| 62 | Global traffic | Health-based backend routing | Multi-cluster backend health architecture implemented | ✅ | MCI/MCS + health checks |
| 63 | Global traffic | Automatic cluster failover | Architecture supports health-based multi-cluster failover, but we have **not performed/documented a controlled cluster-failure test** | 🟡 | Worth validating before submission if desired |
| 64 | Global traffic | Route user to healthy/nearest backend | Google global LB/MCI handles healthy backend selection; we did not separately demonstrate geographic proximity behavior | 🟡 | Technical architecture present, explicit test absent |
| 65 | Global traffic | URI/path routing | `/app-a`, `/app-a/*`, `/app-b`, `/app-b/*` | ✅ | MCI spec |
| 66 | Global traffic | WAF | Cloud Armor attached | ✅ | BackendConfig/Cloud Armor |
| 67 | Global traffic | SQL injection protection | Cloud Armor `sqli-v422-stable` rule | ✅ | `cloud-armor.tf` |
| 68 | Global traffic | XSS protection | Cloud Armor `xss-v422-stable` | ✅ | `cloud-armor.tf` |
| 69 | Global traffic | Network Endpoint Groups | MCI/GKE ingress architecture creates NEG-backed endpoints | ✅ | Used by multi-cluster ingress |
| 70 | Global traffic | Ingress/controller layer | MultiClusterIngress serves this role | ✅ | Implemented |
| 71 | Global traffic | Document full request flow LB → Service → Pod | Documented | ✅ | `docs/architecture.md` |
| 72 | Observability | Centralized Cloud Logging | GKE workload/system logging enabled | ✅ | `gke.tf` |
| 73 | Observability | Cloud Monitoring | GKE/Cloud Monitoring metrics used | ✅ | Grafana uses Monitoring data |
| 74 | Observability | Application structured logs | Both apps emit structured JSON request logs | ✅ | App source |
| 75 | Observability | GKE workload logs | Enabled/exported | ✅ | Logging configuration + sink |
| 76 | Observability | GKE platform/control-plane logs | Relevant system/platform logs included | ✅ | BigQuery sink |
| 77 | Observability | VPC Flow Logs | Enabled and included in sink | ✅ | `network.tf`, `observability-bigquery.tf` |
| 78 | Observability | Firewall logs | Included in BigQuery logging filter | ✅ | BigQuery sink |
| 79 | Observability | Load-balancer/ingress logs | HTTP load-balancer resources included in logging sink | ✅ | `observability-bigquery.tf` |
| 80 | Observability | Export logs to BigQuery | Logging project sink created | ✅ | `gke-observability-bq` |
| 81 | BigQuery | BigQuery observability dataset | `gke_observability` created | ✅ | Terraform |
| 82 | BigQuery | Partitioned log tables | `use_partitioned_tables = true` | ✅ | Terraform |
| 83 | BigQuery | Retention | 30-day partition expiration configured | ✅ | Terraform |
| 84 | BigQuery | Schema documentation | Created | ✅ | `bigquery/SCHEMA.md` |
| 85 | BigQuery | Sample log-analysis queries | Created and tested | ✅ | `bigquery/sample_queries.sql` |
| 86 | BigQuery | Error-rate analysis | Query includes HTTP 5xx rate | ✅ | SQL |
| 87 | BigQuery | Latency analysis | p50/p95/p99 query | ✅ | SQL |
| 88 | Grafana | Cloud-hosted Grafana dashboard | Grafana Cloud dashboard built | ✅ | Export and screenshot committed |
| 89 | Grafana | At least 4 panels | We delivered **6 panels** | ✅ | Dashboard JSON |
| 90 | Grafana panel | Application error rate over time | Implemented for both apps/clusters | ✅ | Panel 1 |
| 91 | Grafana panel | Pod/container restart count by namespace | Implemented for `assessment` in both clusters | ✅ | Panel 3 |
| 92 | Grafana panel | Request latency p50 | Implemented | ✅ | Panel 2 |
| 93 | Grafana panel | Request latency p95 | Implemented | ✅ | Panel 2 |
| 94 | Grafana panel | Request latency p99 | Implemented | ✅ | Panel 2 |
| 95 | Grafana panel | CPU utilization | Implemented | ✅ | Panel 4 |
| 96 | Grafana panel | Memory utilization | Implemented | ✅ | Panel 5 |
| 97 | Grafana extra | Node Ready/health status | Added beyond minimum requirement | ✅ | Panel 6 |
| 98 | Grafana evidence | Screenshot **or** dashboard export | We provided **both** | ✅ | `grafana-dashboard.png` + JSON |
| 99 | Grafana security | Read-only data identity | Dedicated Grafana service account and read permissions | ✅ | `grafana-access.tf` |
| 100 | Tracing | Cloud Trace | OpenTelemetry → Cloud Trace implemented | ✅ | Application instrumentation + IAM |
| 101 | Tracing | Distributed service trace | App A → App B trace validated with parent/child spans | ✅ | Runtime trace evidence |
| 102 | Profiler | Cloud Profiler | API, IAM role and application instrumentation implemented | 🟡 | Code is complete; we did not preserve a visible Profiler UI/profile artifact in the repo |
| 103 | Error Reporting | Cloud Error Reporting | API, IAM and intentional error endpoints implemented | ✅ | `/app-a/error`, `/app-b/error` |
| 104 | Error Reporting | Generate/test application errors | Intentional exceptions generated | ✅ | Runtime validation performed |
| 105 | Observability — optional | Managed Service for Prometheus | Not implemented | ⚪ | Explicitly optional |
| 106 | Observability — optional | Synthetic monitoring / uptime checks | Not implemented | ⚪ | Explicitly optional |
| 107 | HA/DR | Workloads in two geographic regions | Yes | ✅ | Central US + East US GCP regions |
| 108 | HA/DR | Multi-cluster availability | Applications deployed in both clusters | ✅ | Same workloads on both |
| 109 | HA/DR | Health-aware traffic distribution | MCI/MCS and health checks implemented | ✅ | Global backend architecture |
| 110 | HA/DR | Automatic failover | Mechanism exists but controlled failover drill/documented proof has not been completed | 🟡 | One of the best remaining validation tasks |
| 111 | HA/DR | Replicated application state | Application is stateless, so no application state requires replication | ➖ | Architectural decision |
| 112 | HA/DR | Stateful database replication | No database exists | ➖ | Optional state layer intentionally excluded |
| 113 | HA/DR | Backup/recovery strategy | No GKE Backup/Backup for GKE implementation; docs explain stateless design and production backup extension | 🟡 | Could improve documentation or implement if desired |
| 114 | Security | Workload Identity | Enabled in both clusters and used by application workloads | ✅ | `${project}.svc.id.goog`; application node pools use GKE metadata server configuration for workload identity |
| 115 | Security | Kubernetes SA → Google SA binding | `assessment/app-runtime` bound to `gke-app-runtime` | ✅ | Terraform + Kubernetes SA annotation |
| 116 | Security | Secret Manager | Secret resource, secret version, secretAccessor IAM and direct runtime consumption implemented | ✅ | GKE managed Secret Manager CSI driver + Workload Identity; validated in both primary and secondary cluster deployments |
| 117 | Security — optional | Private GKE clusters | Not implemented | ⚪ | Explicitly optional |
| 118 | Security | Cloud Armor | Implemented | ✅ | WAF policy |
| 119 | Security | Binary Authorization | Enabled on both GKE clusters | ✅ | `gke.tf` |
| 120 | Security | Binary Authorization policy | Policy created | ✅ | `binary-authorization-policy.tf` |
| 121 | Security | Strong Binary Authorization enforcement | Policy is deliberately `DRYRUN_AUDIT_LOG_ONLY`, not blocking | 🟡 | Good assessment-safe choice; production would enforce |
| 122 | Security | Avoid static GCP keys for CI/CD | GitHub Workload Identity Federation/OIDC used | ✅ | No service-account JSON keys in repo |
| 123 | Security | No credentials committed | `.gitignore` protects credential JSON/key files | ✅ | Grafana JSON has one narrow exception only |
| 124 | IaC | Terraform infrastructure | Core GCP infrastructure, HTTPS certificate and assessment DNS record are represented/adopted in Terraform | ✅ | `terraform/`; existing DNS A record and managed TLS certificate are imported/adopted into Terraform state |
| 125 | IaC | Terraform VPC/networking | Implemented | ✅ | Network/NAT/PSA/firewall |
| 126 | IaC | Terraform GKE | Implemented | ✅ | Clusters + node pools |
| 127 | IaC | Terraform security | Implemented | ✅ | IAM, WAF, Secret Manager including write-only secret version management, Workload Identity, Binary Auth |
| 128 | IaC | Terraform observability | BigQuery, logging sink, Grafana IAM implemented | ✅ | Observability Terraform |
| 129 | IaC | “Entire setup through Terraform” if interpreted literally | Kubernetes apps, MCS and MCI are YAML applied by CI/CD rather than Terraform | 🟡 | Infrastructure is Terraform; Kubernetes delivery is declarative YAML |
| 130 | CI/CD | Source-controlled application build/deployment | GitHub Actions implemented and latest Secret Manager CSI deployment completed successfully | ✅ | `application.yml`; run `36120276480` completed successfully |
| 131 | CI/CD | Build App A | Automated | ✅ | Workflow |
| 132 | CI/CD | Build App B | Automated | ✅ | Workflow |
| 133 | CI/CD | Container Registry | Artifact Registry implemented | ✅ | Terraform/workflow |
| 134 | CI/CD | Push application images | Automated | ✅ | GitHub Actions |
| 135 | CI/CD | Deploy primary cluster | Automated and Secret Manager CSI mount validation passes | ✅ | Latest main deployment run `36120276480` |
| 136 | CI/CD | Deploy secondary cluster | Automated and Secret Manager CSI mount validation passes | ✅ | Latest main deployment run `36120276480` |
| 137 | CI/CD | Validate rollout | Automated, including application rollout and non-empty Secret Manager CSI mount validation | ✅ | `kubectl rollout status` plus `test -s /var/secrets/DEMO_SECRET` without exposing the secret value |
| 138 | CI/CD | Deploy multi-cluster routing | Automated | ✅ | MCS/MCI applied by workflow |
| 138A | CI/CD | Latest production-style application deployment | PR #15 merged and the full main-branch deployment completed successfully across both clusters and MCI | ✅ | GitHub Actions run `36120276480`; job `108023871595`; completed in 4m44s |
| 139 | CI/CD | Terraform validate/plan | Automated | ✅ | `terraform.yml` |
| 140 | CI/CD | Terraform apply | Automatic after merge to `main` | ✅ | Workflow |
| 141 | CI/CD | Protect against destructive Terraform changes | Added deletion/replacement guard | ✅ | Beyond basic requirement |
| 142 | Deliverable | Terraform files | Present | ✅ | `terraform/` |
| 143 | Deliverable | Architecture diagram | Mermaid architecture diagram included | ✅ | `docs/architecture.md` |
| 144 | Deliverable | Architecture explanation | Detailed flow documented | ✅ | `docs/architecture.md` |
| 145 | Deliverable | Step-by-step setup guide | Created | ✅ | `docs/setup-guide.md` |
| 146 | Deliverable | Design decisions/rationale | Created | ✅ | `docs/design-decisions.md` |
| 147 | Deliverable | BigQuery schema | Created | ✅ | `bigquery/SCHEMA.md` |
| 148 | Deliverable | Sample BigQuery queries | Created | ✅ | `bigquery/sample_queries.sql` |
| 149 | Deliverable | Working cluster + accessible endpoint | Both health endpoints tested successfully | ✅ | `200 OK` |
| 150 | Deliverable | Grafana screenshot/export | Both supplied | ✅ | `grafana/` |
| 151 | Deliverable | Troubleshooting issue encountered | Real CPU scheduling issue documented | ✅ | `docs/troubleshooting.md` |
| 152 | Deliverable | Troubleshooting resolution | Added dedicated `e2-standard-2` application node pools | ✅ | Terraform + troubleshooting doc |
| 153 | Documentation | README | Comprehensive README on `main` includes Cloud DNS, HTTPS/TLS and the current public hostname | ✅ | README updated after HTTPS work; current endpoint is `https://gke.kundhanphotography.com` |
| 154 | Documentation | Known limitations | Remaining limitations are documented; HTTP-only, missing DNS and missing TLS are no longer current gaps | ✅ | Current remaining items include org/folder governance, stronger Binary Auth enforcement, backup strategy and controlled failover evidence |
| 155 | Explicit optional/excluded | Shared VPC | Kept out | ⚪ | Optional |
| 156 | Explicit optional/excluded | Separate system node pool | Kept out | ⚪ | Optional |
| 157 | Explicit optional/excluded | Anthos Service Mesh/service mesh | Kept out | ⚪ | Optional |
| 158 | Explicit optional/excluded | Managed Prometheus | Kept out | ⚪ | Optional |
| 159 | Explicit optional/excluded | Synthetic uptime checks | Kept out | ⚪ | Optional |
| 160 | Explicit optional/excluded | Private GKE | Kept out | ⚪ | Optional |
| 161 | Explicit optional/excluded | Pub/Sub state/integration | Kept out | ⚪ | Optional |
| 162 | Explicit optional/excluded | Cloud SQL | Kept out | ⚪ | Optional |
| 163 | Explicit optional/excluded | Redis | Kept out | ⚪ | Optional |
| 164 | Explicit assessment allowance | Feature unavailable/unsuitable under free-tier constraints can be skipped | This allowance was applied to the regional GKE topology. The Free Trial project is capped at 12 vCPUs across all regions. Rather than risk exceeding quota close to the deadline, the final implementation keeps the validated two-zonal-cluster, two-region architecture and documents the production target of regional clusters with multi-zone worker distribution. | ➖ | Final submission intentionally avoids late infrastructure redesign because the current architecture is stable, deployed, validated, and demonstrates the required multi-region concepts within the quota constraint. |