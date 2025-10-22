#!/bin/bash
# Enviar metricas, logs y trazas OTLP-JSON con timestamps actuales

OTEL_HOST="${1:-localhost}"
PORT="${2:-4318}"

METRICS_URL="http://${OTEL_HOST}:${PORT}/v1/metrics"
LOGS_URL="http://${OTEL_HOST}:${PORT}/v1/logs"
TRACES_URL="http://${OTEL_HOST}:${PORT}/v1/traces"

# === Obtener timestamps ===
NOW_NS=$(($(date +%s%N)))
END_NS=$((NOW_NS + 100000000)) # +100ms para simular fin de span

echo "Timestamp actual (ns): $NOW_NS"

# === MÉTRICAS ===
cat > metrics.json <<EOF
{
  "resourceMetrics": [
    {
      "resource": {
        "attributes": [
          {"key": "telemetry.sdk.language", "value": {"stringValue": "python"}},
          {"key": "telemetry.sdk.name", "value": {"stringValue": "opentelemetry"}},
          {"key": "telemetry.sdk.version", "value": {"stringValue": "1.27.0"}},
          {"key": "service.name", "value": {"stringValue": "ubuntu-otel-sample"}}
        ]
      },
      "scopeMetrics": [
        {
          "scope": {"name": "__main__"},
          "metrics": [
            {
              "name": "demo_requests_total",
              "description": "Número de requests simuladas",
              "unit": "1",
              "sum": {
                "dataPoints": [
                  {
                    "startTimeUnixNano": "$NOW_NS",
                    "timeUnixNano": "$END_NS",
                    "asInt": "5",
                    "attributes": [
                      {"key": "route", "value": {"stringValue": "/child1"}},
                      {"key": "method", "value": {"stringValue": "GET"}},
                      {"key": "mrid", "value": {"stringValue": "autogen"}}
                    ]
                  },
                  {
                    "startTimeUnixNano": "$NOW_NS",
                    "timeUnixNano": "$END_NS",
                    "asInt": "3",
                    "attributes": [
                      {"key": "route", "value": {"stringValue": "/grandchild1"}},
                      {"key": "method", "value": {"stringValue": "POST"}},
                      {"key": "mrid", "value": {"stringValue": "autogen"}}
                    ]
                  }
                ],
                "aggregationTemporality": "AGGREGATION_TEMPORALITY_CUMULATIVE",
                "isMonotonic": true
              }
            },
            {
              "name": "demo_cpu_usage",
              "description": "Uso CPU simulado",
              "unit": "percent",
              "gauge": {
                "dataPoints": [
                  {
                    "timeUnixNano": "$NOW_NS",
                    "asInt": "42",
                    "attributes": [
                      {"key": "unit", "value": {"stringValue": "percent"}}
                    ]
                  }
                ]
              }
            }
          ]
        }
      ]
    }
  ]
}
EOF

echo "Enviando metricas..."
curl -s -X POST "$METRICS_URL" -H "Content-Type: application/json" --data-binary @metrics.json
echo -e "\nMetricas enviadas.\n"


# === LOGS ===
cat > logs.json <<EOF
{
  "resourceLogs": [
    {
      "resource": {
        "attributes": [
          {"key": "telemetry.sdk.language", "value": {"stringValue": "python"}},
          {"key": "telemetry.sdk.name", "value": {"stringValue": "opentelemetry"}},
          {"key": "telemetry.sdk.version", "value": {"stringValue": "1.27.0"}},
          {"key": "service.name", "value": {"stringValue": "ubuntu-otel-sample"}}
        ]
      },
      "scopeLogs": [
        {
          "scope": {"name": "opentelemetry.sdk._logs._internal"},
          "logRecords": [
            {
              "timeUnixNano": "$NOW_NS",
              "observedTimeUnixNano": "$END_NS",
              "severityNumber": "SEVERITY_NUMBER_WARN",
              "severityText": "WARN",
              "body": {"stringValue": "Child operation executed custom"},
              "attributes": [
                {"key": "iteration", "value": {"intValue": "1"}},
                {"key": "mrid", "value": {"stringValue": "Child1MRID"}},
                {"key": "ns", "value": {"stringValue": "user.o014313"}},
                {"key": "region", "value": {"stringValue": "work-01.nextgen.igrupobbva"}}
              ],
              "flags": 1
            },
            {
              "timeUnixNano": "$NOW_NS",
              "observedTimeUnixNano": "$END_NS",
              "severityNumber": "SEVERITY_NUMBER_INFO",
              "severityText": "INFO",
              "body": {"stringValue": "Parent operation completed"},
              "attributes": [
                {"key": "iteration", "value": {"intValue": "1"}},
                {"key": "mrid", "value": {"stringValue": "mr-opentelemetry"}},
                {"key": "ns", "value": {"stringValue": "user.o014313"}},
                {"key": "region", "value": {"stringValue": "work-01.nextgen.igrupobbva"}}
              ],
              "flags": 1
            }
          ]
        }
      ]
    }
  ]
}
EOF

echo "Enviando logs..."
curl -s -X POST "$LOGS_URL" -H "Content-Type: application/json" --data-binary @logs.json
echo -e "\nLogs enviados.\n"


# === TRACES ===
cat > traces.json <<EOF
{
  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {"key": "telemetry.sdk.language", "value": {"stringValue": "python"}},
          {"key": "telemetry.sdk.name", "value": {"stringValue": "opentelemetry"}},
          {"key": "telemetry.sdk.version", "value": {"stringValue": "1.27.0"}},
          {"key": "service.name", "value": {"stringValue": "ubuntu-otel-sample"}}
        ]
      },
      "scopeSpans": [
        {
          "scope": {"name": "__main__"},
          "spans": [
            {
              "traceId": "12345678901234567890123456789012",
              "spanId": "1234567890123456",
              "name": "child_operation_1",
              "kind": "SPAN_KIND_INTERNAL",
              "startTimeUnixNano": "$NOW_NS",
              "endTimeUnixNano": "$END_NS",
              "attributes": [
                {"key": "operation.kind", "value": {"stringValue": "child"}},
                {"key": "mrid", "value": {"stringValue": "Child1MRID"}},
                {"key": "region", "value": {"stringValue": "work-01.nextgen.igrupobbva"}},
                {"key": "ns", "value": {"stringValue": "user.o014313"}}
              ]
            },
            {
              "traceId": "12345678901234567890123456789012",
              "spanId": "1234567890123455",
              "name": "parent_operation",
              "kind": "SPAN_KIND_INTERNAL",
              "startTimeUnixNano": "$NOW_NS",
              "endTimeUnixNano": "$END_NS",
              "attributes": [
                {"key": "operation.kind", "value": {"stringValue": "parent"}},
                {"key": "mrid", "value": {"stringValue": "mr-opentelemetry"}},
                {"key": "region", "value": {"stringValue": "work-01.nextgen.igrupobbva"}},
                {"key": "ns", "value": {"stringValue": "user.o014313"}}
              ]
            }
          ]
        }
      ]
    }
  ]
}
EOF

echo "Enviando trazas..."
curl -s -X POST "$TRACES_URL" -H "Content-Type: application/json" --data-binary @traces.json
echo -e "\nTrazas enviadas.\n"

echo "Todos los datos enviados a ${OTEL_HOST}:${PORT}"
