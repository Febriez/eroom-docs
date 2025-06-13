# 3.2 API 핸들러 구조

## 📡 API 핸들러 개요

{% hint style="info" %}

### **요청/응답 처리의 중심**

모든 HTTP 요청을 처리하고 적절한 응답을 생성하는 핵심 컴포넌트
{% endhint %}

---

## 🏗️ ApiHandler 클래스 구조

### 주요 구성 요소

```java
public class ApiHandler implements RequestHandler {
  private static final Logger log = LoggerFactory.getLogger(ApiHandler.class);

  private final Gson gson;
  private final QueueManager queueManager;
  private final JobResultStore resultStore;
  private final ResponseFormatter responseFormatter;

  public ApiHandler(Gson gson, QueueManager queueManager, JobResultStore resultStore) {
    this.gson = gson;
    this.queueManager = queueManager;
    this.resultStore = resultStore;
    this.responseFormatter = new ResponseFormatter(gson);
  }
}
```

### 의존성 관계

{% hint style="success" %}

#### 🔗 **컴포넌트 의존성**

{% mermaid %}
graph TD
A[ApiHandler] --> B[Gson]
A --> C[QueueManager]
A --> D[JobResultStore]
A --> E[ResponseFormatter]

    B --> F[JSON 직렬화]
    C --> G[요청 큐잉]
    D --> H[결과 조회]
    E --> I[일관된 응답 포맷]
    
    style A fill:#4a90e2
    style B fill:#f39c12
    style C fill:#2ecc71
    style D fill:#e74c3c
{% endmermaid %}
{% endhint %}

---

## 📋 핸들러 메서드 상세

### 1️⃣ **handleRoot() - 서버 상태**

{% hint style="success" %}

#### **GET /**

**기능:** 서버 기본 상태 확인

**구현:**

```java
@Override
public void handleRoot(HttpServerExchange exchange) {
    JsonObject response = new JsonObject();
    response.addProperty("status", "online");
    response.addProperty("message", "Eroom 서버가 작동 중입니다");
    responseFormatter.sendSuccessResponse(exchange, response);
}
```

**응답:**

```json
{
  "status": "online",
  "message": "Eroom 서버가 작동 중입니다",
  "success": true
}
```

**특징:**

- 가장 간단한 헬스체크
- 서버 동작 여부만 확인
- 응답 시간 < 10ms
  {% endhint %}

### 2️⃣ **handleHealth() - 상세 헬스체크**

{% hint style="warning" %}

#### **GET /health**

**기능:** 서버 상태와 큐 통계 제공

**구현:**

```java
@Override
public void handleHealth(HttpServerExchange exchange) {
    JsonObject response = new JsonObject();
    response.addProperty("status", "healthy");
    response.add("queue", formatQueueStatus(queueManager.getQueueStatus()));
    responseFormatter.sendSuccessResponse(exchange, response);
}

private JsonObject formatQueueStatus(QueueManager.QueueStatus status) {
    JsonObject queue = new JsonObject();
    queue.addProperty("queued", status.queued());
    queue.addProperty("active", status.active());
    queue.addProperty("completed", status.completed());
    queue.addProperty("maxConcurrent", status.maxConcurrent());
    return queue;
}
```

**응답 구조:**

```json
{
  "status": "healthy",
  "queue": {
    "queued": 3,
    "active": 1,
    "completed": 150,
    "maxConcurrent": 1
  },
  "success": true
}
```

**활용:**

- 모니터링 시스템 연동
- 부하 상태 파악
- 자동 스케일링 트리거
  {% endhint %}

### 3️⃣ **handleRoomCreate() - 룸 생성 요청**

{% hint style="info" %}

#### **POST /room/create**

**처리 플로우:**

{% mermaid %}
flowchart LR
A[요청 수신] --> B[JSON 파싱]
B --> C{검증}
C -->|성공| D[큐에 등록]
C -->|실패| E[400 에러]
D --> F[ruid 생성]
F --> G[202 응답]
{% endmermaid %}

**구현 상세:**

