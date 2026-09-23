# BigQuery log export schema

## Dataset and table

- Project: `gcp-gke-assessment`
- Dataset: `gke_observability`
- Application log table: `stdout`
- Dataset location: `US`
- Partitioning: Daily, using the `timestamp` field
- Partition retention: 30 days

## Fields used in the assessment

| Field | BigQuery type | Purpose |
|---|---|---|
| `timestamp` | TIMESTAMP | Time of the log event |
| `resource.labels.cluster_name` | STRING | Primary or secondary GKE cluster |
| `resource.labels.namespace_name` | STRING | Kubernetes namespace |
| `resource.labels.container_name` | STRING | Application container |
| `jsonPayload.app` | STRING | Application name |
| `jsonPayload.path` | STRING | HTTP request path |
| `jsonPayload.status` | FLOAT | HTTP response status |
| `jsonPayload.latency_ms` | FLOAT | Request latency in milliseconds |
| `jsonPayload.request_id` | STRING | Request correlation identifier |
| `severity` | STRING | Log severity |

The Cloud Logging sink exports application requests from both clusters.
Application `/health` requests are excluded from the export to reduce
unnecessary log volume.

The SQL examples in `sample_queries.sql` were tested against exported
application records from both clusters on September 23, 2026.

The test dataset includes intentional HTTP 500 responses and slow requests.
Its error rates and latency percentiles are demonstration data, not
production performance measurements.
