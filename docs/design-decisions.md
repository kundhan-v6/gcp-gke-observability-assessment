# Design Decisions and Rationale

## Two GKE Clusters

Two clusters were deployed in separate Google Cloud locations to demonstrate multi-region application redundancy.

- `gke-primary` in `us-central1-a`
- `gke-secondary` in `us-east1-b`

## GKE Standard

GKE Standard was selected to provide explicit control over node pools, machine sizing, and troubleshooting.

## Zonal Clusters

Zonal clusters were used because of assessment quota and cost constraints. Cross-region redundancy is still demonstrated through two independent clusters.

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

## HTTP Global Endpoint

The assessment uses the static global IP `8.232.28.44` over HTTP.

A production environment would normally add Cloud DNS, a managed TLS certificate, and HTTPS-only access.
