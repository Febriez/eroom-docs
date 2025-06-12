# 3.4 룸 기반 요청 처리 시스템

## 🏠 룸 서비스 개요

{% hint style="info" %}
### **AI 기반 방탈출 생성의 핵심**
시나리오 생성부터 3D 모델링까지 전체 프로세스를 관리하는 중앙 서비스
{% endhint %}

---

## 🔄 전체 처리 플로우

{% mermaid %}
flowchart TB
    subgraph "요청 처리"
        A[RoomCreationRequest] --> B[검증]
        B --> C[시나리오 생성]
        C --> D[3D 모델 생성 시작]
        C --> E[스크립트 생성]
        D --> F[모델 완료 대기]
        E --> G[결과 통합]
        F --> G
        G --> H[최종 응답]
    end

    style C fill:#4a90e2
    style D fill:#e74c3c
    style E fill:#4a90e2
{% endmermaid %}

---

## 📋 RoomServiceImpl 구조

### 주요 구성 요소

{% hint style="success" %}
#### 🏗️ **서비스 아키텍처**

```java
public class RoomServiceImpl implements RoomService, AutoCloseable {
    private static final int MODEL_TIMEOUT_MINUTES = ${model.generation.timeout.minutes};
    private static final int EXECUTOR_SHUTDOWN_TIMEOUT_SECONDS = ${executor.shutdown.timeout.seconds};
    
    private final AiService aiService;           // AI 시나리오/스크립트
    private final MeshService meshService;       // 3D 모델 생성
    private final ConfigurationManager configManager;  // 설정 관리
    private final ExecutorService executorService;     // 병렬 처리
    private final RequestValidator requestValidator;   // 요청 검증
    private final ScenarioValidator scenarioValidator; // 시나리오 검증
    
    public JsonObject createRoom(RoomCreationRequest request, String ruid) {
        // 전체 룸 생성 프로세스 조율
    }
}
```

**특징:**
- ✅ 병렬 처리로 시간 단축 (${room.service.executor.threads}개 스레드)
- ✅ 타임아웃 관리 (${model.generation.timeout.minutes}분)
- ✅ 리소스 자동 정리 (AutoCloseable)
- ✅ 에러 격리 및 복구
- ✅ 검증기 분리로 책임 명확화
  {% endhint %}

---

## 🎯 핵심 처리 단계

### 1️⃣ **요청 검증 (Request Validation)**

{% hint style="success" %}
#### ✅ **검증 규칙 (RoomRequestValidator)**

| 필드 | 검증 내용 | 실패 시 동작 | 에러 메시지 |
|------|-----------|--------------|------------|
| `uuid` | 비어있지 않음, 공백 제거 | IllegalArgumentException | "UUID가 비어있습니다" |
| `theme` | 비어있지 않음, 최대 100자 | IllegalArgumentException | "테마가 비어있습니다" |
| `keywords` | 최소 1개, 각각 유효 | IllegalArgumentException | "키워드가 비어있습니다" / "빈 키워드가 포함되어 있습니다" |
| `difficulty` | easy/normal/hard | 기본값 "normal" | "유효하지 않은 난이도입니다. easy, normal, hard 중 하나를 선택하세요." |
| `room_prefab` | https:// URL | IllegalArgumentException | "roomPrefab URL이 비어있습니다" / "유효하지 않은 roomPrefab URL 형식입니다" |

```java
public class RoomRequestValidator implements RequestValidator {
    @Override
    public void validate(RoomCreationRequest request) {
        validateUuid(request);
        validateTheme(request);
        validateKeywords(request);
        validateRoomPrefab(request);
        validateDifficulty(request);
    }
}
```
{% endhint %}

### 2️⃣ **시나리오 생성 (Scenario Generation)**

{% hint style="info" %}
#### 🎭 **AI 시나리오 생성 및 검증**

**시나리오 검증 (DefaultScenarioValidator):**
```java
public class DefaultScenarioValidator implements ScenarioValidator {
    @Override
    public void validate(JsonObject scenario) {
        validateStructure(scenario);      // scenario_data, object_instructions 필수
        validateScenarioData(scenario);   // theme, description, escape_condition, puzzle_flow
        validateObjectInstructions(scenario); // GameManager가 첫 번째 오브젝트인지 확인
    }
}
```

**입력 데이터:**
```json
{
  "uuid": "user_12345",
  "ruid": "room_a1b2c3",
  "theme": "우주정거장",
  "keywords": ["미래", "과학"],
  "difficulty": "normal",
  "room_prefab_url": "https://..."
}
```

