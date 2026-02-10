# HPA - Horizontal Pod Autoscaler Configurado

## Configuração

O HPA foi configurado com as seguintes especificações:

### Limites

- **Mínimo de Replicas**: 1
- **Máximo de Replicas**: 11

### Métricas de Escalonamento

O HPA monitora duas métricas:

1. **CPU**: Escala quando CPU atinge 50% de utilização
2. **Memória**: Escala quando memória atinge 70% de utilização

### Comportamento de Scale-Up

- Sem window de estabilização (escala imediatamente)
- Aumenta até 50% de replicas a cada 15 segundos
- Ou adiciona 2 pods a cada 15 segundos (qualquer que for maior)

### Comportamento de Scale-Down

- Window de estabilização de 300 segundos (5 minutos)
- Reduz 50% das replicas a cada 60 segundos

## Requisitos do Sistema

Para o HPA funcionar corretamente, foi necessário instalar o **Metrics Server**:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Configuração para Kind

No Kind, é necessário adicionar a flag `--kubelet-insecure-tls` ao metrics-server para pular validação de certificados:

```bash
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

## Verificando o Status

### Ver HPA

```bash
kubectl get hpa -n hello-app
kubectl describe hpa hello-app -n hello-app
```

### Ver Métricas

```bash
kubectl top nodes
kubectl top pods -n hello-app
```

### Ver Pods

```bash
kubectl get pods -n hello-app -w
```

## Testando o Autoscaling

Para forçar o scale-up, envie requisições intensivas:

```bash
# Script simples para gerar carga
for i in {1..50}; do
  curl -s "http://localhost:8080/api/compute?iterations=5000000" > /dev/null &
done
wait

# Monitorar em outro terminal
kubectl get pods -n hello-app -w
```

## Arquivos de Configuração

- [deployment.yaml](deployment.yaml): Deployment com 1 replica inicial
- [hpa.yaml](hpa.yaml): HPA configurado
- [all-in-one.yaml](all-in-one.yaml): Todos os recursos (Namespace, Deployment, Service, HPA)

## Observações

- O deployment agora inicia com apenas 1 replica (em vez de 3)
- O HPA pode escalar até 11 replicas sob carga
- As métricas são capturadas a cada 15 segundos
- O scale-down é mais conservador (demora 5 minutos)
- O endpoint `/api/compute` pode ser usado para gerar carga artificial

## Próximos Passos

Para monitorar e gerenciar melhor o autoscaling:

1. Instalar Prometheus para armazenar métricas históricas
2. Instalar Grafana para visualização de gráficos
3. Configurar alertas baseados em métricas
4. Usar ferramentas como `ab` ou `wrk` para load testing mais realista