```java
@Override
public void handleRoomCreate(HttpServerExchange exchange) {
    exchange.getRequestReceiver().receiveFullString((httpServerExchange, message) -> {
        try {
            RoomCreationRequest request = gson.fromJson(message, RoomCreationRequest.class);
            if (isInvalidRequest(request)) {
                responseFormatter.sendErrorResponse(httpServerExchange, StatusCodes.BAD_REQUEST,
                        "유효하지 않은 요청 본문 또는 'uuid' (userId)가 누락되었습니다.");
                return;
            }

            String ruid = queueManager.submitRequest(request);
            JsonObject response = createRoomCreationResponse(ruid);
            responseFormatter.sendSuccessResponse(httpServerExchange, StatusCodes.ACCEPTED, response);

        } catch (JsonSyntaxException e) {
            responseFormatter.sendErrorResponse(httpServerExchange, StatusCodes.BAD_REQUEST,
                    "JSON 요청 본문 파싱에 실패했습니다.");
        } catch (Exception e) {
            responseFormatter.sendErrorResponse(httpServerExchange, StatusCodes.INTERNAL_SERVER_ERROR,
                    "요청 큐 등록 실패", e, true);
        }
    }, (httpServerExchange, e) -> {
        responseFormatter.sendErrorResponse(httpServerExchange, StatusCodes.INTERNAL_SERVER_ERROR,
                "요청 본문을 읽는데 실패했습니다.", e, false);
    });
}
```

**주요 검증:**

- `uuid` 필수 확인
- JSON 형식 검증
- 요청 크기 제한

**비동기 처리:**

- 즉시 ruid 반환
- 백그라운드 처리 시작
- 클라이언트 폴링 유도
  {% endhint %}

### 4️⃣ **handleRoomResult() - 결과 조회**

{% hint style="success" %}

#### **GET /room/result?ruid={id}**

**상태별 응답 처리:**

| 상태           | HTTP 코드 | 응답        | 액션     |
|--------------|---------|-----------|--------|
| `QUEUED`     | 200     | 상태만 반환    | 계속 폴링  |
| `PROCESSING` | 200     | 상태만 반환    | 계속 폴링  |
| `COMPLETED`  | 200     | 전체 결과 반환  | 결과 삭제  |
| `FAILED`     | 200     | 에러 정보 반환  | 결과 삭제  |
| 없음           | 404     | Not Found | 재시도 불가 |

**구현:**

```java
private void processJobState(HttpServerExchange exchange, String ruid, JobResultStore.JobState jobState) {
    switch (jobState.status()) {
        case QUEUED, PROCESSING -> handleInProgressJob(exchange, ruid, jobState);
        case COMPLETED -> handleCompletedJob(exchange, ruid, jobState, false);
        case FAILED -> handleCompletedJob(exchange, ruid, jobState, true);
    }
}

private void handleCompletedJob(HttpServerExchange exchange, String ruid,
                                JobResultStore.JobState jobState, boolean isFailed) {
    responseFormatter.sendJsonResponse(exchange, StatusCodes.OK, jobState.result());
    resultStore.deleteJob(ruid);  // 자동 정리

    if (isFailed) {
        log.warn("ruid '{}'에 대한 실패 결과가 전달되고 삭제되었습니다.", ruid);
    } else {
        log.info("ruid '{}'에 대한 결과가 전달되고 삭제되었습니다.", ruid);
    }
}
```

**자동 정리:**

- 결과 조회 시 자동 삭제
- 메모리 효율적 관리
- 중복 조회 방지
  {% endhint %}

### 5️⃣ **handleQueueStatus() - 큐 상태 조회**

```java
@Override
public void handleQueueStatus(HttpServerExchange exchange) {
    responseFormatter.sendJsonResponse(exchange, StatusCodes.OK,
            formatQueueStatus(queueManager.getQueueStatus()));
}
```

---

## 🛠️ ResponseFormatter 활용

### 일관된 응답 형식

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📤 응답 포맷터의 역할</h4>

```java
public class ResponseFormatter {
    // 성공 응답 (자동으로 success: true 추가)
    public void sendSuccessResponse(HttpServerExchange exchange, JsonObject data) {
        if (!data.has("success")) {
            data.addProperty("success", true);
        }
        sendJsonResponse(exchange, StatusCodes.OK, data);
    }

    // 에러 응답 (일관된 에러 구조)
    public void sendErrorResponse(HttpServerExchange exchange, int statusCode, String errorMessage) {
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("success", false);
        errorResponse.addProperty("error", errorMessage);
        errorResponse.addProperty("timestamp", String.valueOf(System.currentTimeMillis()));
        sendJsonResponse(exchange, statusCode, errorResponse);
    }

    // 쿼리 파라미터 추출 유틸리티
    public Optional<String> getQueryParam(HttpServerExchange exchange, String paramName) {
        return Optional.ofNullable(exchange.getQueryParameters().get(paramName))
                .map(deque -> deque.isEmpty() ? null : deque.getFirst())
                .filter(value -> !value.trim().isEmpty());
    }
}
```

