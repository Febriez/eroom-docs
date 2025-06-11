# 1.3 기술 스택 요약

## 🛠️ 기술 스택 개요

{% hint style="info" %}
### **최신 기술의 완벽한 조합**
성능, 안정성, 확장성을 모두 고려한 기술 선택
{% endhint %}

---

## 📊 기술 스택 전체 구조

```mermaid
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
```

---

## 🔧 백엔드 기술 상세

### ☕ **Java 17 LTS**

{% hint style="success" %}
#### **선택 이유**
* **장기 지원(LTS)**: 2029년까지 보안 업데이트 보장
* **최신 기능**: Records, Pattern Matching, Text Blocks
* **성능 향상**: G1GC 개선, JIT 컴파일러 최적화
* **생태계**: 풍부한 라이브러리와 도구
  {% endhint %}

### 🚀 **Undertow**

| 특징 | 설명 |
|------|------|
| **Non-blocking I/O** | XNIO 기반 고성능 처리 |
| **낮은 메모리 사용** | 경량 설계로 효율적 리소스 활용 |
| **임베디드 가능** | 별도 서버 설치 불필요 |
| **HTTP/2 지원** | 최신 프로토콜 완벽 지원 |

### 📦 **주요 라이브러리**

#### **Gson**
> * Google의 JSON 처리 라이브러리
> * 간단한 API와 높은 성능
> * 커스텀 직렬화 지원

#### **OkHttp**
> * Square의 HTTP 클라이언트
> * 연결 풀링과 캐싱
> * 자동 재시도 메커니즘

---

## 🤖 AI 서비스 통합

### **Anthropic Claude AI**

{% hint style="info" %}
#### **Claude Sonnet 4** (claude-sonnet-4-20250514)
최신 대형 언어 모델로 창의적이고 정확한 콘텐츠 생성

**최대 토큰 수: 16K**
{% endhint %}

**활용 분야:**
- 🎭 **시나리오 생성**: 창의적인 방탈출 스토리와 퍼즐 설계
- 💻 **스크립트 생성**: Unity C# 게임 로직 자동 생성
- 🎯 **난이도 조절**: Easy/Normal/Hard별 맞춤 콘텐츠

### **Meshy AI**

{% hint style="warning" %}
#### **Text-to-3D Generation API**

| 단계 | 소요 시간 | 설명 |
|------|-----------|------|
| **Preview** | 1-3분 | 빠른 프리뷰 생성 |
| **Refine** | 3-5분 | 고품질 정제 |
| **Export** | FBX | Unity 호환 포맷 |
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
{% endhint %}

---

## 📈 기술 스택 비교

### **서버 프레임워크 선택 근거**

| 프레임워크 | 장점 | 단점 | 선택 여부 |
|------------|------|------|-----------|
| **Undertow** | 초경량, 고성능, 임베디드 | 커뮤니티 작음 | ✅ 선택 |
| Spring Boot | 풍부한 생태계 | 무겁고 복잡 | ❌ |
| Vert.x | 리액티브, 폴리글랏 | 학습 곡선 높음 | ❌ |
| Netty | 최고 성능 | 저수준 API | ❌ |

### **AI 서비스 선택 근거**

#### ✅ **Claude vs GPT-4**
> * 더 나은 코드 생성 능력
> * 한국어 이해도 우수
> * 일관된 출력 형식
> * 비용 효율적

#### ✅ **Meshy vs 기타 3D AI**
> * 빠른 생성 속도
> * 높은 품질의 모델
> * Unity 호환 포맷
> * 합리적인 가격

---

## 🔗 기술 통합 다이어그램

```mermaid
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
    CL-->>S: C# Scripts
    
    S->>ME: Generate 3D Models
    ME-->>S: Model IDs
    
    S->>FB: Store Result
    
    C->>S: GET /room/result
    S-->>C: Complete Data
```

---

> 💡 각 기술은 **최고의 성능**과 **개발 효율성**을 위해 신중히 선택되었습니다.