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
- `kubernetes/frontend-config.yaml`
- `kubernetes/multicluster-ingress.yaml`
- `kubernetes/secret-provider-class.yaml`

The application GitHub Actions workflow builds both applications, pushes images to Artifact Registry, deploys both clusters, validates rollouts, applies the Secret Manager CSI configuration, and applies MultiClusterService, FrontendConfig, and MultiClusterIngress resources.

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
curl -i https://gke.kundhanphotography.com/app-a/health
curl -i https://gke.kundhanphotography.com/app-b/health
curl -i https://gke.kundhanphotography.com/app-a/trace-demo
```

Expected health result:

`HTTP/2 200`

Validate the HTTP-to-HTTPS redirect separately:

```bash
curl -I http://gke.kundhanphotography.com/app-a/health
```

Expected redirect:

`301 Moved Permanently`

## Generate Observability Traffic

Slow responses:

```bash
curl https://gke.kundhanphotography.com/app-a/slow
curl https://gke.kundhanphotography.com/app-b/slow
```

Intentional errors:

```bash
curl https://gke.kundhanphotography.com/app-a/error
curl https://gke.kundhanphotography.com/app-b/error
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
