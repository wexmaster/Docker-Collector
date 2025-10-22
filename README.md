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