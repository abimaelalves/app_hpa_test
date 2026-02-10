package com.example;

import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;

public class App {
    public static void main(String[] args) throws IOException {
        int port = 8080;
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        
        // Usar um router único para evitar conflito de contextos
        server.createContext("/", exchange -> routeRequest(exchange));
        
        server.setExecutor(null);
        server.start();
        
        System.out.println("✓ Server started on port " + port);
        System.out.println("✓ Try: http://localhost:8080");
        System.out.println("✓ Health: http://localhost:8080/health");
        System.out.println("✓ Hello: http://localhost:8080/api/hello");
        System.out.println("✓ Compute: http://localhost:8080/api/compute?iterations=1000");
    }
    
    private static void routeRequest(HttpExchange exchange) throws IOException {
        String path = exchange.getRequestURI().getPath();
        System.out.println("Request path: " + path);
        
        if (path.equals("/")) {
            handleRequest(exchange);
        } else if (path.equals("/health")) {
            handleHealth(exchange);
        } else if (path.equals("/api/hello")) {
            handleHello(exchange);
        } else if (path.equals("/api/compute")) {
            handleCompute(exchange);
        } else {
            String response = "{\"error\":\"endpoint not found\"}";
            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(404, response.getBytes().length);
            OutputStream os = exchange.getResponseBody();
            os.write(response.getBytes());
            os.close();
        }
    }
    
    private static void handleRequest(HttpExchange exchange) throws IOException {
        String response = "<!DOCTYPE html>\n" +
            "<html>\n" +
            "<head><title>Hello App</title></head>\n" +
            "<body>\n" +
            "  <h1>✓ Welcome to Java App!</h1>\n" +
            "  <p>Application is running successfully</p>\n" +
            "  <ul>\n" +
            "    <li><a href=\"/health\">Health Check</a></li>\n" +
            "    <li><a href=\"/api/hello\">API Hello</a></li>\n" +
            "  </ul>\n" +
            "</body>\n" +
            "</html>";
        
        exchange.getResponseHeaders().set("Content-Type", "text/html; charset=UTF-8");
        exchange.sendResponseHeaders(200, response.getBytes().length);
        OutputStream os = exchange.getResponseBody();
        os.write(response.getBytes());
        os.close();
    }
    
    private static void handleHealth(HttpExchange exchange) throws IOException {
        String response = "{\"status\":\"UP\",\"application\":\"hello-app\"}";
        exchange.getResponseHeaders().set("Content-Type", "application/json");
        exchange.sendResponseHeaders(200, response.getBytes().length);
        OutputStream os = exchange.getResponseBody();
        os.write(response.getBytes());
        os.close();
    }
    
    private static void handleHello(HttpExchange exchange) throws IOException {
        String name = "World";
        String query = exchange.getRequestURI().getQuery();
        
        if (query != null && query.startsWith("name=")) {
            name = query.substring(5);
        }
        
        String response = "{\"message\":\"Hello, " + name + "!\"}";
        exchange.getResponseHeaders().set("Content-Type", "application/json");
        exchange.sendResponseHeaders(200, response.getBytes().length);
        OutputStream os = exchange.getResponseBody();
        os.write(response.getBytes());
        os.close();
    }
    
    private static void handleCompute(HttpExchange exchange) throws IOException {
        long iterations = 1000;
        String query = exchange.getRequestURI().getQuery();
        
        if (query != null && query.startsWith("iterations=")) {
            try {
                iterations = Long.parseLong(query.substring(11));
            } catch (NumberFormatException e) {
                iterations = 1000;
            }
        }
        
        long startTime = System.currentTimeMillis();
        
        // Simular processamento intensivo: calcular números primos
        long primeCount = countPrimes(iterations);
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        String response = String.format(
            "{\"iterations\":%d,\"primes_found\":%d,\"duration_ms\":%d,\"memory_used\":\"%.2f MB\"}",
            iterations,
            primeCount,
            duration,
            (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / (1024.0 * 1024.0)
        );
        
        exchange.getResponseHeaders().set("Content-Type", "application/json");
        exchange.sendResponseHeaders(200, response.getBytes().length);
        OutputStream os = exchange.getResponseBody();
        os.write(response.getBytes());
        os.close();
    }
    
    private static long countPrimes(long limit) {
        long count = 0;
        
        for (long num = 2; num <= limit; num++) {
            if (isPrime(num)) {
                count++;
            }
        }
        
        // Operações adicionais para aumentar a carga
        double[] dataArray = new double[(int)(limit / 10)];
        for (int i = 0; i < dataArray.length; i++) {
            dataArray[i] = Math.sqrt(i) * Math.sin(i) * Math.cos(i);
        }
        
        // Processamento em memória
        long sum = 0;
        for (double value : dataArray) {
            sum += (long)value;
        }
        
        return count + (sum > 0 ? sum % 1000 : 0);
    }
    
    private static boolean isPrime(long num) {
        if (num <= 1) return false;
        if (num <= 3) return true;
        if (num % 2 == 0 || num % 3 == 0) return false;
        
        for (long i = 5; i * i <= num; i += 6) {
            if (num % i == 0 || num % (i + 2) == 0) {
                return false;
            }
        }
        return true;
    }
}
