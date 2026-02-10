# 🧪 Teste de Carga HPA - Passo a Passo

## ⚡ Quick Start (3 terminais)

```bash
# Terminal 1 - Executar teste (180 segundos)
bash k8s/ultra-aggressive-load-test.sh

# Terminal 2 - Monitorar HPA
kubectl get hpa -n hello-app -w

# Terminal 3 - Monitorar Pods (opcional)
kubectl get pods -n hello-app -w
```

---

## 📋 Pré-requisitos

Antes de começar, verifique se tudo está pronto:

```bash
# 1. Verificar se o cluster está rodando
kubectl cluster-info

# 2. Verificar se a aplicação está deployada
kubectl get deployment -n hello-app

# 3. Verificar se o HPA está configurado
kubectl get hpa -n hello-app

# 4. Verificar se o port-forward está ativo (IMPORTANTE!)
kubectl port-forward -n hello-app svc/hello-app 8080:8080
```

---

## 🚀 Executar o Teste (Passo a Passo)

### Passo 1: Abra 3 Terminais

Você precisará de **3 terminais separados** para:
1. **Terminal 1**: Executar o script de teste
2. **Terminal 2**: Monitorar o HPA em tempo real  
3. **Terminal 3**: Monitorar os pods em tempo real (opcional)

---

### Passo 2: Terminal 1 - Validar a Aplicação

Antes de iniciar, faça uma requisição de teste:

```bash
curl -s "http://localhost:8080/api/compute?iterations=1000000" | head -5
```

**Esperado:** A requisição deve responder (pode levar 10-20 segundos)

---

### Passo 3: Terminal 1 - Executar o Script de Teste

```bash
cd /Users/abimael/workspace/k8s_local
bash k8s/ultra-aggressive-load-test.sh
```

**O que você vai ver:**
```
╔════════════════════════════════════════════════════════╗
║   TESTE DE CARGA ULTRA AGRESSIVO - HPA TEST v2        ║
╚════════════════════════════════════════════════════════╝

⚙️  Configuração OTIMIZADA:
   - Endpoint: http://localhost:8080/api/compute
   - Iterações por requisição: 10000000 (10 MILHÕES)
   - Requisições paralelas: 30 (controladas)
   - Duração: 180s

🚀 Iniciando teste...

⏱️  Lote 1 | Tempo: 0s / 180s | Restante: 180s | Requisições: 0
```

> ⏱️ **Duração**: ~3 minutos (180 segundos)

---

### Passo 4: Terminal 2 - Monitorar o HPA em Tempo Real

Em **outro terminal**, rode:

```bash
kubectl get hpa -n hello-app -w
```

**O que você vai ver:**
```
NAME        REFERENCE              TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
hello-app   Deployment/hello-app   15%/50%, 35%/70%   1         11        1          21m
hello-app   Deployment/hello-app   45%/50%, 55%/70%   1         11        3          21m
hello-app   Deployment/hello-app   65%/50%, 78%/70%   1         11        6          21m
hello-app   Deployment/hello-app   80%/50%, 85%/70%   1         11        9          21m
hello-app   Deployment/hello-app   70%/50%, 75%/70%   1         11        11         21m
```

**O que observar:**
- 🟢 REPLICAS aumenta conforme CPU e Memória crescem
- 📊 Vai de **1 → 3 → 6 → 9 → 11** replicas
- 📈 TARGETS mostra: `CPU_ATUAL%/LIMITE%, MEM_ATUAL%/LIMITE%`

---

### Passo 5: Terminal 3 (Opcional) - Monitorar Pods

Em um **terceiro terminal**:

```bash
kubectl get pods -n hello-app -w
```

**O que você vai ver:**
```
NAME                         READY   STATUS    RESTARTS   AGE
hello-app-59bd58b89b-2jhgj   1/1     Running   0          3m
hello-app-59bd58b89b-4qjwd   1/1     Running   0          2m
hello-app-59bd58b89b-7qjlg   1/1     Running   0          3m
hello-app-59bd58b89b-9bbzv   1/1     Running   0          2m
...
```

