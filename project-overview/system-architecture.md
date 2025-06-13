# 1.2 전체 시스템 아키텍처

## 🏗️ 시스템 개요

{% hint style="info" %}

### **마이크로서비스 기반 AI 통합 아키텍처**

비동기 처리와 AI 서비스를 결합한 확장 가능한 시스템 설계
{% endhint %}

ERoom 시스템은 **레이어드 아키텍처**와 **이벤트 기반 비동기 처리**를 결합하여 안정적이고 확장 가능한 서비스를 제공합니다.

---

## 🔄 전체 시스템 플로우

{% mermaid %}
graph TB
subgraph "Client Layer"
C1[Unity Client]
C2[Web Client]
C3[Mobile Client]
end

    subgraph "API Gateway"
        AG[Undertow Server :8080]
        AF[API Key Auth Filter]
    end
    
    subgraph "Business Logic Layer"
        AH[API Handler]
        QM[Queue Manager]
        RS[Room Service]
    end
    
    subgraph "AI Service Layer"
        AS[Anthropic Service]
        MS[Meshy Service]
    end
    
    subgraph "Data Layer"
        JR[JobResultStore]
        FB[(Firebase Firestore)]
    end
    
    C1 --> AG
    C2 --> AG
    C3 --> AG
    
    AG --> AF
    AF --> AH
    
    AH --> QM
    QM --> RS
    
    RS --> AS
    RS --> MS
    
    RS --> JR
    C1 -.-> FB
    C2 -.-> FB
    
    style AS fill:#4a90e2
    style MS fill:#4a90e2
    style FB fill:#f39c12

{% endmermaid %}

---

## 📋 레이어별 상세 구조

### 1️⃣ **Client Layer (클라이언트 계층)**

| 클라이언트         | 역할          | 기술 스택             |
|---------------|-------------|-------------------|
| Unity Client  | 메인 게임 클라이언트 | Unity6, C#        |
| Web Client    | 웹 기반 대시보드   | React, TypeScript |
| Mobile Client | 모바일 컨트롤러    | React Native      |

### 2️⃣ **API Gateway (게이트웨이 계층)**

{% hint style="success" %}

#### 🔐 **보안과 라우팅**

* **Undertow Server**: 고성능 NIO 기반 웹 서버 (포트 8080)
* **API Key Filter**: 모든 요청에 대한 인증 처리
* **Request Routing**: RESTful 엔드포인트 관리
  {% endhint %}

### 3️⃣ **Business Logic Layer (비즈니스 로직 계층)**

{% mermaid %}
graph LR
subgraph "Request Flow"
A[API Handler] --> B[Request Validation]
B --> C[Queue Manager]
C --> D[Async Processing]
D --> E[Room Service]
end
{% endmermaid %}

**핵심 컴포넌트:**

- **API Handler**: 요청/응답 처리 및 JSON 변환
- **Queue Manager**: 비동기 작업 큐 관리 (최대 동시 처리: 1개)
- **Room Service**: 방탈출 생성 로직 총괄

### 4️⃣ **AI Service Layer (AI 서비스 계층)**

#### 🤖 **Anthropic Service**

> * 시나리오 생성 (60초)
> * 스크립트 생성 (20초)
> * Claude Sonnet 4 모델 사용
> * Temperature: 시나리오 0.9, 스크립트 0.1

#### 🎨 **Meshy Service**

> * 3D 모델 프리뷰 (1-3분)
> * 모델 정제 (3-5분)
> * FBX 포맷 출력
> * 다중 API 키 로드밸런싱 (3개)

### 5️⃣ **Data Layer (데이터 계층)**

| 저장소                | 용도          | 특징                                  |
|--------------------|-------------|-------------------------------------|
| JobResultStore     | 임시 작업 결과 저장 | In-Memory, ConcurrentHashMap, 빠른 접근 |
| Firebase Firestore | 영구 데이터 저장   | NoSQL, 실시간 동기화, 클라이언트 직접 접근         |

---

## 🔧 핵심 설계 원칙

### ✅ **비동기 처리 (Asynchronous Processing)**

```java
// 요청 즉시 반환
POST /room/create → {"ruid":"room_12345","status":"대기중"}

// 백그라운드 처리
Queue → Room Service → AI Services → Result Store

// 결과 폴링
GET /room/result?ruid=room_12345 → {"status":"COMPLETED",...}
```

### ✅ **확장성 (Scalability)**

- 수평적 확장: 서버 인스턴스 추가
- AI 서비스 로드 밸런싱: 다중 API 키 사용
- 큐 시스템: 처리량 동적 조절 (현재 1, 확장 가능)

### ✅ **안정성 (Reliability)**

