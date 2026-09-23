-- Assessment query 1: Request counts and HTTP 5xx error rates
-- by GKE cluster and application.
-- The /error endpoint deliberately generates HTTP 500 test traffic.

SELECT
  resource.labels.cluster_name AS cluster,
  jsonPayload.app AS app,
  COUNT(*) AS total_requests,
  COUNTIF(jsonPayload.status >= 500) AS errors,
  ROUND(
    100 * SAFE_DIVIDE(
      COUNTIF(jsonPayload.status >= 500),
      COUNT(*)
    ),
    2
  ) AS error_rate_pct
FROM `gcp-gke-assessment.gke_observability.stdout`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND resource.labels.namespace_name = 'assessment'
  AND jsonPayload.app IN ('app-a', 'app-b')
GROUP BY cluster, app
ORDER BY cluster, app;


-- Assessment query 2: Approximate p50, p95 and p99 request latency
-- by GKE cluster and application.

SELECT
  resource.labels.cluster_name AS cluster,
  jsonPayload.app AS app,
  COUNT(*) AS requests,
  ROUND(APPROX_QUANTILES(jsonPayload.latency_ms, 100)[OFFSET(50)], 2)
    AS p50_ms,
  ROUND(APPROX_QUANTILES(jsonPayload.latency_ms, 100)[OFFSET(95)], 2)
    AS p95_ms,
  ROUND(APPROX_QUANTILES(jsonPayload.latency_ms, 100)[OFFSET(99)], 2)
    AS p99_ms
FROM `gcp-gke-assessment.gke_observability.stdout`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND resource.labels.namespace_name = 'assessment'
  AND jsonPayload.app IN ('app-a', 'app-b')
  AND jsonPayload.latency_ms IS NOT NULL
GROUP BY cluster, app
ORDER BY cluster, app;
