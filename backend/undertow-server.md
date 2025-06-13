# 3.1 Undertow 서버 개요

## 🚀 Undertow 서버 구조

<div style="background: linear-gradient(135deg, #4a90e2 0%, #7b68ee 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">고성능 NIO 기반 웹 서버</h3>
  <p style="margin: 10px 0 0 0;">비동기 처리와 낮은 메모리 사용량으로 최적화된 서버 구현</p>
</div>

---

## 📋 서버 초기화 및 구성

### UndertowServer 클래스 구조

```java
public class UndertowServer implements Server {
   private static final Logger log = LoggerFactory.getLogger(UndertowServer.class);
   private static final int MAX_CONCURRENT_REQUESTS = 1;

   private final Undertow server;
   private final QueueManager queueManager;
   private final RoomService roomService;

   public UndertowServer(int port) {
      // 의존성 초기화
      // 서비스 생성
      // 라우팅 설정
      // 서버 빌드
   }
}
```

### 주요 구성 요소

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔧 핵심 컴포넌트</h4>

| 컴포넌트                 | 역할      | 특징               |
|----------------------|---------|------------------|
| **Undertow Server**  | HTTP 서버 | NIO 기반, 포트 8080  |
| **ApiKeyAuthFilter** | 인증 필터   | 모든 요청 인증         |
| **RoutingHandler**   | 라우팅     | RESTful 엔드포인트 관리 |
| **ApiHandler**       | 요청 처리   | JSON 직렬화/역직렬화    |
| **ServiceFactory**   | 서비스 생성  | 의존성 주입 관리        |

</div>

---

## 🔄 큐 시스템 (Queue System)

### RoomRequestQueueManager

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📊 비동기 작업 큐 관리</h4>

```java
public class RoomRequestQueueManager implements QueueManager {
   private final BlockingQueue<QueuedRoomRequest> requestQueue;
   private final ExecutorService executorService;
   private final int maxConcurrentRequests;

   private final AtomicInteger activeRequests = new AtomicInteger(0);
   private final AtomicInteger completedRequests = new AtomicInteger(0);

   // 동시 처리: 기본 1개 (확장 가능)
   // 큐 타입: LinkedBlockingQueue (무제한)
   // 워커 스레드: maxConcurrentRequests 개수만큼
}
```

**주요 기능:**

- ✅ 요청 즉시 반환 (ruid 생성)
- ✅ 백그라운드 비동기 처리
- ✅ 상태 추적 (QUEUED → PROCESSING → COMPLETED/FAILED)
- ✅ 동시 처리량 제어
- ✅ 통계 수집 (대기/활성/완료)
- ✅ 상세한 요청 로깅

</div>

### 큐 처리 플로우

{% mermaid %}
sequenceDiagram
participant Client
participant Queue
participant Worker
participant AI Services

    Client->>Queue: submitRequest()
    Queue-->>Client: return ruid
    
    Queue->>Worker: take() request
    Worker->>AI Services: process
    AI Services-->>Worker: result
    Worker->>JobResultStore: store result
{% endmermaid %}

---

## 💾 JobResultStore

### 결과 저장소 구조

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🗄️ 인메모리 결과 저장소</h4>

```java
public class JobResultStore {
    private final Map<String, JobState> jobStore = new ConcurrentHashMap<>();

    public enum Status {
        QUEUED,      // 큐 대기중
        PROCESSING,  // 처리중
        COMPLETED,   // 완료
        FAILED       // 실패
    }

    public record JobState(Status status, JsonObject result) {
    }
}
```

**특징:**

- Thread-safe (ConcurrentHashMap)
- 빠른 조회 성능 (O(1))
- 결과 조회 후 자동 삭제
- 메모리 효율적 관리

</div>

---

## ⚙️ 설정 관리

### 환경 변수 및 설정

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔐 필수 환경 변수</h4>

