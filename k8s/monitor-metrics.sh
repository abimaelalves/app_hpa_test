#!/bin/bash

# Script para monitorar qual métrica (CPU ou Memória) está causando escalonamento

echo "═══════════════════════════════════════════════════════════"
echo "   Monitor de Métricas HPA - Qual está escalando?"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Configuração atual do HPA:"
echo "  - CPU Limit: 50% de utilização"
echo "  - MEMORY Limit: 70% de utilização"
echo "  - Min Replicas: 1"
echo "  - Max Replicas: 11"
echo ""
echo "O HPA escala quando QUALQUER uma das métricas atinge seu limite"
echo "Métrica que atinge PRIMEIRO = ela é o fator limitante"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""

while true; do
  clear
  echo "📊 MONITORAMENTO DE MÉTRICAS HPA"
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  
  # Obter informações do HPA
  echo "🎯 STATUS DO HPA:"
  kubectl get hpa -n hello-app -o custom-columns=NAME:.metadata.name,REFERENCE:.spec.scaleTargetRef.kind,TARGETS:.status.currentMetrics[*].resource.name,CPU:.status.currentMetrics[0].resource.current.averageUtilization,MEM:.status.currentMetrics[1].resource.current.averageUtilization,REPLICAS:.status.currentReplicas,MAXREPS:.spec.maxReplicas 2>/dev/null || echo "HPA não encontrado"
  
  echo ""
  echo "📈 DETALHES DAS MÉTRICAS:"
  kubectl get hpa hello-app -n hello-app -o jsonpath='{range .status.currentMetrics[*]}{.type}{" - "}{.resource.name}{": "}{.resource.current.averageUtilization}{"%"}{"\n"}{end}' 2>/dev/null
  
  echo ""
  echo "📊 CPU vs MEMORY:"
  CPU=$(kubectl get hpa hello-app -n hello-app -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2>/dev/null)
  MEM=$(kubectl get hpa hello-app -n hello-app -o jsonpath='{.status.currentMetrics[1].resource.current.averageUtilization}' 2>/dev/null)
  REPLICAS=$(kubectl get hpa hello-app -n hello-app -o jsonpath='{.status.currentReplicas}' 2>/dev/null)
  
  if [ -z "$CPU" ]; then CPU="N/A"; fi
  if [ -z "$MEM" ]; then MEM="N/A"; fi
  
  echo "  CPU Atual: $CPU% (Limite: 50%)"
  echo "  MEM Atual: $MEM% (Limite: 70%)"
  echo "  Réplicas: $REPLICAS/11"
  echo ""
  
  # Análise
  if [ "$CPU" != "N/A" ] && [ "$MEM" != "N/A" ]; then
    CPU_NUM=$(echo $CPU | sed 's/%//')
    MEM_NUM=$(echo $MEM | sed 's/%//')
    
    CPU_DIST=$((50 - CPU_NUM))
    MEM_DIST=$((70 - MEM_NUM))
    
    echo "🔍 ANÁLISE:"
    if [ $CPU_DIST -lt $MEM_DIST ]; then
      echo "  🔴 CPU está mais próxima do limite!"
      echo "  CPU está ${CPU_DIST}% abaixo do limite (50%)"
      echo "  MEM está ${MEM_DIST}% abaixo do limite (70%)"
      echo "  ➜ HPA está escalando POR CPU"
    elif [ $MEM_DIST -lt $CPU_DIST ]; then
      echo "  🟠 MEMÓRIA está mais próxima do limite!"
      echo "  MEM está ${MEM_DIST}% abaixo do limite (70%)"
      echo "  CPU está ${CPU_DIST}% abaixo do limite (50%)"
      echo "  ➜ HPA está escalando POR MEMÓRIA"
    else
      echo "  🟡 CPU e MEMÓRIA estão próximas do limite"
      echo "  Ambas limitando igualmente"
    fi
  fi
  
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "Atualizando em 5 segundos... (Ctrl+C para sair)"
  echo "═══════════════════════════════════════════════════════════"
  sleep 5
done
