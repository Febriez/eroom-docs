# 4.1 서버 개발 개요

## 🎯 **서버 개발 목표**

### **핵심 책임**
- **AI 기반 방탈출 맵 자동 생성**: Claude 4 Sonnet을 활용한 지능형 시나리오 및 스크립트 생성
- **3D 모델 파이프라인**: MeshyAI API를 통한 비동기 3D 모델 생성 및 추적
- **요청 큐 관리**: 동시 처리 제한을 통한 안정적인 서비스 제공
- **통합 REST API 서버**: Unity 클라이언트와의 효율적인 통신 인터페이스 제공

### **기술적 목표**
- **안정성**: 큐 기반 요청 관리로 서버 과부하 방지
- **확장성**: 동시 처리 수 조정 가능한 모듈화된 아키텍처
- **모니터링**: 실시간 큐 상태 조회 및 상세한 로깅
- **고성능**: Undertow 기반 논블로킹 I/O와 비동기 처리

## 🏗️ **서버 아키텍처**

### **전체 구조도**
```mermaid
graph TB
   A[Unity Client] -->|HTTP Request| B[Undertow Server]
   B --> C[ApiHandler]
   C --> D[RoomRequestQueueManager]
   D --> E[BlockingQueue]
   D --> F[Semaphore 동시성 제어]
   D --> G[RoomServiceImpl]
   G --> H[AnthropicService]
   G --> I[MeshyService]
   H -->|AI API| J[Claude 4 Sonnet]
   I -->|3D API| K[MeshyAI]

   B --> L[RoutingHandler]
   L --> M[/health + 큐 상태]
L --> N[/room/create + 큐 제출]
L --> O[/queue/status]
L --> P[/]
```

### **Undertow 서버 초기화**
```java
public class UndertowServer {
    // 동시 처리 제한 (확장 시 이 값만 변경)
    private static final int MAX_CONCURRENT_REQUESTS = 1;
    
    public UndertowServer(int port) {
        // 서비스 초기화
        AnthropicService anthropicService = new AnthropicService(apiKeyConfig, configUtil);
        MeshyService meshyService = new MeshyService(apiKeyConfig);
        RoomServiceImpl roomService = new RoomServiceImpl(anthropicService, meshyService, configUtil);
        
        // 큐 매니저 생성
        queueManager = new RoomRequestQueueManager(roomService, MAX_CONCURRENT_REQUESTS);
        
        // 라우팅 설정
        RoutingHandler routingHandler = Handlers.routing()
                .get("/", apiHandler::handleRoot)
                .get("/health", apiHandler::handleHealth)
                .get("/queue/status", apiHandler::handleQueueStatus)
                .post("/room/create", apiHandler::handleRoomCreate);
        
        // 서버 생성
        server = Undertow.builder()
                .addHttpListener(port, "0.0.0.0")
                .setHandler(routingHandler)
                .build();
    }
}
```

## 🚦 **큐 관리 시스템**

### **RoomRequestQueueManager 구조**
```java
public class RoomRequestQueueManager {
    private final int maxConcurrentRequests;
    private final ExecutorService executorService;
    private final BlockingQueue<QueuedRequest> requestQueue;
    private final Semaphore concurrencyLimiter;
    
    // 상태 추적용 AtomicInteger
    private final AtomicInteger queuedRequests = new AtomicInteger(0);
    private final AtomicInteger activeRequests = new AtomicInteger(0);
    private final AtomicInteger completedRequests = new AtomicInteger(0);
    
    public CompletableFuture<JsonObject> submitRequest(RoomCreationRequest request) {
        CompletableFuture<JsonObject> future = new CompletableFuture<>();
        QueuedRequest queuedRequest = new QueuedRequest(request, future);
        
        requestQueue.offer(queuedRequest);
        queuedRequests.incrementAndGet();
        
        return future;
    }
}
```

### **큐 처리 워커 스레드**
```java
private void startQueueProcessor() {
    Thread processorThread = new Thread(() -> {
        while (!Thread.currentThread().isInterrupted()) {
            try {
                // 큐에서 요청 가져오기 (블로킹)
                QueuedRequest queuedRequest = requestQueue.take();
                queuedRequests.decrementAndGet();
                
                // Semaphore로 동시 실행 제어
                concurrencyLimiter.acquire();
                
                // 요청 처리
                processRequest(queuedRequest);
                
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }, "RoomRequestQueueProcessor");
    
    processorThread.setDaemon(true);
    processorThread.start();
}
```

