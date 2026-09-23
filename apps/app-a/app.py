import json
import logging
import os
import sys
import time
import uuid

from flask import Flask, g, jsonify, request

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "app-a")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")

logger = logging.getLogger(APP_NAME)
logger.setLevel(logging.INFO)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(logging.Formatter("%(message)s"))

logger.handlers.clear()
logger.addHandler(handler)


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
def home():
    return """
    <html>
      <head>
        <title>GKE Assessment - App A</title>
      </head>
      <body>
        <h1>Application A</h1>
        <p>Running successfully on Google Kubernetes Engine.</p>
        <p>Environment: Assessment</p>
      </body>
    </html>
    """


@app.route("/health")
def health():
    return jsonify(
        app=APP_NAME,
        version=APP_VERSION,
        status="healthy"
    )


@app.route("/slow")
def slow():
    time.sleep(1.2)

    return jsonify(
        app=APP_NAME,
        message="Slow response generated for latency testing"
    )


@app.route("/error")
def error():
    return jsonify(
        app=APP_NAME,
        message="Intentional error for observability testing"
    ), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
