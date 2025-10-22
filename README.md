# 🛰️ OpenTelemetry Collector — Exportador a Atenea (MU, RHO, OMEGA)

Este repositorio contiene la configuración del **OpenTelemetry Collector** para integrar métricas, logs y trazas con la plataforma **Atenea**, a través de las APIs **MU**, **RHO** y **OMEGA**.  
El objetivo es centralizar la observabilidad del sistema, permitiendo enviar datos de **OpenTelemetry** hacia los servicios internos de monitorización.

---

## ⚙️ Construir el Docker

```bash
docker build -t monitoring-otel:v0.135.0 .
```
o 

```bash
docker buildx build --load -t monitoring-otel:v0.135.0 .
```

---

## 🚀 run OpenTelemetry

Es nececesario tener los certificados /secret/ca.crt como minimo y un token valido:

1. **Arrancar Docker si tenemos los Certificados:**
```bash
docker run -it --rm \
  -v $(pwd)/secret:/secret \
  -e OTEL_NS="user.xxxxxx" \
  -e OTEL_REGION="work-01.xxxx.xxxxxx" \
  -e OTEL_MRID="mr-opentelemetry" \
  -e OTEL_METRICSET="opentelemetry_metrics" \
  -p 4317:4317 -p 4318:4318 -p 13133:13133 \
  monitoring-otel:v0.135.0
```
**Arrancar Docker con Token:**
```bash
docker run -it --rm \
  -v "$(pwd)/secret:/secret" \
  -e OTEL_NS="user.xxxxxx" \
  -e OTEL_REGION="work-01.xxxx.xxxxxx" \
  -e OTEL_MRID="mr-opentelemetry" \
  -e OTEL_METRICSET="opentelemetry_metrics" \
  -e TOKEN="token" \
  -p 4317:4317 -p 4318:4318 -p 13133:13133 \
  monitoring-otel:v0.135.0
```


```bash
docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED          STATUS          PORTS                          NAMES
423a3243e865   monitoring-otel:v0.135.0  "/entrypoint.sh"         59 seconds ago   Up 58 seconds   4317/tcp, 13133/tcp            agitated_tu
```


2. **Script Bash para precrear entorno LAB**
Es necesario configurar el ns y region al igual que token
editar provision_atenea.sh antes de ejecutar:
```bash
# Configuración — personalízala antes de ejecutar
WORK="work-01"
NS="user.xxxxxx"
TOKEN="AQUITOKEN"
```
Ejecutar tenemos que tener 201 si es la primera vez si es duplicado 409 cualquie otro error lo indicara con status code
```bash
./provision_atenea.sh
Generando JSONs y ejecutando creación en json_payloads...

1 Creando MonitorResourceType...
   → HTTP 201

2 Creando MonitorResource Grandchild1MRID...
   → HTTP 201

3 Creando MonitorResource Child1MRID...
   → HTTP 201

4 Creando MonitorResource principal mr-opentelemetry...
   → HTTP 201

5 Creando Métrica base (integer)...
   → HTTP 201

6 Creando MetricSetType opentelemetry_metrics...
   → HTTP 201

7 Creando MetricSet opentelemetry_metrics...
   → HTTP 201

=========================
   RESUMEN DE ESTADOS
=========================
1  MonitorResourceType ............. HTTP 201
2  MR Grandchild1MRID .............. HTTP 201
3  MR Child1MRID ................... HTTP 201
4  MR mr-opentelemetry ............. HTTP 201
5  Métrica base .................... HTTP 201
6  MetricSetType ................... HTTP 201
7  MetricSet ....................... HTTP 201
=========================

Archivos JSON generados en json_payloads
Proceso completo.
```

3. **Script Bash para enviar datos a colector OTEL entorno LAB**

```bash
./send_demo_data.sh 
Timestamp actual (ns): 1761145625269013000
Enviando metricas...
{"partialSuccess":{}}
Metricas enviadas.

Enviando logs...
{"partialSuccess":{}}
Logs enviados.

Enviando trazas...
{"partialSuccess":{}}
Trazas enviadas.

Todos los datos enviados a localhost:4318
```

en consola veremos

