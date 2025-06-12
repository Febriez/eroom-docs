# 1.3 기술 스택 요약

## 🛠️ 기술 스택 개요

{% hint style="info" %}
### **최신 기술의 완벽한 조합**
성능, 안정성, 확장성을 모두 고려한 기술 선택
{% endhint %}

---

## 📊 기술 스택 전체 구조

{% mermaid %}
graph TB
  subgraph "Frontend Technologies"
    U[Unity6 - Game Engine]
    R[React - Web Dashboard]
    RN[React Native - Mobile]
  end

  subgraph "Backend Technologies"
    J[Java 17 LTS]
    UT[Undertow Server]
    G[Gson]
    OK[OkHttp Client]
  end

  subgraph "AI Services"
    CL[Claude AI - Anthropic]
    ME[Meshy AI - 3D Generation]
  end

  subgraph "Infrastructure"
    FB[Firebase Firestore]
    GC[Google Cloud Platform]
  end

  U --> J
  R --> J
  RN --> J

  J --> CL
  J --> ME
  J --> FB

  style CL fill:#4a90e2
  style ME fill:#4a90e2
  style FB fill:#f39c12
{% endmermaid %}

---

## 🔧 백엔드 기술 상세

### ☕ **Java 17 LTS**

{% hint style="success" %}
#### **선택 이유**
* **장기 지원(LTS)**: 2029년까지 보안 업데이트 보장
* **최신 기능**: Records, Pattern Matching, Text Blocks, Switch Expressions
* **성능 향상**: G1GC 개선, JIT 컴파일러 최적화
* **생태계**: 풍부한 라이브러리와 도구
  {% endhint %}

### 🚀 **Undertow**

| 특징 | 설명 |
|------|------|
| **Non-blocking I/O** | XNIO 기반 고성능 처리 |
| **낮은 메모리 사용** | ${server.memory.usage} 경량 설계로 효율적 리소스 활용 |
| **임베디드 가능** | 별도 서버 설치 불필요 |
| **HTTP/2 지원** | 최신 프로토콜 완벽 지원 |
| **동시 연결** | ${server.concurrent.connections} |
| **응답 지연** | ${server.response.latency} |

### 📦 **주요 라이브러리**

#### **Gson**
> * Google의 JSON 처리 라이브러리
> * 간단한 API와 높은 성능
> * 커스텀 직렬화 지원
> * Null 안전성 지원

#### **OkHttp**
> * Square의 HTTP 클라이언트
> * 연결 풀링과 캐싱
> * 자동 재시도 메커니즘
> * HTTP/2 지원

#### **SLF4J + Logback**
> * 표준 로깅 인터페이스
> * 유연한 로그 레벨 설정
> * 비동기 로깅 지원

---

## 🤖 AI 서비스 통합

### **Anthropic Claude AI**

{% hint style="info" %}
#### **Claude Opus 4** (${anthropic.model.name})
최신 대형 언어 모델로 창의적이고 정확한 콘텐츠 생성

**최대 토큰 수: ${anthropic.max.tokens}**
{% endhint %}

**활용 분야:**
- 🎭 **시나리오 생성**: 창의적인 방탈출 스토리와 퍼즐 설계 (Temperature: ${anthropic.scenario.temperature})
- 💻 **스크립트 생성**: Unity C# 게임 로직 자동 생성 (Temperature: ${anthropic.script.temperature})
- 🎯 **난이도 조절**: Easy/Normal/Hard별 맞춤 콘텐츠

**성능 특성:**
- 시나리오 생성: ${scenario.generation.time.avg}
- 스크립트 생성: ${script.generation.time.avg}
- 요청당 비용: ${anthropic.cost.per.request}

### **Meshy AI**

{% hint style="warning" %}
#### **Text-to-3D Generation API v2**

| 단계 | 소요 시간 | 설명 | 비용 |
|------|-----------|------|------|
| **Preview** | ${model.preview.time.avg} | 빠른 프리뷰 생성 | ${meshy.preview.cost} |
| **Refine** | ${model.refine.time.avg} | 고품질 정제 | ${meshy.refine.cost} |
| **Export** | FBX | Unity 호환 포맷 | - |
| **총 비용** | - | - | ${meshy.total.cost.per.model} |