| 변수명               | 용도           | 기본값             |
|-------------------|--------------|-----------------|
| EROOM_PRIVATE_KEY | API 인증 키     | 랜덤 UUID (자동 생성) |
| ANTHROPIC_KEY     | Claude API 키 | 필수 (없으면 서버 종료)  |
| MESHY_KEY_1/2/3   | Meshy API 키  | 필수 (최소 1개)      |

**💡 보안 팁:**

- EROOM_PRIVATE_KEY 미설정 시 랜덤 키가 생성되며, 서버 재시작 시 변경됩니다.
- 생성된 키는 로그에 출력되므로 확인 후 사용하세요.

</div>

### 설정 파일 로드

```java
// JsonConfigurationManager를 통한 config.json 로드
ConfigurationManager configManager = new JsonConfigurationManager();
JsonObject config = configManager.getConfig();

// 프롬프트 및 모델 설정 사용
String scenarioPrompt = configManager.getPrompt("scenario");
JsonObject modelConfig = configManager.getModelConfig();
```

**config.json 주요 설정:**
- 모델명: claude-sonnet-4-20250514
- 최대 토큰: 16,000
- Temperature: 시나리오 0.9, 스크립트 0.1

---

## 🌐 라우팅 구조

### 엔드포인트 매핑

```java
private RoutingHandler createRouting(RequestHandler handler) {
    return Handlers.routing()
            .get("/", handler::handleRoot)
            .get("/health", handler::handleHealth)
            .get("/queue/status", handler::handleQueueStatus)
            .post("/room/create", handler::handleRoomCreate)
            .get("/room/result", handler::handleRoomResult);
}
```

### API 엔드포인트 상세

| 엔드포인트           | 메서드  | 핸들러               | 설명       |
|-----------------|------|-------------------|----------|
| `/`             | GET  | handleRoot        | 서버 기본 상태 |
| `/health`       | GET  | handleHealth      | 상세 헬스체크  |
| `/queue/status` | GET  | handleQueueStatus | 큐 상태 조회  |
| `/room/create`  | POST | handleRoomCreate  | 룸 생성 요청  |
| `/room/result`  | GET  | handleRoomResult  | 결과 조회    |

---

## 🚦 서버 생명주기

### 시작과 종료

#### 🟢 **서버 시작**

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">서버 초기화 순서</h4>

1. **의존성 초기화**
   - Gson 인스턴스 생성
   - ConfigurationManager 로드
   - ApiKeyProvider (환경변수)
   - AuthProvider (API 키)

2. **서비스 생성**
   - ServiceFactory 통한 서비스 인스턴스화
   - RoomService (AI 서비스 포함)
   - JobResultStore
   - QueueManager

3. **라우팅 설정**
   - API 핸들러 생성
   - 라우트 정의
   - 인증 필터 적용

4. **서버 빌드 및 시작**
   ```java
   server = Undertow.builder()
           .addHttpListener(port, "0.0.0.0")
           .setHandler(apiKeyProtectedHandler)
           .build();
   server.start();
   ```

</div>

#### 🔴 **서버 종료**

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">우아한 종료 절차</h4>

```java
@Override
public void stop() {
    if (server != null) {
        log.info("서버 종료 시작...");

        // 1. 큐 매니저 종료 (새 요청 차단)
        if (queueManager != null) {
            queueManager.shutdown();
        }

        // 2. RoomService 정리 (ExecutorService 종료)
        if (roomService instanceof AutoCloseable) {
            try {
                ((AutoCloseable) roomService).close();
            } catch (Exception e) {
                log.error("RoomService 종료 중 오류", e);
            }
        }

        // 3. HTTP 서버 종료
        server.stop();
        log.info("서버가 중지되었습니다");
    }
}
```

</div>

---

## 📊 성능 특성

### Undertow 서버 성능

