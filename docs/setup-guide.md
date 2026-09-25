# Setup and Validation Guide

## Prerequisites

Required tools:

- Google Cloud SDK
- Terraform
- kubectl
- Docker
- Git
- GitHub CLI

Project:

`gcp-gke-assessment`

## Terraform

Infrastructure code is stored in `terraform/`.

Initialize:

```bash
cd terraform
terraform init
```

Validate:

```bash
terraform fmt -check -recursive
terraform validate
```

Review:

```bash
terraform plan
```

The normal workflow applies reviewed Terraform through GitHub Actions after merge to `main`.

## Application Deployment

Application source:

- `apps/app-a`
- `apps/app-b`

Kubernetes manifests:

- `kubernetes/apps.yaml`
- `kubernetes/multicluster-ingress.yaml`

The application GitHub Actions workflow builds both applications, pushes images to Artifact Registry, deploys both clusters, validates rollouts, and applies MultiClusterService and MultiClusterIngress resources.

## Validate Primary Cluster

```bash
gcloud container clusters get-credentials gke-primary \
  --location=us-central1-a \
  --project=gcp-gke-assessment

kubectl get pods -n assessment
kubectl get deployments -n assessment
kubectl get svc -n assessment
kubectl get hpa -n assessment
```

## Validate Secondary Cluster

```bash
gcloud container clusters get-credentials gke-secondary \
  --location=us-east1-b \
  --project=gcp-gke-assessment

kubectl get pods -n assessment
kubectl get deployments -n assessment
kubectl get svc -n assessment
kubectl get hpa -n assessment
```

## Validate Global Endpoints

```bash
curl -i http://8.232.28.44/app-a/health
curl -i http://8.232.28.44/app-b/health
curl -i http://8.232.28.44/app-a/trace-demo
```

Expected health result:

`HTTP/1.1 200 OK`

## Generate Observability Traffic

Slow responses:

```bash
curl http://8.232.28.44/app-a/slow
curl http://8.232.28.44/app-b/slow
```

Intentional errors:

```bash
curl http://8.232.28.44/app-a/error
curl http://8.232.28.44/app-b/error
```

## BigQuery

Schema documentation:

`bigquery/SCHEMA.md`

Sample SQL:

`bigquery/sample_queries.sql`

Dataset:

`gcp-gke-assessment.gke_observability`

## Grafana

Final evidence files:

- `grafana/grafana-dashboard.png`
- `grafana/gke-multicluster-observability.json`

The dashboard includes error rate, p50/p95/p99 latency, container restarts, CPU, memory, and node readiness.

## Troubleshooting

See:

`docs/troubleshooting.md`