```bash
2025-10-22T15:16:28.022Z	info	Logs	{"resource": {"service.instance.id": "847244f9-eef5-457a-afa3-4ddd32ff2711", "service.name": "monitoring-otelcol", "service.version": "v0.135.0"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "logs", "resource logs": 1, "log records": 2}
2025-10-22T15:16:28.022Z	info	Metrics	{"resource": {"service.instance.id": "847244f9-eef5-457a-afa3-4ddd32ff2711", "service.name": "monitoring-otelcol", "service.version": "v0.135.0"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "metrics", "resource metrics": 1, "metrics": 2, "data points": 3}
2025-10-22T15:16:28.022Z	info	Traces	{"resource": {"service.instance.id": "847244f9-eef5-457a-afa3-4ddd32ff2711", "service.name": "monitoring-otelcol", "service.version": "v0.135.0"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "traces", "resource spans": 1, "spans": 2}
2025-10-22T15:16:28.023Z	info	ResourceSpans #0
Resource SchemaURL: 
Resource attributes:
     -> telemetry.sdk.language: Str(python)
     -> telemetry.sdk.name: Str(opentelemetry)
     -> telemetry.sdk.version: Str(1.27.0)
     -> service.name: Str(ubuntu-otel-sample)
ScopeSpans #0
ScopeSpans SchemaURL: 
InstrumentationScope __main__ 
Span #0
    Trace ID       : 12345678901234567890123456789012
    Parent ID      : 
    ID             : 1234567890123456
    Name           : child_operation_1
    Kind           : Internal
    Start time     : 2025-10-22 15:16:27.828479 +0000 UTC
    End time       : 2025-10-22 15:16:27.928479 +0000 UTC
    Status code    : Unset
    Status message : 
Attributes:
     -> operation.kind: Str(child)
     -> mrid: Str(Child1MRID)
     -> region: Str(work-01.xxxx.xxxxxx)
     -> ns: Str(user.XXXXXXX)
Span #1
    Trace ID       : 12345678901234567890123456789012
    Parent ID      : 
    ID             : 1234567890123455
    Name           : parent_operation
    Kind           : Internal
    Start time     : 2025-10-22 15:16:27.828479 +0000 UTC
    End time       : 2025-10-22 15:16:27.928479 +0000 UTC
    Status code    : Unset
    Status message : 
Attributes:
     -> operation.kind: Str(parent)
     -> mrid: Str(mr-opentelemetry)
     -> region: Str(work-01.xxxx.xxxxxx)
     -> ns: Str(user.XXXXXXX)
	{"resource": {"service.instance.id": "847244f9-eef5-457a-afa3-4ddd32ff2711", "service.name": "monitoring-otelcol", "service.version": "v0.135.0"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "traces"}
2025-10-22T15:16:28.022Z	info	ResourceLog #0
Resource SchemaURL: 
Resource attributes:
     -> telemetry.sdk.language: Str(python)
     -> telemetry.sdk.name: Str(opentelemetry)
     -> telemetry.sdk.version: Str(1.27.0)
     -> service.name: Str(ubuntu-otel-sample)
ScopeLogs #0
ScopeLogs SchemaURL: 
InstrumentationScope opentelemetry.sdk._logs._internal 
LogRecord #0
ObservedTimestamp: 2025-10-22 15:16:27.928479 +0000 UTC
Timestamp: 2025-10-22 15:16:27.828479 +0000 UTC
SeverityText: WARN
SeverityNumber: Warn(13)
Body: Str(Child operation executed custom)
Attributes:
     -> iteration: Int(1)
     -> mrid: Str(Child1MRID)
     -> ns: Str(user.XXXXXXX)
     -> region: Str(work-01.xxxx.xxxxxx)
Trace ID: 
Span ID: 
Flags: 1
LogRecord #1
ObservedTimestamp: 2025-10-22 15:16:27.928479 +0000 UTC
Timestamp: 2025-10-22 15:16:27.828479 +0000 UTC
SeverityText: INFO
SeverityNumber: Info(9)
Body: Str(Parent operation completed)
Attributes:
     -> iteration: Int(1)
     -> mrid: Str(mr-opentelemetry)
     -> ns: Str(user.XXXXXXX)
     -> region: Str(work-01.xxxx.xxxxxx)
Trace ID: 
Span ID: 
Flags: 1
	{"resource": {"service.instance.id": "847244f9-eef5-457a-afa3-4ddd32ff2711", "service.name": "monitoring-otelcol", "service.version": "v0.135.0"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "logs"}
2025-10-22T15:16:28.023Z	info	ResourceMetrics #0
Resource SchemaURL: 
Resource attributes:
     -> telemetry.sdk.language: Str(python)
     -> telemetry.sdk.name: Str(opentelemetry)
     -> telemetry.sdk.version: Str(1.27.0)
     -> service.name: Str(ubuntu-otel-sample)
ScopeMetrics #0
ScopeMetrics SchemaURL: 
InstrumentationScope __main__ 
Metric #0
Descriptor:
     -> Name: demo_requests_total
     -> Description: Número de requests simuladas
     -> Unit: 1
     -> DataType: Sum
     -> IsMonotonic: true
     -> AggregationTemporality: Cumulative
NumberDataPoints #0
Data point attributes:
     -> route: Str(/child1)
     -> method: Str(GET)
     -> mrid: Str(autogen)
StartTimestamp: 2025-10-22 15:16:27.828479 +0000 UTC
Timestamp: 2025-10-22 15:16:27.928479 +0000 UTC
Value: 5
NumberDataPoints #1
Data point attributes:
     -> route: Str(/grandchild1)
     -> method: Str(POST)
     -> mrid: Str(autogen)
StartTimestamp: 2025-10-22 15:16:27.828479 +0000 UTC
Timestamp: 2025-10-22 15:16:27.928479 +0000 UTC
Value: 3
Metric #1
Descriptor:
     -> Name: demo_cpu_usage
     -> Description: Uso CPU simulado
     -> Unit: percent
     -> DataType: Gauge
NumberDataPoints #0
Data point attributes:
     -> unit: Str(percent)
StartTimestamp: 1970-01-01 00:00:00 +0000 UTC
Timestamp: 2025-10-22 15:16:27.828479 +0000 UTC
Value: 42
	{"resource": {"service.instance.id": "847244f9-eef5-457a-afa3-4ddd32ff2711", "service.name": "monitoring-otelcol", "service.version": "v0.135.0"}, "otelcol.component.id": "debug", "otelcol.component.kind": "exporter", "otelcol.signal": "metrics"}
```