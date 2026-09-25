# Troubleshooting Scenario

## Issue Summary

During application deployment, some GKE application Pods could not be scheduled because the available nodes did not have enough allocatable CPU capacity for all requested workload resources.

## Symptoms

The deployment did not reach the desired number of running replicas. Some Pods remained in `Pending` state.

Troubleshooting commands included:

```bash
kubectl get pods -n assessment
kubectl describe pod <pod-name> -n assessment
kubectl get nodes
kubectl describe node <node-name>
```

Kubernetes scheduler events showed insufficient CPU capacity.

## Root Cause

The original GKE nodes were sized for a lightweight assessment environment.

After deploying multiple replicas of Application A and Application B, the combined CPU requests from application workloads and system workloads exceeded the remaining allocatable CPU on the existing nodes.

Because the application manifests define explicit CPU requests, Kubernetes correctly refused to schedule Pods onto nodes that could not satisfy those requests.

## Resolution

Dedicated application node pools were added to both GKE clusters through Terraform.

The application node pools use `e2-standard-2` machines:

- `gke-primary` application node pool
- `gke-secondary` application node pool

After the additional capacity was provisioned, the application workloads were redeployed and Kubernetes successfully scheduled the required Pod replicas.

## Validation

The fix was validated with:

```bash
kubectl get pods -n assessment
kubectl get deployments -n assessment
kubectl get nodes
```

The Pods reached `Running` state and the Deployments reached their desired replica counts.

Application health was then validated through the global Multi-Cluster Ingress endpoint:

```bash
curl -i http://8.232.28.44/app-a/health
curl -i http://8.232.28.44/app-b/health
```

Both returned:

`HTTP/1.1 200 OK`

The service-to-service path was also validated:

```bash
curl -i http://8.232.28.44/app-a/trace-demo
```

Application A successfully called Application B and returned a successful downstream response.

## Lessons Learned

- Size Kubernetes node capacity based on workload resource requests.
- Review allocatable node capacity before increasing replicas.
- Use dedicated application node pools where appropriate.
- Inspect scheduler events when Pods remain Pending.
- Keep infrastructure changes reproducible through Terraform.
