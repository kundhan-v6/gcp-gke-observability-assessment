# GCP GKE Multi-Cluster Observability Assessment

## Overview

This project implements an end-to-end Google Cloud architecture with two Google Kubernetes Engine (GKE) clusters, two stateless web applications, global multi-cluster traffic management, HTTPS/TLS, infrastructure as code, CI/CD, security controls, centralized logging, metrics, tracing, profiling, error reporting, BigQuery analytics, and Grafana dashboards.

The implementation uses:

- GCP project: `gcp-gke-assessment`
- Primary GKE cluster: `gke-primary` in `us-central1-a`
- Secondary GKE cluster: `gke-secondary` in `us-east1-b`
- Global application IP: `8.232.28.44`
- Public application hostname: `gke.kundhanphotography.com`
- Cloud DNS for public DNS resolution
- Google-managed TLS certificate for trusted HTTPS
- HTTP-to-HTTPS redirect on the global frontend
- Terraform for infrastructure
- GitHub Actions for CI/CD
- MultiClusterIngress and MultiClusterService for global traffic
- Cloud Armor for WAF protection
- Workload Identity for workload authentication
- Cloud Logging, Cloud Monitoring, Cloud Trace, Cloud Profiler, and Error Reporting
- BigQuery for log analytics
- Grafana for visualization

## Assessment Deliverables

### Working cluster with accessible application endpoint

Validated HTTPS endpoints:

- Application A health: `https://gke.kundhanphotography.com/app-a/health`
- Application B health: `https://gke.kundhanphotography.com/app-b/health`
- Distributed trace demo: `https://gke.kundhanphotography.com/app-a/trace-demo`

Both health endpoints return `HTTP/2 200` over a trusted Google-managed TLS certificate.

Plain HTTP requests are redirected permanently to HTTPS. For example:

`http://gke.kundhanphotography.com/app-a/health → 301 → https://gke.kundhanphotography.com:443/app-a/health`

The trace demo confirms Application A can call Application B successfully.

### Grafana dashboard

The final dashboard contains six panels:

1. Application error rate over time
2. Request latency p50, p95, and p99
3. Container restarts by namespace and cluster
4. CPU utilization by cluster
5. Memory used by cluster
6. GKE node health — Ready status

Final evidence files are stored under `grafana/`:

- `grafana/grafana-dashboard.png`
- `grafana/gke-multicluster-observability.json`

### BigQuery log analysis

BigQuery dataset:

`gcp-gke-assessment.gke_observability`

Files:

- [BigQuery schema](bigquery/SCHEMA.md)
- [Sample queries](bigquery/sample_queries.sql)

The sample queries demonstrate request volume, HTTP 5xx error rates, and p50/p95/p99 latency across both clusters and both applications.

### Troubleshooting scenario

A real application scheduling issue was documented and resolved by adding dedicated application node pools with sufficient CPU capacity.

See [Troubleshooting Scenario](docs/troubleshooting.md).

## Architecture

See the full [Architecture Documentation](docs/architecture.md).

High-level traffic flow:

`User → Cloud DNS → Global HTTPS Load Balancer → TLS Termination → Cloud Armor → MultiClusterIngress → MultiClusterService → NEGs → GKE pods`

HTTP traffic is redirected to HTTPS before application traffic is served.

The same applications run in both clusters to demonstrate cross-region redundancy.

## Repository Structure

    .
    ├── .github/workflows/
    ├── apps/
    │   ├── app-a/
    │   └── app-b/
    ├── bigquery/
    │   ├── SCHEMA.md
    │   └── sample_queries.sql
    ├── docs/
    │   ├── architecture.md
    │   ├── design-decisions.md
    │   ├── setup-guide.md
    │   └── troubleshooting.md
    ├── grafana/
    │   ├── grafana-dashboard.png
    │   └── gke-multicluster-observability.json
    ├── kubernetes/
    │   ├── apps.yaml
    │   ├── frontend-config.yaml
    │   └── multicluster-ingress.yaml
    └── terraform/

## Infrastructure as Code

Terraform manages the core Google Cloud infrastructure, including:

- Custom VPC and regional subnets
- GKE clusters
- Dedicated application node pools
- Cloud NAT
- Private Service Access
- Artifact Registry
- Secret Manager
- Workload Identity
- Multi-cluster configuration
- Global static IP
- Cloud Armor
- BigQuery log export
- Grafana reader IAM
- Binary Authorization