**O que observar:**
- 🟢 Novos pods vão aparecer (status PENDING → RUNNING)
- ⏱️ Cada pod leva ~30-60s para ficar READY
- 📊 Total vai aumentar de 1 → até 11 pods

---

### Passo 6: Acompanhar Métricas de CPU/Memória (Opcional)

Em outro terminal:

```bash
watch -n 2 'kubectl top pods -n hello-app'
```

**O que você vai ver:**
```
NAME                         CPU(cores)   MEMORY(bytes)
hello-app-59bd58b89b-2jhgj   450m         256Mi
hello-app-59bd58b89b-4qjwd   480m         264Mi
hello-app-59bd58b89b-7qjlg   470m         260Mi
```

---

## ✅ Critérios de Sucesso

O teste foi bem-sucedido se:

- ✅ **Nenhum erro "fork: Resource temporarily unavailable"**
- ✅ **HPA escala para múltiplas replicas** (mínimo 3, máximo 11)
- ✅ **Pods ficam em status RUNNING** (não CrashLoopBackOff)
- ✅ **CPU e Memória dentro dos limites esperados**
- ✅ **Script completa em ~3 minutos** sem travamentos
- ✅ **Após teste, replicas voltam para 1** (scale-down)

---

## 📊 Timeline Esperado

| Tempo | Evento |
|-------|--------|
| 0-30s | Teste inicia, CPU aumenta, HPA começa a escalar |
| 30-60s | 3-6 replicas ativas, requisições sendo processadas |
| 60-120s | Pico de 9-11 replicas, CPU/Memória no máximo |
| 120-180s | Teste reduz carga, HPA mantém replicas altas |
| 180s+ | Teste termina, requisições completam, scale-down inicia |
| 180-300s | Replicas voltam gradualmente para 1 |

---

## 🔧 Monitoramento Completo em Um Terminal

Se preferir ver tudo em um único terminal:

```bash
watch -n 2 'echo "=== HPA ===" && kubectl get hpa -n hello-app && echo "" && echo "=== PODS ===" && kubectl get pods -n hello-app --no-headers | wc -l && echo "replicas" && echo "" && echo "=== CPU/MEM ===" && kubectl top pods -n hello-app 2>/dev/null | head -5'
```

---

## 🛑 Interromper o Teste

Se precisar parar o teste antes de completar:

```bash
# Terminal 1 - Parar o script
Ctrl + C

# Limpar jobs em background (se houver)
killall curl
```

---

## 📝 Checklist de Testes

Copie e preencha enquanto testa:

```
[ ] Pré-requisitos verificados
[ ] Terminal 1: Script iniciado com sucesso
[ ] Terminal 2: HPA começou a monitorar
[ ] Terminal 3: Pods começaram a aparecer
[ ] HPA escalonou para 3+ replicas
[ ] HPA escalonou para 6+ replicas  
[ ] HPA escalonou para 9+ replicas (ou máximo)
[ ] Nenhum erro "fork" ou "CrashLoopBackOff"
[ ] Script completou após ~3 minutos
[ ] HPA escalou para trás (scale-down)
[ ] Replicas voltaram para 1
```

---

## 🐛 Troubleshooting

### Erro: "fork: Resource temporarily unavailable"
**Solução**: Use uma versão anterior do script (menos agressiva)
```bash
# Editar e reduzir CONCURRENT_REQUESTS para 10-15
vi k8s/ultra-aggressive-load-test.sh
```

### Erro: "Connection refused"
**Solução**: Port-forward não está ativo
```bash
kubectl port-forward -n hello-app svc/hello-app 8080:8080
```

### Pods em CrashLoopBackOff
**Solução**: Aumentar limites de memória/CPU na aplicação

### HPA não escala
**Solução**: Verificar se métricas estão disponíveis
```bash
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes
```

---

## 📝 Referências

- [HPA Documentation](k8s/HPA.md)
- Configuração do Kubernetes: `k8s/k8s-resources.yaml`
- Script de teste: `k8s/ultra-aggressive-load-test.sh`

---

**Boa sorte no teste! 🚀**