</div>

**장점:**

- 일관된 응답 구조
- 자동 Content-Type 설정 (application/json; charset=utf-8)
- 에러 처리 표준화
- 로깅 통합

---

## 📊 요청/응답 처리 패턴

### 비동기 요청 수신

{% hint style="success" %}

#### 🔄 **Non-blocking 처리**

```java
exchange.getRequestReceiver().receiveFullString((httpExchange, message) -> {
    // 요청 본문 처리
    // JSON 파싱
    // 비즈니스 로직
}, (httpExchange, e) -> {
    // 에러 처리
});
```

**장점:**

- 스레드 블로킹 없음
- 높은 동시성 지원
- 메모리 효율적
  {% endhint %}

---

## 🔒 입력 검증 전략

### 계층적 검증

{% mermaid %}
graph TD
A[HTTP 레벨] --> B[헤더 검증]
B --> C[JSON 레벨]
C --> D[구조 검증]
D --> E[비즈니스 레벨]
E --> F[값 검증]

    B --> G[API Key]
    D --> H[필수 필드]
    F --> I[값 범위/형식]
{% endmermaid %}

### 검증 실패 처리

| 검증 단계   | 실패 시 응답        | HTTP 코드 |
|---------|----------------|---------|
| API Key | Unauthorized   | 401     |
| JSON 파싱 | Bad Request    | 400     |
| 필수 필드   | Bad Request    | 400     |
| 값 형식    | Bad Request    | 400     |
| 서버 오류   | Internal Error | 500     |

---

## 📈 성능 최적화

### 응답 시간 목표

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e3f2fd; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>GET 요청</h4>
    <div style="font-size: 2em; font-weight: bold; color: #1976d2;">< 50ms</div>
    <p>조회 작업 응답 시간</p>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>POST 요청</h4>
    <div style="font-size: 2em; font-weight: bold; color: #388e3c;">< 100ms</div>
    <p>생성 작업 응답 시간</p>
  </div>
  <div style="background: #f3e5f5; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>에러 응답</h4>
    <div style="font-size: 2em; font-weight: bold; color: #7b1fa2;">< 20ms</div>
    <p>에러 처리 응답 시간</p>
  </div>
</div>

---

## 🐛 에러 처리 철학

{% hint style="info" %}

#### 💡 **핵심 원칙**

1. **구체적인 에러 메시지**: 문제 해결을 위한 충분한 정보 제공
2. **일관된 응답 형식**: 모든 에러가 동일한 구조
3. **적절한 HTTP 코드**: RESTful 규약 준수
4. **로깅과 분리**: 민감한 정보는 로그에만 기록
   {% endhint %}

### 에러 응답 예시

```json
// 잘못된 요청
{
  "success": false,
  "error": "유효하지 않은 요청 본문 또는 'uuid' (userId)가 누락되었습니다.",
  "timestamp": "1234567890"
}

// 리소스 없음
{
  "success": false,
  "error": "ruid 'room_xxx'에 해당하는 작업을 찾을 수 없습니다. 이미 처리되었거나 존재하지 않는 작업입니다.",
  "timestamp": "1234567890"
}
```

---

## 🔧 헬퍼 메서드

### 요청 검증

```java
private boolean isInvalidRequest(RoomCreationRequest request) {
  return request == null || request.getUuid() == null || request.getUuid().trim().isEmpty();
}
```

### 응답 생성

```java
private JsonObject createRoomCreationResponse(String ruid) {
  JsonObject response = new JsonObject();
  response.addProperty("ruid", ruid);
  response.addProperty("status", "대기중");
  response.addProperty("message", "방 생성 요청이 수락되었습니다. 상태 확인을 위해 /room/result?ruid=" + ruid + "를 폴링하세요.");
  return response;
}
```

### 쿼리 파라미터 추출

```java
private String extractRuidFromQuery(HttpServerExchange exchange) {
  return responseFormatter.getQueryParam(exchange, "ruid").orElse(null);
}
```

---

> 💡 ApiHandler는 **안정적**이고 **예측 가능한** API 서비스의 핵심입니다.