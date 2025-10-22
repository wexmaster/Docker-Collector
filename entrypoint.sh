#!/bin/bash
set -e

CONFIG_FILE="${OTEL_CONFIG_PATH:-/etc/otel/collector-config.yaml}"

echo "Generando configuración dinámica en: $CONFIG_FILE"

# Inicia el bloque base de configuración
cat > "$CONFIG_FILE" <<EOF
extensions:
  health_check:
    endpoint: 0.0.0.0:13133

receivers:
  otlp:
    protocols:
      http: { endpoint: 0.0.0.0:4318 }
      grpc: { endpoint: 0.0.0.0:4317 }

processors:
  batch: {}

exporters:
  debug:
    verbosity: detailed

  monitoring:
    ns: ${OTEL_NS}
    region: ${OTEL_REGION}
    mrid: "${OTEL_MRID}"
    metricsets: "${OTEL_METRICSET}"
    traces: true
    metrics: true
    logs: true
    log_file: "${OTEL_LOG_FILE}"
    ca_cert_file: "/secret/ca.crt"
    client_cert_file: "/secret/cfs-path-bot.pem"
    client_key_file: "/secret/cfs-path-bot-unlocked.key"
EOF

# Si TOKEN está definido y no vacío → añade bloque headers
if [[ -n "${TOKEN}" ]]; then
  echo "    headers:" >> "$CONFIG_FILE"
  echo "      Authorization: \"Bearer ${TOKEN}\"" >> "$CONFIG_FILE"
  echo "TOKEN detectado: se añadió cabecera Authorization"
else
  echo "No se definió TOKEN: sin cabecera Authorization"
fi

# Continúa con el resto del YAML
cat >> "$CONFIG_FILE" <<EOF
    timeout: 45s
    sending_queue:
      enabled: true
      num_consumers: 4
      queue_size: 2048
    retry_on_failure:
      enabled: true
      initial_interval: 1s
      max_interval: 30s
      max_elapsed_time: 0s

service:
  extensions: [health_check]
  pipelines:
    logs:    { receivers: [otlp], processors: [batch], exporters: [debug, monitoring] }
    metrics: { receivers: [otlp], processors: [batch], exporters: [debug, monitoring] }
    traces:  { receivers: [otlp], processors: [batch], exporters: [debug, monitoring] }
EOF

echo "Configuración creada:"
cat "$CONFIG_FILE"

echo "Iniciando OpenTelemetry Collector..."
exec /opt/otel/monitoring-otelcol --config "$CONFIG_FILE"