Kubernetes and multi-cluster application resources are maintained as declarative manifests and deployed through GitHub Actions.

See [Setup Guide](docs/setup-guide.md).

## Kubernetes Application Design

Application A and Application B are stateless Flask services deployed to both clusters.

Each application uses:

- Kubernetes Deployment
- Multiple replicas
- ClusterIP Service
- ConfigMap
- Kubernetes Secret
- CPU and memory resource requests and limits
- Readiness probe
- Liveness probe
- Horizontal Pod Autoscaler

Application A includes `/app-a/trace-demo`, which calls Application B and creates a distributed trace.

## Global Traffic Management and HTTPS

Application Services use `ClusterIP`. They are not exposed through separate per-application public load balancers.

External traffic uses:

- Domain: `gke.kundhanphotography.com`
- Cloud DNS A record → `8.232.28.44`
- Global static IP: `8.232.28.44`
- Google-managed TLS certificate: `gke-kundhanphotography-cert`
- HTTPS frontend on port 443
- HTTP frontend on port 80 with permanent redirect to HTTPS
- Cloud Armor WAF policy
- MultiClusterIngress
- MultiClusterService
- Healthy backends across both GKE clusters

The MultiClusterIngress references:

- `networking.gke.io/static-ip: "8.232.28.44"`
- `networking.gke.io/pre-shared-certs: "gke-kundhanphotography-cert"`
- `networking.gke.io/frontend-config: "assessment-frontend-config"`

The `FrontendConfig` enables permanent HTTP-to-HTTPS redirection.

Validated behavior:

- HTTP App A → `301 Moved Permanently`
- HTTP App B → `301 Moved Permanently`
- HTTPS App A → `HTTP/2 200`
- HTTPS App B → `HTTP/2 200`

## Observability

### Cloud Logging

Applications emit structured JSON logs with:

- application name
- version
- request ID
- request path
- HTTP status
- request latency

GKE workload and system logging are also enabled.

### BigQuery

Selected application and platform logs are exported from Cloud Logging to BigQuery using a project-level logging sink.

The dataset uses partitioned tables and 30-day retention.

### Grafana

Grafana visualizes both application log analytics and Google Cloud Monitoring metrics across `gke-primary` and `gke-secondary`.

### Cloud Trace

OpenTelemetry instrumentation exports traces to Google Cloud Trace.

The `/app-a/trace-demo` endpoint demonstrates Application A → Application B distributed tracing.

### Cloud Profiler

Both applications include Cloud Profiler instrumentation.

### Error Reporting

The `/error` endpoints intentionally generate exceptions for Error Reporting validation.

## Security

Implemented security controls include:

- HTTPS-only application access through HTTP-to-HTTPS redirection
- Google-managed TLS certificate
- Cloud DNS
- Workload Identity
- Secret Manager
- Cloud Armor
- SQL injection WAF protection
- Cross-site scripting WAF protection
- Binary Authorization in audit-only mode
- GitHub OIDC / Workload Identity Federation
- Least-privilege Grafana reader identity

No long-lived Google Cloud service-account keys are stored in the repository.

## CI/CD

### Terraform Infrastructure Pipeline

The Terraform workflow performs:

- format validation
- initialization
- validation
- planning
- destructive-change protection
- apply after merge to `main`

### Application Build, Publish, and Deploy Pipeline

The application workflow:

1. Builds Application A and Application B.
2. Pushes images to Artifact Registry.
3. Deploys to `gke-primary`.
4. Deploys to `gke-secondary`.
5. Validates Kubernetes rollouts.
6. Applies the HTTPS `FrontendConfig`.
7. Applies MultiClusterService resources.
8. Applies MultiClusterIngress with the static IP and TLS certificate configuration.

The HTTPS implementation was merged to `main` through PR #11 and validated by the post-merge application deployment workflow.

## Design Decisions

See [Design Decisions and Rationale](docs/design-decisions.md).

## Known Limitations

The global application endpoint now uses Cloud DNS, a trusted Google-managed TLS certificate, HTTPS on port 443, and permanent HTTP-to-HTTPS redirection.

Remaining production-hardening considerations include:

- stronger Binary Authorization enforcement instead of audit-only mode
- organization-level governance and folder hierarchy
- dedicated backup and disaster-recovery controls for future stateful workloads
- private GKE clusters if required by a production security model
- additional policy, alerting, and operational controls appropriate to production environments