### **큐 상태 모니터링**
```java
public record QueueStatus(int queued, int active, int completed, int maxConcurrent) {
    @Override
    public String toString() {
        return String.format("QueueStatus{queued=%d, active=%d, completed=%d, maxConcurrent=%d}",
                queued, active, completed, maxConcurrent);
    }
}
```

## 📊 **REST API 엔드포인트**

### **1. 루트 상태 API**
```http
GET /
Content-Type: application/json

Response:
{
  "status": "online",
  "message": "Eroom 서버가 작동 중입니다"
}
```

### **2. 헬스체크 API (큐 상태 포함)**
```http
GET /health
Content-Type: application/json

Response:
{
  "status": "healthy",
  "queue": {
    "queued": 3,      // 대기 중인 요청 수
    "active": 1,      // 현재 처리 중인 요청 수
    "completed": 15,  // 총 완료된 요청 수
    "maxConcurrent": 1 // 최대 동시 처리 수
  }
}
```

### **3. 큐 상태 조회 API**
```http
GET /queue/status
Content-Type: application/json

Response:
{
  "queued": 3,
  "active": 1,
  "completed": 15,
  "maxConcurrent": 1
}
```

### **4. 방 생성 API (큐 기반 비동기 처리)**
```http
POST /room/create
Content-Type: application/json

Request:
{
  "uuid": "unique-session-id",
  "theme": "고딕 도서관",
  "keywords": ["책", "촛불", "비밀문서"],
  "difficulty": "normal",
  "room_prefab": "https://example.com/room.prefab"
}

Response:
{
  "uuid": "unique-session-id",
  "puid": "room_abc123def456",
  "theme": "고딕 도서관",
  "difficulty": "normal",
  "keywords": ["책", "촛불", "비밀문서"],
  "room_prefab": "https://example.com/room.prefab",
  "scenario": { /* AI 생성 시나리오 */ },
  "scripts": { 
    "GameManager.cs": "base64_encoded_script",
    "BookShelf.cs": "base64_encoded_script"
  },
  "model_tracking": {
    "BookShelf": "meshy_tracking_id_123",
    "Candle": "meshy_tracking_id_456"
  },
  "success": true,
  "timestamp": "1702345678901"
}
```

## ⚡ **비동기 처리 시스템**

### **ApiHandler의 비동기 응답**
```java
public void handleRoomCreate(@NotNull HttpServerExchange exchange) {
    if (exchange.isInIoThread()) {
        exchange.dispatch(this::handleRoomCreate);
        return;
    }

    try {
        String requestBody = getRequestBody(exchange);
        RoomCreationRequest request = gson.fromJson(requestBody, RoomCreationRequest.class);
        
        // 큐에 요청 제출
        CompletableFuture<JsonObject> future = queueManager.submitRequest(request);

        // 비동기로 결과 대기 및 응답 전송
        future.whenComplete((result, throwable) -> {
            if (throwable != null) {
                JsonObject errorResponse = new JsonObject();
                errorResponse.addProperty("error", throwable.getMessage());
                sendResponse(exchange, 500, errorResponse.toString());
            } else {
                sendResponse(exchange, 200, result.toString());
            }
        });

    } catch (Exception e) {
        // 즉시 에러 응답
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("error", e.getMessage());
        sendResponse(exchange, 500, errorResponse.toString());
    }
}
```

### **안전한 응답 전송**
```java
private void sendResponse(@NotNull HttpServerExchange exchange, int statusCode, @NotNull String body) {
    if (!exchange.isResponseStarted()) {
        exchange.setStatusCode(statusCode);
        exchange.getResponseSender().send(ByteBuffer.wrap(body.getBytes(StandardCharsets.UTF_8)));
    }
}
```

## 🔧 **프로젝트 구조**

