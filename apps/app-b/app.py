import json
import logging
import os
import sys
import time
import uuid

import requests
from google.cloud import error_reporting
from opentelemetry import trace
from opentelemetry.exporter.cloud_trace import CloudTraceSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.trace.sampling import ParentBased, TraceIdRatioBased

from flask import Flask, g, jsonify, request

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "app-b")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")

logger = logging.getLogger(APP_NAME)
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter("%(message)s"))

logger.handlers.clear()
logger.addHandler(handler)

PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "gcp-gke-assessment")

resource = Resource.create({
    "service.name": APP_NAME,
    "service.version": APP_VERSION,
    "deployment.environment.name": "assessment",
})

tracer_provider = TracerProvider(
    resource=resource,
    sampler=ParentBased(root=TraceIdRatioBased(1.0)),
)

tracer_provider.add_span_processor(
    BatchSpanProcessor(
        CloudTraceSpanExporter(project_id=PROJECT_ID)
    )
)

trace.set_tracer_provider(tracer_provider)

FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()

error_client = error_reporting.Client(
    project=PROJECT_ID,
    service=APP_NAME,
    version=APP_VERSION,
)


@app.before_request
def start_request():
    g.start_time = time.perf_counter()
    g.request_id = str(uuid.uuid4())


@app.after_request
def log_request(response):
    latency_ms = round((time.perf_counter() - g.start_time) * 1000, 2)

    log_entry = {
        "severity": "ERROR" if response.status_code >= 500 else "INFO",
        "app": APP_NAME,
        "version": APP_VERSION,
        "request_id": g.request_id,
        "method": request.method,
        "path": request.path,
        "status": response.status_code,
        "latency_ms": latency_ms
    }

    logger.info(json.dumps(log_entry))

    response.headers["X-Request-ID"] = g.request_id
    return response


@app.route("/")
@app.route("/app-b")
def home():
    return """
    <html>
      <head>
        <title>GKE Assessment - App B</title>
      </head>
      <body>
        <h1>Application B</h1>
        <p>Running successfully on Google Kubernetes Engine.</p>
        <p>Environment: Assessment</p>
      </body>
    </html>
    """


@app.route("/health")
@app.route("/app-b/health")
def health():
    return jsonify(
        app=APP_NAME,
        version=APP_VERSION,
        status="healthy"
    )


@app.route("/slow")
@app.route("/app-b/slow")
def slow():
    time.sleep(0.8)

    return jsonify(
        app=APP_NAME,
        message="Slow response generated for latency testing"
    )


@app.route("/error")
@app.route("/app-b/error")
def error():
    try:
        raise RuntimeError(
            f"Intentional observability exception from {APP_NAME}"
        )
    except Exception:
        error_client.report_exception()
        logger.exception(
            "Intentional exception reported to Google Cloud Error Reporting"
        )

        return jsonify(
            app=APP_NAME,
            message="Intentional error for observability testing"
        ), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
