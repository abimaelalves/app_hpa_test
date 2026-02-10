# 📊 Como Identificar se está escalando por CPU ou Memória?

## ⚙️ Configuração Atual

```yaml
metrics:
  - CPU: 50% de utilização (threshold)
  - MEMORY: 70% de utilização (threshold)
```

O HPA escala quando **QUALQUER** uma das métricas atinge seu limite.

---

## 🔍 Identificar a Métrica Limitante

### Método 1: Comando Simples

```bash
kubectl get hpa hello-app -n hello-app -o wide
```

**Saída esperada:**
```
NAME        REFERENCE              TARGETS           MINPODS   MAXPODS   REPLICAS
hello-app   Deployment/hello-app   42%/50%, 58%/70%   1         11        5
```

**Como ler:**
- `42%/50%` = CPU em 42% (limite é 50%) ✅ OK
- `58%/70%` = MEMORY em 58% (limite é 70%) ✅ OK

Se vê `52%/50%, 58%/70%` → **CPU ultrapassou o limite** = escalando por CPU

---

### Método 2: Monitor em Tempo Real (Recomendado)

```bash
bash k8s/monitor-metrics.sh
```

**Saída:**
```
📊 MONITORAMENTO DE MÉTRICAS HPA
═══════════════════════════════════════════════════════════

🎯 STATUS DO HPA:
NAME        REFERENCE   TARGETS           CPU    MEM    REPLICAS   MAXREPS
hello-app   Deployment  cpu,memory        45     62     6          11

📈 DETALHES DAS MÉTRICAS:
Resource - cpu: 45%
Resource - memory: 62%

📊 CPU vs MEMORY:
  CPU Atual: 45% (Limite: 50%)
  MEM Atual: 62% (Limite: 70%)
  Réplicas: 6/11

🔍 ANÁLISE:
  🟡 CPU e MEMÓRIA estão próximas do limite
  CPU está 5% abaixo do limite (50%)
  MEM está 8% abaixo do limite (70%)
  ➜ HPA está escalando POR CPU (mais próxima do limite)
```

---

### Método 3: Formato JSON Detalhado

```bash
kubectl get hpa hello-app -n hello-app -o json | jq '.status.currentMetrics'
```

**Saída:**
```json
[
  {
    "type": "Resource",
    "resource": {
      "name": "cpu",
      "current": {
        "averageUtilization": 42
      }
    }
  },
  {
    "type": "Resource",
    "resource": {
      "name": "memory",
      "current": {
        "averageUtilization": 58
      }
    }
  }
]
```

---

## 📋 Tabela de Interpretação

| CPU | Memory | Quem Escala? | Ação |
|-----|--------|-------------|------|
| 45% | 62% | MEMÓRIA (mais perto) | Aumentar Memory Limit ou aplicação usa mais memória |
| 48% | 65% | CPU (mais perto) | Aumentar CPU Limit ou código é ineficiente |
| 51% | 68% | AMBAS (perto) | Otimizar código ou aumentar ambas |
| 30% | 50% | MEMÓRIA (passou) | Memória é o bottleneck |

---

## 🚀 Durante o Teste

Enquanto `ultra-aggressive-load-test.sh` roda:

**Terminal 1**: Teste rodando
```bash
bash k8s/ultra-aggressive-load-test.sh
```

**Terminal 2**: Monitorar métrica limitante
```bash
bash k8s/monitor-metrics.sh
```

Você verá em tempo real qual métrica está causando o escalonamento!

---

## 💡 O Que Esperar

### Com requisições de 10 MILHÕES de iterações:

1. **Primeiros 30 segundos**:
   - CPU: 40-50% (aumenta rápido)
   - Memory: 50-60% (aumenta gradual)
   - HPA: começa a escalar por CPU

2. **30-60 segundos**:
   - CPU: 70-90% (mantém alto)
   - Memory: 70-80% (atingindo limite)
   - HPA: ambas próximas do limite

3. **60-120 segundos**:
   - CPU: 45-55% (oscila)
   - Memory: 60-70% (oscila)
   - HPA: mantém máximo de replicas

---

## 🎯 Como Interpretar "TARGETS"

Quando você vê:
```
TARGETS: 72%/50%, 68%/70%
```

**Significa:**
- CPU: 72% de utilização (ACIMA do limite de 50%)
  - HPA vai AUMENTAR replicas
- Memory: 68% de utilização (ABAIXO do limite de 70%)
  - HPA ainda quer aumentar mais

---

## 📊 Comandos Úteis

### Ver métrica de CPU apenas
```bash
kubectl get hpa hello-app -n hello-app -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}'
```

### Ver métrica de Memory apenas
```bash
kubectl get hpa hello-app -n hello-app -o jsonpath='{.status.currentMetrics[1].resource.current.averageUtilization}'
```

### Ver número de replicas
```bash
kubectl get hpa hello-app -n hello-app -o jsonpath='{.status.currentReplicas}'
```

### Ver tudo formatado
```bash
watch -n 1 'kubectl get hpa hello-app -n hello-app -o wide'
```

---

## 🔧 Para Mudar os Limites

Se quiser que scale por CPU ou Memory diferente:

```bash
# Editar HPA
kubectl edit hpa hello-app -n hello-app

# Procure por "averageUtilization" e mude os valores:
# cpu: 50       ← mude para 30 (mais sensível a CPU)
# memory: 70    ← mude para 80 (menos sensível a memory)
```

---

## ✅ Resumo Rápido

- **Monitor em tempo real**: `bash k8s/monitor-metrics.sh`
- **Ver TARGETS**: `kubectl get hpa hello-app -n hello-app -o wide`
- **Quem está escalando?**: Veja qual métrica está mais PERTO do seu limite
- **CPU Limit**: 50%
- **Memory Limit**: 70%
