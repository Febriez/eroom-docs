# 3.1 Undertow 서버 개요

## 🚀 Undertow 서버 구조

<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">고성능 NIO 기반 웹 서버</h3>
  <p style="margin: 10px 0 0 0;">비동기 처리와 낮은 메모리 사용량으로 최적화된 서버 구현</p>
</div>

---

## 📋 서버 초기화 및 구성

### UndertowServer 클래스 구조

```java
public class UndertowServer {
    private static final int MAX_CONCURRENT_REQUESTS = 1;
    
    private final Undertow server;
    private final RoomRequestQueueManager queueManager;
    private final RoomServiceImpl roomService;
    
    public UndertowServer(int port) {
        // 서비스 초기화
        // 라우팅 설정
        // 서버 생성
    }
}
```

### 주요 구성 요소

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔧 핵심 컴포넌트</h4>
  
  | 컴포넌트 | 역할 | 특징 |
  |----------|------|------|
  | **Undertow Server** | HTTP 서버 | NIO 기반, 포트 8080 |
  | **ApiKeyAuthFilter** | 인증 필터 | 모든 요청 인증 |
  | **RoutingHandler** | 라우팅 | RESTful 엔드포인트 관리 |
  | **ApiHandler** | 요청 처리 | JSON 직렬화/역직렬화 |
</div>

---

## 🔄 큐 시스템 (Queue System)

### RoomRequestQueueManager

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📊 비동기 작업 큐 관리</h4>
  
  ```java
  public class RoomRequestQueueManager {
      private final BlockingQueue<QueuedRoomRequest> requestQueue;
      private final ExecutorService executorService;
      private final int maxConcurrentRequests;
      
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
</div>

### 큐 처리 플로우

```mermaid
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
```

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
  
  | 변수명 | 용도 | 기본값 |
  |--------|------|--------|
  | `EROOM_PRIVATE_KEY` | API 인증 키 | 랜덤 UUID |
  | `ANTHROPIC_KEY` | Claude API 키 | 필수 |
  | `MESHY_KEY_1/2/3` | Meshy API 키 | 필수 |
  
  <div style="margin-top: 15px; padding: 10px; background: #ffecb3; border-radius: 5px;">
    <strong>💡 보안 팁:</strong> EROOM_PRIVATE_KEY 미설정 시 랜덤 키가 생성되며, 서버 재시작 시 변경됩니다.
  </div>
</div>

### ConfigUtil 사용

```java
// config.json 로드 및 사용
JsonObject config = configUtil.getConfig();
String prompt = config.getAsJsonObject("prompts").get("scenario").getAsString();
```

---

## 🌐 라우팅 구조

### 엔드포인트 매핑

```java
RoutingHandler routingHandler = Handlers.routing()
    .get("/", apiHandler::handleRoot)              // 서버 상태
    .get("/health", apiHandler::handleHealth)      // 헬스체크
    .get("/queue/status", apiHandler::handleQueueStatus)  // 큐 상태
    .post("/room/create", apiHandler::handleRoomCreate)   // 룸 생성
    .get("/room/result", apiHandler::handleRoomResult);   // 결과 조회
```

---

## 🚦 서버 생명주기

### 시작과 종료

<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px;">
    <h4 style="margin: 0 0 10px 0;">🟢 서버 시작</h4>
    <ol style="margin: 0;">
      <li>서비스 초기화</li>
      <li>설정 검증</li>
      <li>큐 워커 시작</li>
      <li>HTTP 리스너 바인딩</li>
      <li>포트 8080 대기</li>
    </ol>
  </div>
  <div style="background: #ffcdd2; padding: 20px; border-radius: 10px;">
    <h4 style="margin: 0 0 10px 0;">🔴 서버 종료</h4>
    <ol style="margin: 0;">
      <li>큐 매니저 종료</li>
      <li>진행중 작업 완료 대기</li>
      <li>RoomService 정리</li>
      <li>HTTP 연결 종료</li>
      <li>리소스 해제</li>
    </ol>
  </div>
</div>

---

## 📊 성능 특성

### Undertow 서버 성능

| 지표 | 값 | 설명 |
|------|-----|------|
| **동시 연결** | 10,000+ | NIO 기반 |
| **메모리 사용** | ~50MB | 초경량 |
| **시작 시간** | < 1초 | 빠른 부팅 |
| **응답 지연** | < 5ms | 낮은 레이턴시 |

### 큐 시스템 성능

```mermaid
graph LR
    A[요청 수신] -->|< 100ms| B[큐 등록]
    B -->|즉시| C[ruid 반환]
    B -->|비동기| D[백그라운드 처리]
    D -->|5-10분| E[완료]
```

---

## 🛡️ 에러 처리

### 서버 레벨 에러 처리

<div style="background: #f0f0f0; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚠️ 장애 대응 전략</h4>
  
  1. **설정 오류**: 서버 시작 전 검증, 실패 시 종료
  2. **API 키 누락**: 명확한 로그 메시지, 안전한 종료
  3. **큐 오버플로우**: LinkedBlockingQueue로 무제한 대기
  4. **처리 실패**: 개별 요청 격리, 다른 요청 영향 없음
</div>

---

## 🔍 모니터링 포인트

### 주요 모니터링 지표

```java
// GET /health 응답 예시
{
  "status": "healthy",
  "queue": {
    "queued": 5,        // 대기 중
    "active": 1,        // 처리 중
    "completed": 142,   // 완료됨
    "maxConcurrent": 1  // 최대 동시 처리
  }
}
```

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>Undertow 서버는 <strong>안정성</strong>과 <strong>성능</strong>을 모두 제공하는 핵심 인프라입니다.</p>
</div>