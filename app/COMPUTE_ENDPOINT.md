# Endpoint de Computação Intensiva

## Descrição

Novo endpoint implementado na aplicação Java para simular processamento com carga computacional.

## Funcionalidades

- **Cálculo de números primos**: Identifica números primos até o limite especificado
- **Operações em memória**: Realiza operações matemáticas em arrays
- **Medição de performance**: Retorna tempo de execução e uso de memória
- **Parâmetro configurável**: Aceita número de iterações como parâmetro

## Endpoint

```
GET /api/compute?iterations=<número>
```

### Parâmetros

- `iterations` (opcional): Número de iterações para o cálculo (padrão: 1000)

### Resposta

```json
{
  "iterations": 10000,
  "primes_found": 1229,
  "duration_ms": 1,
  "memory_used": "6.14 MB"
}
```

### Exemplos de Uso

```bash
# Com 1000 iterações (padrão)
curl http://localhost:8080/api/compute

# Com 100 iterações
curl http://localhost:8080/api/compute?iterations=100

# Com 1 milhão de iterações
curl http://localhost:8080/api/compute?iterations=1000000
```

## Resultados de Performance

| Iterações | Primos Encontrados | Tempo (ms) | Memória |
|-----------|-------------------|-----------|---------|
| 100       | 25                | 0         | 6.14 MB |
| 1.000     | 170               | 0         | 6.14 MB |
| 10.000    | 1.229             | 1         | 6.14 MB |
| 100.000   | 9.592             | 8         | 6.63 MB |
| 1.000.000 | 78.498            | 29        | 7.63 MB |

## Casos de Uso

- Testar comportamento da aplicação sob carga
- Monitorar uso de CPU e memória
- Teste de escalabilidade horizontal no Kubernetes
- Validar alertas e métricas de performance
- Load testing com múltiplas requisições paralelas

## Implementação

A implementação simula carga computacional através de:

1. **Algoritmo de Teste de Primalidade**: Loop eficiente para encontrar números primos
2. **Operações em Array**: Manipulação de dados temporários em memória
3. **Cálculos Matemáticos**: Operações trigonométricas e de raiz quadrada
4. **Medição**: Captura de tempo e uso de memória do JVM
