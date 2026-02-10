# 🎯 RESPOSTA: Como Identificar se está Escalando por CPU ou Memória?

## ⚡ Resposta Rápida

**Configuração do HPA:**
- 🔴 **CPU Limit**: 50% de utilização
- 🟠 **Memory Limit**: 70% de utilização

O HPA escala quando **QUALQUER UM** ultrapassa seu limite. **Aquele que ficar mais próximo do limite é o causador do escalonamento.**

---

## 📊 Exemplo Prático

Quando você vê no `kubectl get hpa hello-app -n hello-app -o wide`:

```
TARGETS: 42%/50%, 58%/70%
REPLICAS: 5
```

**Interpretação:**
- CPU: 42% (ainda tem 8% para o limite)
- Memory: 58% (ainda tem 12% para o limite)
- ➜ **CPU está mais próxima** → escala por CPU!

---

## 🛠️ 3 Formas de Verificar

### 1️⃣ Comando Simples (Recomendado)
```bash
kubectl get hpa hello-app -n hello-app -o wide
```
Leia os TARGETS: quem está mais alto, relativo ao seu limite?

### 2️⃣ Monitor em Tempo Real
```bash
bash k8s/monitor-metrics.sh
```
Script que compara automaticamente e indica qual está causando!

### 3️⃣ Comando Raw JSON
```bash
kubectl get hpa hello-app -n hello-app -o json | jq '.status.currentMetrics'
```

---

## 🚀 Durante o Teste

Execute em 2 terminais simultâneos:

**Terminal 1 - Teste:**
```bash
bash k8s/ultra-aggressive-load-test.sh
```

**Terminal 2 - Monitor de Métricas:**
```bash
bash k8s/monitor-metrics.sh
```

Você verá em tempo real qual métrica está causando o escalonamento!

---

## 📋 Tabela de Interpretação Rápida

| Cenário | CPU | Memory | Quem Escala? |
|---------|-----|--------|-------------|
| 42%/50%, 58%/70% | 42 | 58 | CPU (8% p/ limite) |
| 48%/50%, 65%/70% | 48 | 65 | CPU (2% p/ limite) |
| 45%/50%, 68%/70% | 45 | 68 | Memory (2% p/ limite) |
| 51%/50%, 68%/70% | 51 | 68 | AMBAS! (CPU passou) |

---

## 🔍 Como Saber Qual Está Próximo?

**Fórmula simples:**
```
Distância para limite CPU = 50 - CPU_Atual
Distância para limite Memory = 70 - Memory_Atual

Quem tiver MENOR distância = está mais próximo = vai escalar
```

**Exemplo:**
```
CPU: 42% → Distância = 50 - 42 = 8%
Memory: 58% → Distância = 70 - 58 = 12%

8% < 12% → CPU está mais próxima → escala por CPU
```

---

## 📊 Arquivos de Referência

- **Monitor Script**: `k8s/monitor-metrics.sh` (automatizado)
- **Documentação**: `k8s/METRICAS.md` (completa)
- **Configuração**: `k8s/k8s-resources.yaml` (linhas 101-116)

---

## ✅ Conclusão

**CPU: 50% | Memory: 70%**

Se você vir:
- CPU mais próximo de 50% → **Escalando por CPU**
- Memory mais próximo de 70% → **Escalando por Memory**
- Ambas próximas → **Ambas limitando**

**Recomendação**: Use `bash k8s/monitor-metrics.sh` para ver tudo automatizado!
