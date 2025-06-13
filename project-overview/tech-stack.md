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

| 특징                   | 설명                      |
|----------------------|-------------------------|
| **Non-blocking I/O** | XNIO 기반 고성능 처리          |
| **낮은 메모리 사용**        | ~50MB 경량 설계로 효율적 리소스 활용 |
| **임베디드 가능**          | 별도 서버 설치 불필요            |
| **HTTP/2 지원**        | 최신 프로토콜 완벽 지원           |
| **동시 연결**            | 10,000+ 연결 처리 가능        |
| **응답 지연**            | < 5ms 낮은 레이턴시           |

### 📦 **주요 라이브러리**

#### **Gson 2.10.1**

> * Google의 JSON 처리 라이브러리
> * 간단한 API와 높은 성능
> * 커스텀 직렬화 지원
> * Null 안전성 지원

#### **OkHttp 4.12.0**

> * Square의 HTTP 클라이언트
> * 연결 풀링과 캐싱
> * 자동 재시도 메커니즘
> * HTTP/2 지원
> * 타임아웃 설정 (30초)

#### **SLF4J + Logback**

> * 표준 로깅 인터페이스
> * 유연한 로그 레벨 설정
> * 비동기 로깅 지원
> * 파일 로테이션 기능

---

## 🤖 AI 서비스 통합

### **Anthropic Claude AI**

{% hint style="info" %}

#### **Claude Sonnet 4** (claude-sonnet-4-20250514)

최신 대형 언어 모델로 창의적이고 정확한 콘텐츠 생성

**모델 설정:**

- **최대 토큰**: 16,000
- **시나리오 Temperature**: 0.9 (높은 창의성)
- **스크립트 Temperature**: 0.1 (높은 정확성)
  {% endhint %}

**활용 분야:**

- 🎭 **시나리오 생성**: 창의적인 방탈출 스토리와 퍼즐 설계
- 💻 **스크립트 생성**: Unity6 C# 게임 로직 자동 생성
- 🎯 **난이도 조절**: Easy/Normal/Hard별 맞춤 콘텐츠

**성능 특성:**

- 시나리오 생성: 60초
- 스크립트 생성: 20초
- 토큰 효율성: 압축 프롬프트로 45% 절감
- 성공률: 98%+

### **Meshy AI**

{% hint style="warning" %}

#### **Text-to-3D Generation API v2**

| 단계          | 소요 시간 | 설명          | API 모드          |
|-------------|-------|-------------|-----------------|
| **Preview** | 1-3분  | 빠른 프리뷰 생성   | mode: "preview" |
| **Refine**  | 3-5분  | 고품질 정제      | mode: "refine"  |
| **Export**  | 즉시    | Unity 호환 포맷 | format: "fbx"   |

**API 특성:**

- 폴링 간격: 3초
- 최대 폴링 횟수: 200회 (10분)
- API 키: 3개 로드밸런싱
- 성공률: 95%+
  {% endhint %}

---

## 🎮 프론트엔드 기술

### **Unity6**

| 기능                   | 활용                |
|----------------------|-------------------|
| **최신 렌더링**           | URP/HDRP로 고품질 그래픽 |
| **새로운 Input System** | 다양한 입력 장치 지원      |
| **UI Toolkit**       | 현대적인 UI 구현        |
| **C# 9.0**           | 최신 언어 기능 활용       |
| **Addressables**     | 효율적인 에셋 관리        |

---

## 💾 데이터 저장소

### **Firebase Firestore**

{% hint style="warning" %}

#### **선택 이유**

| 특징          | 설명                        | ERoom에서의 활용 |
|-------------|---------------------------|-------------|
| **실시간 동기화** | 클라이언트 간 즉각적인 데이터 동기화      | 게임 상태 공유    |
| **오프라인 지원** | 네트워크 없이도 작동, 재연결 시 자동 동기화 | 안정적인 플레이    |
| **확장성**     | 자동 샤딩으로 무제한 확장 가능         | 사용자 증가 대응   |
| **보안 규칙**   | 세밀한 접근 권한 제어              | 사용자별 데이터 보호 |
| **백업**      | 자동 백업 및 복구 지원             | 데이터 안전성     |

