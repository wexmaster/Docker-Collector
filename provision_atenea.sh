#!/bin/bash
# ==========================================
# Script para crear recursos Atenea (MR y MU)
# ==========================================

# Configuración — personalízala antes de ejecutar
WORK="work-01"
NS="user.xxxxxx"
TOKEN="AQUITOKEN"

# ==========================================
# URLs base
MR_URL="https://mr.${WORK}.nextgen.igrupobbva"
MU_URL="https://mu.${WORK}.nextgen.igrupobbva"
AUTH_HEADER="Authorization: Bearer ${TOKEN}"
CT_HEADER="Content-Type: application/json"

# Crear carpeta temporal
mkdir -p ./json_payloads
cd ./json_payloads || exit 1

echo "Generando JSONs y ejecutando creación en $(pwd)..."
echo

# ========== 1 createMonitorResourceType ==========
cat > step1_createMonitorResourceType.json <<EOF
{
  "_id": "mr-opentelemetry-type",
  "description": "Services statuses",
  "propertiesSpec": {
    "name": "string",
    "os": "string"
  },
  "sourceOf": ["TRACES", "LOGS", "METRICS", "ALARMS"]
}
EOF

echo "1 Creando MonitorResourceType..."
STATUS1=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${MR_URL}/v0/ns/${NS}/mr-types" \
  -H "${AUTH_HEADER}" -H "${CT_HEADER}" \
  --data-binary @step1_createMonitorResourceType.json)
echo "   → HTTP ${STATUS1}"
echo


# ========== 2 createMonitorResource Grandchild1MRID ==========
cat > step2_createMonitorResource_Grandchild1MRID.json <<EOF
{
  "_id": "Grandchild1MRID",
  "mrType": "//mr.${WORK}/ns/${NS}/mr-types/mr-opentelemetry-type",
  "properties": { "name": "ubuntu", "os": "linux" }
}
EOF

echo "2 Creando MonitorResource Grandchild1MRID..."
STATUS2=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${MR_URL}/v0/ns/${NS}/mrs" \
  -H "${AUTH_HEADER}" -H "${CT_HEADER}" \
  --data-binary @step2_createMonitorResource_Grandchild1MRID.json)
echo "   → HTTP ${STATUS2}"
echo


# ========== 3 createMonitorResource Child1MRID ==========
cat > step3_createMonitorResource_Child1MRID.json <<EOF
{
  "_id": "Child1MRID",
  "mrType": "//mr.${WORK}/ns/${NS}/mr-types/mr-opentelemetry-type",
  "properties": { "name": "ubuntu", "os": "linux" }
}
EOF

echo "3 Creando MonitorResource Child1MRID..."
STATUS3=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${MR_URL}/v0/ns/${NS}/mrs" \
  -H "${AUTH_HEADER}" -H "${CT_HEADER}" \
  --data-binary @step3_createMonitorResource_Child1MRID.json)
echo "   → HTTP ${STATUS3}"
echo


# ========== 4 createMonitorResource mr-opentelemetry ==========
cat > step4_createMonitorResource_mr-opentelemetry.json <<EOF
{
  "_id": "mr-opentelemetry",
  "mrType": "//mr.${WORK}/ns/${NS}/mr-types/mr-opentelemetry-type",
  "properties": { "name": "ubuntu", "os": "linux" }
}
EOF

echo "4 Creando MonitorResource principal mr-opentelemetry..."
STATUS4=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${MR_URL}/v0/ns/${NS}/mrs" \
  -H "${AUTH_HEADER}" -H "${CT_HEADER}" \
  --data-binary @step4_createMonitorResource_mr-opentelemetry.json)
echo "   → HTTP ${STATUS4}"
echo


# ========== 5 createMetric integer ==========
cat > step5_createMetric_integer.json <<EOF
{
  "_id": "integer",
  "dataType": "integer",
  "dataUnit": "NONE",
  "description": "integer Data"
}
EOF

echo "5 Creando Métrica base (integer)..."
STATUS5=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${MU_URL}/v0/ns/${NS}/metrics" \
  -H "${AUTH_HEADER}" -H "${CT_HEADER}" \
  --data-binary @step5_createMetric_integer.json)
echo "   → HTTP ${STATUS5}"
echo


# ========== 6 createMetricSetType opentelemetry_metrics ==========
cat > step6_createMetricSetType_opentelemetry_metrics.json <<EOF
{
  "_id": "opentelemetry_metrics",
  "metricsSpec": {
    "demo_cpu_usage": "//mu.${WORK}/ns/${NS}/metrics/integer",
    "demo_requests_total": "//mu.${WORK}/ns/${NS}/metrics/integer"
  }
}
EOF

echo "6 Creando MetricSetType opentelemetry_metrics..."
STATUS6=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${MU_URL}/v0/ns/${NS}/metric-set-types" \
  -H "${AUTH_HEADER}" -H "${CT_HEADER}" \
  --data-binary @step6_createMetricSetType_opentelemetry_metrics.json)
echo "   → HTTP ${STATUS6}"
echo


# ========== 7 createMetricSet opentelemetry_metrics ==========
cat > step7_createMetricSet_opentelemetry_metrics.json <<EOF
{
  "_id": "opentelemetry_metrics",
  "metricSetType": "//mu.${WORK}/ns/${NS}/metric-set-types/opentelemetry_metrics",
  "monitoredResource": "//mr.${WORK}/ns/${NS}/mrs/mr-opentelemetry"
}
EOF

echo "7 Creando MetricSet opentelemetry_metrics..."
STATUS7=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST "${MU_URL}/v0/ns/${NS}/metric-sets" \
  -H "${AUTH_HEADER}" -H "${CT_HEADER}" \
  --data-binary @step7_createMetricSet_opentelemetry_metrics.json)
echo "   → HTTP ${STATUS7}"
echo


# ==========================================
#  RESUMEN FINAL
# ==========================================
echo "========================="
echo "   RESUMEN DE ESTADOS"
echo "========================="
echo "1  MonitorResourceType ............. HTTP ${STATUS1}"
echo "2  MR Grandchild1MRID .............. HTTP ${STATUS2}"
echo "3  MR Child1MRID ................... HTTP ${STATUS3}"
echo "4  MR mr-opentelemetry ............. HTTP ${STATUS4}"
echo "5  Métrica base .................... HTTP ${STATUS5}"
echo "6  MetricSetType ................... HTTP ${STATUS6}"
echo "7  MetricSet ....................... HTTP ${STATUS7}"
echo "========================="
echo
echo "Archivos JSON generados en $(pwd)"
echo "Proceso completo."