**처리 시간:** ${scenario.generation.time.avg}
{% endhint %}

### 3️⃣ **3D 모델 생성 (Model Generation)**

{% hint style="warning" %}
#### 🎨 **병렬 모델 생성 및 실패 추적**

{% mermaid %}
graph LR
    A[Object Instructions] --> B[GameManager 제외]
    B --> C[병렬 생성 시작]

    C --> D1[Model 1]
    C --> D2[Model 2]
    C --> D3[Model N]

    D1 --> E[CompletableFuture]
    D2 --> E
    D3 --> E

    E --> F[최대 10분 대기]
    F --> G{결과 수집}
    G -->|성공| H[tracking에 추가]
    G -->|실패| I[failed_models에 추가]
{% endmermaid %}

**실패 추적 메커니즘:**
- `error-` 접두사: 생성 실패
- `timeout-` 접두사: 타임아웃
- `no-tracking-` 접두사: ID 없음

**모델 건너뛰기 조건:**
1. GameManager (type: "game_manager")
2. 필수 필드 누락 (name, visual_description)
3. 빈 이름 또는 설명

**결과 추적:**
```json
{
  "OxygenTank": "mesh_tracking_id_1",
  "ControlPanel": "mesh_tracking_id_2",
  "failed_models": {
    "BrokenDoor": "timeout-preview-123",
    "error_3": "collection_error-1234567890"
  }
}
```
{% endhint %}

### 4️⃣ **스크립트 생성 (Script Generation)**

{% hint style="info" %}
#### 💻 **Unity C# 스크립트 생성**

**통합 스크립트 요청:**
```java
private JsonObject buildScriptRequest(JsonObject scenario, String roomPrefabUrl) {
    JsonObject scriptRequest = new JsonObject();
    scriptRequest.add("scenario_data", scenario.getAsJsonObject("scenario_data"));
    scriptRequest.add("object_instructions", scenario.getAsJsonArray("object_instructions"));
    scriptRequest.addProperty("room_prefab_url", roomPrefabUrl);
    return scriptRequest;
}
```

**스크립트 특징:**
- Unity6 최신 API 사용
- InputSystem 통합
- 에러 처리 포함
- 한국어 디버그 메시지
- Base64 인코딩으로 전송
- Temperature: ${anthropic.script.temperature} (낮은 창의성, 높은 정확성)

**처리 시간:** ${script.generation.time.avg}
{% endhint %}

---

## ⚡ 병렬 처리 최적화

### 동시 실행 구조

```java
// 시나리오 생성 (동기)
JsonObject scenario = createIntegratedScenario(request, ruid);

// 3D 모델 생성 시작 (비동기) - 최대 ${room.service.executor.threads}개 동시
List<CompletableFuture<ModelGenerationResult>> modelFutures = 
    startModelGeneration(scenario);

// 스크립트 생성 (시나리오 완료 후 시작)
Map<String, String> allScripts = 
    createUnifiedScripts(scenario, request.getRoomPrefab());

// 모델 생성 완료 대기 (최대 ${model.generation.timeout.minutes}분)
JsonObject modelTracking = waitForModels(modelFutures);
```

### 시간 절약 효과

{% hint style="success" %}
#### ⏱️ **처리 시간 비교**

| 방식 | 시나리오 | 스크립트 | 3D 모델 | 총 시간 |
|------|----------|-----------|---------|---------|
| **순차 처리** | ${scenario.generation.time.avg} | ${script.generation.time.avg} | 5개×3분=15분 | 18-21분 |
| **병렬 처리** | ${scenario.generation.time.avg} | ${script.generation.time.avg} (동시) | ${model.refine.time.min}-${model.refine.time.max} (동시) | **${total.process.time.avg}** |

**60-70% 시간 단축 효과**
{% endhint %}

---

## 🛡️ 에러 처리 전략

### 계층별 에러 처리

{% hint style="danger" %}
#### ⚠️ **에러 복구 메커니즘**

```java
try {
    requestValidator.validate(request);
} catch (IllegalArgumentException e) {
    // 검증 실패 - 사용자 오류
    return createErrorResponse(request, ruid, e.getMessage());
}

try {
    // 메인 로직
} catch (RuntimeException e) {
    // 비즈니스 로직 오류
    log.error("통합 방 생성 중 비즈니스 오류 발생: ruid={}", ruid, e);
    return createErrorResponse(request, ruid, e.getMessage());
} catch (Exception e) {
    // 시스템 오류
    log.error("통합 방 생성 중 시스템 오류 발생: ruid={}", ruid, e);
    return createErrorResponse(request, ruid, "시스템 오류가 발생했습니다");
}
```

