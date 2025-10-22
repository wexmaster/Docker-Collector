# Etapa base mínima
FROM debian:bookworm-slim

LABEL maintainer="Luis Chavez"
LABEL version="v0.135.0"
LABEL description="OpenTelemetry Collector Exporter for Atenea (MU, RHO, OMEGA)"

# Variables de entorno por defecto (modificables en docker run o compose)
ENV OTEL_NS="default.ns.monitoring" \
    OTEL_REGION="work-01.nextgen.igrupobbva" \
    OTEL_MRID="mr-opentelemetry" \
    OTEL_METRICSET="opentelemetry_metrics" \
    OTEL_LOG_FILE="/var/log/monitoring_exporter.log" \
    OTEL_CONFIG_PATH="/etc/otel/collector-config.yaml"

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios
RUN mkdir -p /opt/otel /etc/otel /secret /var/log
WORKDIR /opt/otel

# Detectar arquitectura y descargar binario correspondiente
# Docker/Podman expone automáticamente la variable TARGETARCH (amd64 / arm64)
ARG TARGETARCH
RUN echo "Arquitectura detectada: ${TARGETARCH}" && \
    if [ "${TARGETARCH}" = "arm64" ]; then \
    FILE="monitoring-otelcol-v0.135.0-linux.arm64.zip"; \
    else \
    FILE="monitoring-otelcol-v0.135.0-linux.x64.zip"; \
    fi && \
    echo "Descargando ${FILE}" && \
    curl -fSL -o monitoring-otelcol.zip \
    "https://github.com/wexmaster/opentelemetryexportermonitoring/releases/download/v0.135.0/${FILE}" && \
    unzip -o monitoring-otelcol.zip && \
    mv monitoring-otelcol-v0.135.0-linux.*64/monitoring-otelcol . && \
    chmod +x monitoring-otelcol && \
    rm -rf monitoring-otelcol-v0.135.0-linux.*64 monitoring-otelcol.zip __MACOSX

# Establecer volumen para certificados
VOLUME ["/secret"]

# Copiar script de arranque
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exponer puertos
EXPOSE 4317 4318 13133

# Comando de inicio
CMD ["/entrypoint.sh"]