- 에러 격리: 각 요청 독립적 처리
- 재시도 메커니즘: AI 서비스 실패 시 재시도
- 상태 추적: 모든 작업 상태 실시간 모니터링

---

## 🚀 성능 최적화 전략

{% hint style="warning" %}

#### ⚡ **최적화 포인트**

| 최적화 기법      | 설명                      | 효과            |
|-------------|-------------------------|---------------|
| **병렬 처리**   | AI 서비스 호출 병렬화           | 처리 시간 60% 단축  |
| **캐싱 전략**   | 자주 사용되는 프롬프트와 설정 메모리 캐싱 | 응답 속도 향상      |
| **연결 풀링**   | HTTP 클라이언트 연결 재사용       | 오버헤드 감소       |
| **비동기 I/O** | Undertow의 NIO 활용        | 동시 연결 10,000+ |

{% endhint %}

---

## 🔒 보안 아키텍처

{% mermaid %}
graph LR
A[Client Request] --> B{API Key Valid?}
B -->|Yes| C[Process Request]
B -->|No| D[401 Unauthorized]

    C --> E[Input Validation]
    E --> F[Sanitize Data]
    F --> G[Execute Business Logic]
    
    style D fill:#f44336
    style C fill:#4caf50

{% endmermaid %}

**보안 계층:**

1. **API Key 인증**: 모든 요청에 필수 (환경변수 또는 자동 생성)
2. **입력 검증**: SQL Injection, XSS 방지
3. **환경 변수**: 민감 정보 보호 (API 키)
4. **HTTPS**: 전송 구간 암호화 (프로덕션 권장)

---

## 📊 시스템 모니터링

{% hint style="info" %}

#### 📈 **모니터링 지표**

* **큐 상태**: 대기/처리중/완료 작업 수
* **응답 시간**: API별 평균 응답 시간
* **에러율**: AI 서비스별 실패율
* **리소스 사용량**: CPU, 메모리, 네트워크
  {% endhint %}

### 헬스체크 응답 예시

```json
{
  "status": "healthy",
  "queue": {
    "queued": 3,
    "active": 1,
    "completed": 150,
    "maxConcurrent": 1
  }
}
```

---

## 🔄 데이터 흐름 상세

### 룸 생성 요청 플로우

{% mermaid %}
sequenceDiagram
participant C as Client
participant S as Server
participant Q as Queue
participant RS as RoomService
participant AI as AI Services
participant DB as ResultStore

    C->>S: POST /room/create
    S->>S: 요청 검증
    S->>Q: 큐에 추가
    S-->>C: 202 Accepted {ruid}
    
    Q->>RS: 작업 시작
    RS->>AI: 시나리오 생성 (60s)
    AI-->>RS: 시나리오 데이터
    
    par 병렬 처리
        RS->>AI: 스크립트 생성 (20s)
        AI-->>RS: C# 스크립트
    and
        RS->>AI: 3D 모델 생성 (5-7분)
        AI-->>RS: 모델 추적 ID
    end
    
    RS->>DB: 결과 저장
    
    C->>S: GET /room/result?ruid=xxx
    S->>DB: 결과 조회
    DB-->>S: 완료된 데이터
    S-->>C: 200 OK {전체 결과}

{% endmermaid %}

---

## 🏛️ 컴포넌트 상세

### UndertowServer

- **포트**: 8080 (설정 가능)
- **동시 연결**: 10,000+
- **메모리 사용**: ~50MB
- **시작 시간**: < 1초

### RoomService

- **ExecutorService**: 10개 스레드 풀
- **타임아웃**: 모델 생성 10분
- **검증기**: RequestValidator, ScenarioValidator

### AI 서비스 통합

- **Anthropic**: 단일 클라이언트 재사용
- **Meshy**: 3개 API 키 순환 사용
- **에러 처리**: 실패 시 서버 종료 (fail-fast)

---

## 🎨 확장 가능한 설계

### 현재 아키텍처의 확장 포인트

1. **큐 시스템 확장**

    - Redis 기반 분산 큐로 전환 가능
    - 다중 워커 프로세스 지원

2. **AI 서비스 확장**

    - 새로운 AI 서비스 쉽게 추가
    - 서비스별 폴백 메커니즘

3. **데이터 저장소 확장**

    - 영구 저장소 추가 (PostgreSQL 등)
    - 캐싱 레이어 추가 (Redis)

4. **모니터링 확장**

    - Prometheus 메트릭 수집
    - Grafana 대시보드
    - ELK 스택 로그 분석

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>이 아키텍처는 <strong>안정성</strong>, <strong>확장성</strong>, <strong>성능</strong>을 모두 고려한 설계입니다.</p>
</div>