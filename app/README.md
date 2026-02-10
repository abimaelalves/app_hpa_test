# Java Application with Docker

Aplicação Java simples empacotada com Dockerfile usando multi-stage build.

## Estrutura

- **Stage 1 (Builder)**: Maven 3.8.1 com OpenJDK 11 para compilar o código
- **Stage 2 (Runtime)**: OpenJDK 11 JRE slim com apenas o JAR compilado

## Build

```bash
docker build -t hello-app:latest .
```

## Run

```bash
docker run -p 8080:8080 hello-app:latest
```

## Testar

### Home page
```bash
curl http://localhost:8080
```

### Health check
```bash
curl http://localhost:8080/health
```

### API Hello
```bash
curl http://localhost:8080/api/hello?name=Docker
```

## Tamanho da imagem

A imagem com multi-stage build é muito menor porque usa apenas o JRE (não inclui compilador Maven).

```bash
docker images hello-app
```

## Parar o container

```bash
docker stop <container-id>
```