**에러 응답 형식:**
```json
{
  "uuid": "user_12345",
  "ruid": "room_12345",
  "success": false,
  "error": "구체적인 에러 메시지",
  "timestamp": "1234567890"
}
```
{% endhint %}

---

## 📊 리소스 관리

### ExecutorService 관리

```java
public class RoomServiceImpl implements AutoCloseable {
    private final ExecutorService executorService;
    
    public RoomServiceImpl(...) {
        // ${room.service.executor.threads}개 스레드 풀
        this.executorService = Executors.newFixedThreadPool(${room.service.executor.threads});
    }
    
    @Override
    public void close() {
        log.info("RoomService 종료 시작");
        executorService.shutdown();
        
        // ${executor.shutdown.timeout.seconds}초 대기
        if (!executorService.awaitTermination(${executor.shutdown.timeout.seconds}, TimeUnit.SECONDS)) {
            log.warn("ExecutorService가 정상적으로 종료되지 않아 강제 종료합니다");
            executorService.shutdownNow();
        }
        log.info("RoomService 종료 완료");
    }
}
```

### 메모리 사용 패턴

| 단계 | 예상 메모리 | 지속 시간 |
|------|-------------|-----------|
| 요청 수신 | ${request.data.avg.size} | 순간 |
| 시나리오 생성 | ${scenario.data.avg.size} | ${scenario.generation.time.avg} |
| 스크립트 생성 | ~100KB | ${script.generation.time.avg} |
| 3D 모델 추적 | ${model.metadata.avg.size} | ${model.refine.time.avg} |
| 최종 응답 | ${response.data.avg.size} | 전송까지 |

---

## 🔍 모니터링 포인트

### 주요 로그 메시지

{% hint style="info" %}
#### 📝 **로그 레벨별 기록**

```java
// INFO: 주요 단계 시작/완료
log.info("통합 방 생성 시작: ruid={}, user_uuid={}, theme={}, difficulty={}",
         ruid, request.getUuid(), request.getTheme(), request.getValidatedDifficulty());
log.info("통합 시나리오 생성 완료. ruid: {}, 오브젝트 설명 {}개",
         ruid, objectInstructions.size());
log.info("마크다운 스크립트 Base64 인코딩 완료: {} 개의 스크립트", encodedScripts.size());

// DEBUG: 상세 진행 상황
log.debug("3D 모델 생성 요청 [{}]: name='{}', prompt='{}자'", index, name, prompt.length());
log.debug("모델 추적 ID 추가: {} -> {}", objectName, trackingId);

// WARN: 부분 실패 (계속 진행)
log.warn("object_instructions[{}]에 필수 필드가 없습니다. 건너뜁니다.", i);
log.warn("모델 생성 타임아웃 발생, 현재까지 완료된 결과만 수집");
log.warn("GameManager 스크립트가 파싱되지 않았습니다");

// ERROR: 치명적 오류
log.error("통합 방 생성 중 시스템 오류 발생: ruid={}", ruid, e);
log.error("모델 생성 실패: {} - {}", name, e.getMessage());
```
{% endhint %}

---

## 🚀 성능 특성

### 📊 **핵심 성능 지표**

#### ⏱️ **평균 처리 시간**
> **${total.process.time.avg}**
>
> 전체 방탈출 생성 완료

#### 🔄 **동시 처리**
> **${room.service.executor.threads}개**
>
> 3D 모델 병렬 생성

#### ✅ **성공률**
> **${overall.success.rate}**
>
> 에러 복구 포함

#### ⏰ **타임아웃**
> **${model.generation.timeout.minutes}분**
>
> 모델 생성 최대 대기

---

## 🎨 추가 기능 상세

### 키워드 중복 제거

```java
private JsonArray createKeywordsArray(String[] keywords) {
  JsonArray array = new JsonArray();
  Set<String> uniqueKeywords = new LinkedHashSet<>(); // 순서 유지

  for (String keyword : keywords) {
    if (keyword != null && !keyword.trim().isEmpty()) {
      uniqueKeywords.add(keyword.trim().toLowerCase());
    }
  }

  for (String keyword : uniqueKeywords) {
    array.add(keyword);
  }

  return array;
}
```

### 스크립트 파일명 처리

```java
private String ensureFileExtension(String fileName) {
  return fileName.endsWith(".cs") ? fileName : fileName + ".cs";
}
```

---

> 💡 RoomService는 복잡한 AI 통합을 **단순하고 안정적**으로 만듭니다.