{% endhint %}

---

## 📈 기술 스택 비교

### **서버 프레임워크 선택 근거**

| 프레임워크        | 장점             | 단점       | 선택 여부 | 성능       |
|--------------|----------------|----------|-------|----------|
| **Undertow** | 초경량, 고성능, 임베디드 | 커뮤니티 작음  | ✅ 선택  | 1.2M RPS |
| Spring Boot  | 풍부한 생태계        | 무겁고 복잡   | ❌     | 200K RPS |
| Vert.x       | 리액티브, 폴리글랏     | 학습 곡선 높음 | ❌     | 800K RPS |
| Netty        | 최고 성능          | 저수준 API  | ❌     | 1.4M RPS |

### **AI 서비스 선택 근거**

#### ✅ **Claude vs GPT-4**

> * 더 나은 코드 생성 능력 (HumanEval 92.0%)
> * 한국어 이해도 우수
> * 일관된 출력 형식
> * 비용 효율적 ($0.015/1K tokens)
> * 빠른 응답 속도 (1-3초)

#### ✅ **Meshy vs 기타 3D AI**

> * 빠른 생성 속도 (총 5-8분)
> * 높은 품질의 모델
> * Unity 호환 포맷 (FBX)
> * 합리적인 가격 ($0.20/모델)
> * 안정적인 API (99.5% 가동률)

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

    S->>CL: Generate Scenario (60s)
    CL-->>S: Scenario JSON

    par 병렬 처리
        S->>CL: Generate Scripts (20s)
        CL-->>S: C# Scripts (Base64)
    and
        S->>ME: Generate 3D Models (5-7분)
        ME-->>S: Model Tracking IDs
    end

    S->>FB: Store Result (선택적)

    C->>S: GET /room/result
    S-->>C: Complete Data

{% endmermaid %}

---

## 🛡️ 추가 기술 구성

### **보안 및 인증**

- API Key 기반 인증 (환경변수 또는 자동 생성)
- 환경 변수 관리
- HTTPS 지원 (프로덕션 권장)

### **모니터링 및 로깅**

- SLF4J + Logback
- 상세한 에러 추적
- 성능 메트릭 수집
- 로그 레벨별 관리 (INFO, DEBUG, WARN, ERROR)

### **개발 도구**

- Maven 빌드 시스템
- JUnit 5 테스팅
- IntelliJ IDEA 지원

---

## 📊 기술 스택 성능 요약

### 전체 시스템 성능

| 지표            | 측정값        | 설명                  |
|---------------|------------|---------------------|
| **전체 처리 시간**  | 5-8분       | 시나리오 + 스크립트 + 3D 모델 |
| **동시 처리 능력**  | 1개 (확장 가능) | 큐 시스템으로 관리          |
| **API 응답 시간** | < 100ms    | 95 percentile       |
| **메모리 사용량**   | < 1GB      | 서버 전체               |
| **시작 시간**     | < 1초       | 콜드 스타트              |

### 비용 효율성

| 항목             | 비용        | 설명               |
|----------------|-----------|------------------|
| **Claude API** | $0.015/요청 | 압축 프롬프트 적용       |
| **Meshy API**  | $0.20/모델  | Preview + Refine |
| **서버 운영**      | $50/월     | 2GB RAM VPS      |
| **총 룸 생성 비용**  | ~$0.35/룸  | 모든 비용 포함         |

---

## 🚀 향후 기술 스택 확장

### 계획된 추가 기술

1. **캐싱 레이어**
    - Redis 도입
    - 프롬프트 캐싱
    - 결과 캐싱

2. **모니터링 강화**
    - Prometheus + Grafana
    - ELK Stack
    - APM 도구

3. **컨테이너화**
    - Docker 이미지
    - Kubernetes 오케스트레이션
    - 자동 스케일링

4. **CI/CD**
    - GitHub Actions
    - 자동 테스트
    - 자동 배포

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>각 기술은 <strong>최고의 성능</strong>과 <strong>개발 효율성</strong>을 위해 신중히 선택되었습니다.</p>
</div>