### **패키지 구조**
```
src/main/java/com/febrie/eroom/
├── Main.java                           # 애플리케이션 진입점
├── config/                             # 설정 관리
│   ├── ApiKeyConfig.java               # API 키 관리
│   └── GsonConfig.java                 # JSON 직렬화 설정
├── server/                             # 서버 계층
│   └── UndertowServer.java             # Undertow 서버 설정
├── handler/                            # HTTP 요청 처리
│   └── ApiHandler.java                 # REST API 핸들러
├── service/                            # 비즈니스 로직
│   ├── AnthropicService.java           # AI 시나리오 생성
│   ├── MeshyService.java               # 3D 모델 생성
│   ├── RoomRequestQueueManager.java    # 요청 큐 관리 ⭐ 새로 추가
│   ├── RoomService.java                # 방 생성 인터페이스
│   └── impl/
│       └── RoomServiceImpl.java        # 방 생성 구현체
├── model/                              # 데이터 모델
│   ├── RoomCreationRequest.java        # 요청 DTO
│   ├── RoomCreationResponse.java       # 응답 DTO
│   └── ModelGenerationResult.java      # 모델 생성 결과
├── util/                               # 유틸리티
│   └── ConfigUtil.java                 # 설정 파일 관리
└── exception/                          # 예외 처리
    └── NoAvailableKeyException.java
```

## 📈 **성능 지표**

### **큐 관리 성능**
```yaml
동시 처리 제한: 1개 요청 (현재 설정)
큐 용량: 무제한 (LinkedBlockingQueue)
처리 방식: FIFO (First In, First Out)
응답 시간: 
  - 큐 추가: < 1ms
  - 전체 처리: 45-60초 (AI 처리 시간 포함)

큐 상태 추적:
  - 대기 중: queuedRequests.get()
  - 처리 중: activeRequests.get()
  - 완료됨: completedRequests.get()
```

### **메모리 사용량**
```yaml
기본 메모리: 180MB
큐 처리 중: 420-650MB
피크 사용량: 890MB
GC 빈도: 8-15초마다 Young GC
안정성: 메모리 누수 없음
```

## 🔧 **주요 기술 스택**

### **Core Framework**
- **Java 17**: 최신 LTS 버전으로 성능 최적화
- **Undertow 2.3+**: 고성능 웹 서버
- **Maven**: 의존성 관리 및 빌드 도구

### **동시성 제어**
```xml
<dependencies>
    <!-- Java 기본 동시성 라이브러리 활용 -->
    <!-- BlockingQueue, Semaphore, CompletableFuture -->
    
    <!-- Anthropic Claude API -->
    <dependency>
        <groupId>com.anthropic</groupId>
        <artifactId>anthropic-java</artifactId>
        <version>0.1.0-alpha.4</version>
    </dependency>
    
    <!-- HTTP Client for MeshyAI -->
    <dependency>
        <groupId>com.squareup.okhttp3</groupId>
        <artifactId>okhttp</artifactId>
        <version>4.12.0</version>
    </dependency>
</dependencies>
```

### **확장성 설계**
```java
// 서버 확장 시 이 값만 변경하면 됨
private static final int MAX_CONCURRENT_REQUESTS = 1;  // → 5, 10, 20 등으로 확장 가능

// Semaphore와 ExecutorService가 자동으로 확장됨
this.concurrencyLimiter = new Semaphore(maxConcurrentRequests);
this.executorService = Executors.newFixedThreadPool(maxConcurrentRequests);
```

## 🛡️ **안정성 보장**

### **Graceful Shutdown**
```java
public void stop() {
    if (server != null) {
        log.info("서버 종료 시작...");

        // 1. 큐 매니저 종료
        if (queueManager != null) {
            queueManager.shutdown();
        }

        // 2. RoomService 종료
        if (roomService != null) {
            try {
                roomService.close();
            } catch (Exception e) {
                log.error("RoomService 종료 중 오류", e);
            }
        }

        // 3. 서버 종료
        server.stop();
        log.info("서버가 중지되었습니다");
    }
}
```

### **에러 처리**
- **큐 레벨**: 요청 추가 실패 시 즉시 에러 응답
- **처리 레벨**: 비동기 처리 중 예외 발생 시 CompletableFuture로 전파
- **응답 레벨**: 중복 응답 방지 (`!exchange.isResponseStarted()` 검사)

## 👥 **담당자**
**작성자**: 옥병준  
**최종 수정일**: 2025-06-11  
**문서 버전**: v2.0

---

> 💡 **실제 코드 위치**: `com.febrie.eroom.server.UndertowServer`, `com.febrie.eroom.service.RoomRequestQueueManager`