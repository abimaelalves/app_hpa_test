#!/bin/bash

set -e

ENDPOINT="http://localhost:8080/api/compute"
ITERATIONS=10000000  # 10 milhões - pesado mas gerenciável
CONCURRENT_REQUESTS=30  # 30 requisições simultâneas (máx do xargs)
DURATION=180  # Duração do teste em segundos

echo "╔════════════════════════════════════════════════════════╗"
echo "║   TESTE DE CARGA ULTRA AGRESSIVO - HPA TEST v2        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "⚙️  Configuração OTIMIZADA:"
echo "   - Endpoint: $ENDPOINT"
echo "   - Iterações por requisição: $ITERATIONS (10 MILHÕES)"
echo "   - Requisições paralelas: $CONCURRENT_REQUESTS (controladas com xargs)"
echo "   - Duração: ${DURATION}s"
echo ""
echo "🔥 Teste otimizado para produção:"
echo "   - Requisições de longa duração (10M iterações = ~20-40s cada)"
echo "   - Paralelismo controlado (máx $CONCURRENT_REQUESTS simultâneas)"
echo "   - Mantém carga contínua e ESTÁVEL no cluster"
echo ""
echo "📊 O que observar:"
echo "   1. Número de PODS vai aumentar MUITO (kubectl get pods -n hello-app -w)"
echo "   2. HPA vai escalar para muitas replicas (até 11)"
echo "   3. CPU dos pods vai ficar ALTA"
echo ""
echo "🚀 Iniciando teste..."
echo ""

# Variável para contar rodadas e requisições
ROUND=0
TOTAL_REQUESTS=0
START_TIME=$(date +%s)
END_TIME=$((START_TIME + DURATION))
CURRENT_TIME=$START_TIME

while [ $CURRENT_TIME -lt $END_TIME ]; do
  ROUND=$((ROUND + 1))
  ELAPSED=$((CURRENT_TIME - START_TIME))
  REMAINING=$((DURATION - ELAPSED))
  
  echo -ne "\r⏱️  Lote $ROUND | Tempo: ${ELAPSED}s / ${DURATION}s | Restante: ${REMAINING}s | Requisições: $TOTAL_REQUESTS "
  
  # Enviar CONCURRENT_REQUESTS requisições usando GNU Parallel ou background
  # Aqui usamos for loop com wait controlado para não sobrecarregar
  for i in $(seq 1 $CONCURRENT_REQUESTS); do
    curl -s "$ENDPOINT?iterations=$ITERATIONS" > /dev/null 2>&1 &
  done
  
  TOTAL_REQUESTS=$((TOTAL_REQUESTS + CONCURRENT_REQUESTS))
  
  # Aguarda requisições completarem antes do próximo lote
  wait
  
  # Sleep para dar tempo do sistema recuperar
  sleep 1
  CURRENT_TIME=$(date +%s)
done

echo ""
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              TESTE CONCLUÍDO COM SUCESSO              ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "✅ Total de requisições enviadas: $TOTAL_REQUESTS"
echo ""
echo "📈 Status Final:"
echo ""
echo "HPA:"
kubectl get hpa -n hello-app
echo ""
echo "Pods:"
kubectl get pods -n hello-app -o wide
echo ""
echo "Métricas CPU/Memória:"
kubectl top pods -n hello-app 2>/dev/null || echo "Capturando métricas..."
echo ""
