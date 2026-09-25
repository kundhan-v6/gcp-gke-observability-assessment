# Disaster Recovery Validation

## Scope

This document captures the implemented and tested controls for the High Availability and Disaster Recovery portion of the assessment.

The deployed applications are stateless. No Cloud SQL, Memorystore, or Firestore instance is required by the current workload, so database-specific HA, replication, automated backups, and point-in-time recovery are intentionally not provisioned.

## Implemented DR Architecture

### Cross-region GKE

- Primary cluster: `gke-primary` in `us-central1-a`
- Secondary cluster: `gke-secondary` in `us-east1-b`
- MultiClusterIngress and MultiClusterService route traffic across both clusters.
- Both applications run in both clusters.

### Backup for GKE

Terraform manages two scheduled backup plans:

- `gke-primary-dr-backup`: primary-cluster backup stored in `us-east1`
- `gke-secondary-dr-backup`: secondary-cluster backup stored in `us-central1`

Both plans:

- run daily
- retain backups for 7 days
- include all namespaces
- include Secrets
- include volume data
- use deletion protection in Terraform

Backup for GKE is used as the supported workload/resource backup and recovery mechanism rather than direct access to GKE control-plane etcd snapshots.

### Restore Plans

Terraform manages restore plans in both directions:

- `gke-primary-to-secondary-restore`
- `gke-secondary-to-primary-restore`

Restore scope is limited to the `assessment` namespace and does not automatically restore cluster-scoped resources.

### Artifact Registry Protection

The existing multi-region `us` Artifact Registry repository uses Terraform-managed retention safeguards:

- keep all tagged images
- keep the 10 most recent versions per package
- delete only untagged images older than 30 days

This protects deployable SHA and release images from routine cleanup.

## DR Validation Evidence

### Controlled Secondary-only Traffic Test

A controlled MultiClusterService test temporarily left only `gke-secondary` registered as the application backend.

During the secondary-only window:

- `/app-a/health` returned successfully
- `/app-b/health` returned successfully

The original two-cluster membership was then restored and the global endpoint remained healthy.

Evidence:
- GitHub Actions run: `36183939118`
- Successful job: `Validate Secondary-only MCI Traffic`
- Result: success

### Manual Backup Test

A manual backup was created from `gke-secondary-dr-backup`.

Backup:
`secondary-dr-validation-36184032775-1`

Verified result:

- state: `SUCCEEDED`
- completed: `2026-09-25T20:10:28.616796874Z`
- contains Secrets: `true`
- contains volume data: `true`

Evidence:
- GitHub Actions run: `36184032775`
- Successful job: `Create Secondary GKE Backup`

### Restore Test

The successful secondary backup was restored into the primary cluster using:

`gke-secondary-to-primary-restore`

Restore:
`primary-dr-validation-36184391342-1`

Verified result:

- state: `SUCCEEDED`
- completed: `2026-09-25T20:13:35.430148171Z`

After the restore:

- `app-a` deployment: 2/2 available
- `app-b` deployment: 2/2 available
- App A public health endpoint returned healthy
- App B public health endpoint returned healthy

Evidence:
- restore status and workload verification run: `36184570170`
- result: success

### Final Read-only Verification

A final read-only workflow verified all DR evidence together:

- backup state is `SUCCEEDED`
- restore state is `SUCCEEDED`
- primary App A and App B deployments are available
- secondary App A and App B deployments are available
- MultiClusterService contains both cluster links:
  - `us-central1-a/gke-primary`
  - `us-east1-b/gke-secondary`
- `https://gke.kundhanphotography.com/app-a/health` is healthy
- `https://gke.kundhanphotography.com/app-b/health` is healthy

Evidence:
- GitHub Actions run: `36184736872`
- job: `Verify DR Evidence End to End`
- result: success

## Requirement Mapping

| Requirement | Implementation |
|---|---|
| Two GKE clusters / cross-regional redundancy | Implemented |
| Multi-cluster ingress / failover | Implemented and controlled secondary-only traffic test completed |
| Stateful cross-region storage | Not applicable; applications are stateless |
| Cloud SQL automated backups and PITR | Not applicable; Cloud SQL is not used |
| GKE workload backup/recovery | Backup for GKE scheduled plans, manual backup test, and successful restore test |
| Artifact Registry protection | Multi-region repository plus keep/cleanup retention policies |

## Current Production Extensions

If persistent application state is introduced later, add the appropriate stateful DR controls, such as Cloud SQL regional HA, automated backups, PITR, Memorystore replication, or Firestore multi-region configuration.
