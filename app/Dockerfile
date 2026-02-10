# Stage 1: Build
FROM maven:3.8.4-openjdk-11 AS builder

WORKDIR /app

# Copy apenas os arquivos de configuração primeiro (cache layer)
COPY pom.xml .

# Download dependencies
RUN mvn dependency:resolve

# Copy source code
COPY src ./src

# Compile e packerar a aplicação
RUN mvn clean package -DskipTests

# Stage 2: Runtime (imagem mínima)
FROM eclipse-temurin:11-jre-jammy

WORKDIR /app

# Copiar apenas o JAR compilado do stage anterior
COPY --from=builder /app/target/app.jar .

# Exposar porta
EXPOSE 8080

# Rodar aplicação
CMD ["java", "-jar", "app.jar"]