**API 특성:**
- 폴링 간격: ${meshy.polling.interval.ms}
- 최대 폴링 횟수: ${meshy.max.polling.attempts}
- 타임아웃: ${meshy.timeout.seconds}
- API 안정성: ${meshy.api.stability}
  {% endhint %}

---

## 🎮 프론트엔드 기술

### **Unity6**

| 기능 | 활용 |
|------|------|
| **최신 렌더링** | URP/HDRP로 고품질 그래픽 |
| **새로운 Input System** | 다양한 입력 장치 지원 |
| **UI Toolkit** | 현대적인 UI 구현 |
| **C# 9.0** | 최신 언어 기능 활용 |
| **Addressables** | 효율적인 에셋 관리 |

---

## 💾 데이터 저장소

### **Firebase Firestore**

{% hint style="warning" %}
#### **선택 이유**

| 특징 | 설명 |
|------|------|
| **실시간 동기화** | 클라이언트 간 즉각적인 데이터 동기화 |
| **오프라인 지원** | 네트워크 없이도 작동, 재연결 시 자동 동기화 |
| **확장성** | 자동 샤딩으로 무제한 확장 가능 |
| **보안 규칙** | 세밀한 접근 권한 제어 |
| **백업** | 자동 백업 및 복구 지원 |
{% endhint %}

---

## 📈 기술 스택 비교

### **서버 프레임워크 선택 근거**

| 프레임워크 | 장점 | 단점 | 선택 여부 | 성능 |
|------------|------|------|-----------|------|
| **Undertow** | 초경량, 고성능, 임베디드 | 커뮤니티 작음 | ✅ 선택 | ${undertow.rps} RPS |
| Spring Boot | 풍부한 생태계 | 무겁고 복잡 | ❌ | 200K RPS |
| Vert.x | 리액티브, 폴리글랏 | 학습 곡선 높음 | ❌ | 800K RPS |
| Netty | 최고 성능 | 저수준 API | ❌ | 1.4M RPS |

### **AI 서비스 선택 근거**

#### ✅ **Claude vs GPT-4**
> * 더 나은 코드 생성 능력 (${claude.humaneval.score})
> * 한국어 이해도 우수
> * 일관된 출력 형식
> * 비용 효율적
> * 창의성 점수: ${claude.creative.score}

#### ✅ **Meshy vs 기타 3D AI**
> * 빠른 생성 속도 (${total.process.time.avg})
> * 높은 품질의 모델 (${meshy.quality.score})
> * Unity 호환 포맷 (FBX)
> * 합리적인 가격 (${meshy.total.cost.per.model}/모델)

---

## 🔗 기술 통합 다이어그램

{% mermaid %}
sequenceDiagram
    participant C as Client
    participant S as Server
    participant CL as Claude AI
    participant ME as Meshy AI
    participant FB as Firebase

    C->>S: POST /room/create
    S->>S: Queue Request
    S-->>C: Return ruid

    S->>CL: Generate Scenario
    CL-->>S: Scenario JSON

    S->>CL: Generate Scripts
    CL-->>S: CSharp Scripts

    S->>ME: Generate 3D Models
    ME-->>S: Model IDs

    S->>FB: Store Result

    C->>S: GET /room/result
    S-->>C: Complete Data
{% endmermaid %}

---

## 🛡️ 추가 기술 구성

### **보안 및 인증**
- API Key 기반 인증
- 환경 변수 관리
- HTTPS 지원 (프로덕션)

### **모니터링 및 로깅**
- SLF4J + Logback
- 상세한 에러 추적
- 성능 메트릭 수집

### **개발 도구**
- Maven 빌드 시스템
- JUnit 5 테스팅
- IntelliJ IDEA 지원

---

> 💡 각 기술은 **최고의 성능**과 **개발 효율성**을 위해 신중히 선택되었습니다.