| 지표         | 값       | 설명      |
|------------|---------|---------|
| **동시 연결**  | 10,000+ | NIO 기반  |
| **메모리 사용** | ~50MB   | 초경량     |
| **시작 시간**  | < 1초    | 빠른 부팅   |
| **응답 지연**  | < 5ms   | 낮은 레이턴시 |

### 큐 시스템 성능

{% mermaid %}
graph LR
A[요청 수신] -->|< 100ms| B[큐 등록]
B -->|즉시| C[ruid 반환]
B -->|비동기| D[백그라운드 처리]
D -->|5-8분| E[완료]
{% endmermaid %}

---

## 🛡️ 에러 처리

### 서버 레벨 에러 처리

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚠️ 장애 대응 전략</h4>

| 증상            | 확인 사항    | 조치 방법       |
|---------------|----------|-------------|
| **서버 무응답**    | 프로세스 상태  | 서버 재시작      |
| **메모리 부족**    | 힙 사용량    | JVM 힙 크기 증가 |
| **API 키 오류**  | 환경 변수    | 키 재설정       |
| **큐 적체**      | 큐 상태     | 처리 스레드 확인   |
| **AI 서비스 오류** | API 키 설정 | 환경변수 확인     |

**fail-fast 전략:**

- 필수 설정 누락 시 서버 즉시 종료
- AI 응답 실패 시 서버 종료
- 명확한 에러 메시지 로깅

</div>

---

## 🔍 모니터링 포인트

### 주요 모니터링 지표

```json
// GET /health 응답 예시
{
  "status": "healthy",
  "queue": {
    "queued": 5,
    "active": 1,
    "completed": 142,
    "maxConcurrent": 1
  }
}
```

### 로그 레벨별 모니터링

| 로그 레벨     | 용도     | 예시           |
|-----------|--------|--------------|
| **INFO**  | 주요 이벤트 | 서버 시작, 요청 처리 |
| **WARN**  | 주의 사항  | API 키 자동 생성  |
| **ERROR** | 오류 발생  | 처리 실패        |
| **DEBUG** | 상세 디버깅 | 요청/응답 세부사항   |

**상세 로깅 예시:**
```
=== 요청 제출 상세 정보 ===
RUID: room_a1b2c3d4e5f6
User UUID: test_user
Theme: '우주 정거장'
Keywords: SF, 퍼즐
Difficulty: 'normal'
Room Prefab: 'https://example.com/space.fbx'
========================
```

---

## 🏛️ 아키텍처 특징

### 의존성 주입 패턴

```java
// ServiceFactory를 통한 깔끔한 의존성 관리
ServiceFactory serviceFactory = new ServiceFactoryImpl(apiKeyProvider, configManager);
roomService = serviceFactory.createRoomService();
```

### 비동기 처리 모델

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔄 논블로킹 아키텍처</h4>

- **요청 수신**: Non-blocking I/O
- **큐 처리**: ExecutorService 기반
- **AI 호출**: 병렬 처리
- **응답 전송**: 비동기 전송

이로 인해 단일 서버에서도 높은 동시성을 처리할 수 있습니다.
</div>

---

## 🚀 최적화 팁

### JVM 튜닝 옵션

```bash
# 권장 JVM 옵션
java -Xms512m -Xmx2g \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -Dfile.encoding=UTF-8 \
     -jar eroom-server.jar
```

### 성능 향상 방법

1. **큐 동시 처리 수 증가**
   ```java
   MAX_CONCURRENT_REQUESTS = 3; // 서버 리소스에 따라 조정
   ```

2. **연결 풀 최적화**
   - OkHttpClient 연결 풀 크기 조정
   - 타임아웃 값 최적화

3. **로깅 레벨 조정**
   - 프로덕션: INFO 레벨
   - 디버깅: DEBUG 레벨

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>💡 Undertow 서버는 <strong>안정성</strong>과 <strong>성능</strong>을 모두 제공하는 핵심 인프라입니다.</p>
</div>