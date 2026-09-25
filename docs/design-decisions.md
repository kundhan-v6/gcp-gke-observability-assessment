# Design Decisions and Rationale

## Two GKE Clusters

Two clusters were deployed in separate Google Cloud locations to demonstrate multi-region application redundancy.

- `gke-primary` in `us-central1-a`
- `gke-secondary` in `us-east1-b`

## GKE Standard

GKE Standard was selected to provide explicit control over node pools, machine sizing, and troubleshooting.

## Stateless Applications

Application A and Application B are stateless so the assessment can focus on Kubernetes, global traffic management, observability, automation, and security without introducing database replication complexity.

## Dedicated Application Node Pools

Dedicated `e2-standard-2` application node pools were added after the original cluster capacity was insufficient for all requested Pod CPU resources.

This also separates application workload capacity from the original cluster nodes.

## ClusterIP Services

Application A and Application B use `ClusterIP` Services.

They do not require independent public LoadBalancer Services because external traffic enters through the single global Multi-Cluster Ingress.

## Multi-Cluster Ingress

MultiClusterIngress and MultiClusterService were selected to demonstrate one global entry point with health-aware routing across two GKE clusters.

## Workload Identity

Workload Identity is used instead of service-account key files. This reduces credential exposure and gives workloads short-lived Google Cloud identity credentials.

## Cloud Armor

Cloud Armor protects the global application backends using preconfigured SQL injection and cross-site scripting WAF protections.

## BigQuery for Log Analytics

Selected Cloud Logging data is exported to BigQuery for analytical queries across clusters and applications.

The dataset uses partitioning and 30-day retention.

## Grafana

Grafana provides a single view across both application log analytics and Cloud Monitoring metrics.

## Binary Authorization

Binary Authorization is configured in dry-run/audit-only mode. This demonstrates admission security controls without risking accidental blocking of assessment deployments.

## GitHub Actions and OIDC

GitHub Actions handles infrastructure and application CI/CD.

Authentication uses Workload Identity Federation and OIDC instead of stored Google Cloud service-account keys.

## HTTPS Global Endpoint

The applications are exposed through `https://gke.kundhanphotography.com` using Cloud DNS, a Google-managed TLS certificate, and HTTP-to-HTTPS redirection on the global frontend.

## Free Trial Quota Constraint and Production Target

The assessment environment intentionally uses two zonal GKE Standard clusters in separate regions rather than two fully regional, multi-zone clusters. The Google Cloud Free Trial project is limited by a project-wide `CPUS_ALL_REGIONS` quota of 12 vCPUs across all regions.

A production-style topology with two regional clusters and multi-zone worker-node distribution would require substantially more compute capacity, especially when maintaining separate general-purpose and application node pools. To remain within the available quota while still demonstrating multi-region DevOps and SRE concepts, the implementation uses independent clusters in `us-central1-a` and `us-east1-b`, replicated application workloads, MultiClusterService, MultiClusterIngress, health checks, global load balancing, Cloud Armor, HTTPS, DNS, HPA, Workload Identity, and Secret Manager CSI.

This design provides cross-region redundancy within the assessment constraints. In a production environment with standard quotas, each cluster would be deployed as a regional GKE cluster with worker nodes distributed across multiple zones to add zone-level control-plane and workload resilience.
