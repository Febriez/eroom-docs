# 3.6 Meshy AI 연동

## 🎨 Meshy 서비스 개요

<div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">Text-to-3D 모델 자동 생성</h3>
  <p style="margin: 10px 0 0 0;">텍스트 설명만으로 고품질 3D 모델을 생성하는 AI 서비스 통합</p>
</div>

---

## 🏗️ MeshyApiService 구조

### 주요 구성 요소

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔧 서비스 아키텍처</h4>

```java
public class MeshyApiService implements MeshService {
    private static final Logger log = LoggerFactory.getLogger(MeshyApiService.class);
    private static final MediaType JSON = MediaType.get("application/json; charset=utf-8");
    private static final String MESHY_API_BASE_URL = "https://api.meshy.ai/openapi/v2/text-to-3d";
    private static final int TIMEOUT_SECONDS = 30;
    private static final int MAX_POLLING_ATTEMPTS = 100;
    private static final int POLLING_INTERVAL_MS = 3000;

    private final ApiKeyProvider apiKeyProvider;
    private final OkHttpClient httpClient;

    public MeshyApiService(ApiKeyProvider apiKeyProvider) {
        this.apiKeyProvider = apiKeyProvider;
        this.httpClient = createHttpClient();
    }
}
```

**특징:**

- ✅ 2단계 생성 (Preview → Refine)
- ✅ 다중 API 키 로드밸런싱
- ✅ 비동기 상태 추적
- ✅ FBX 포맷 출력
- ✅ 폴링 기반 진행 상황 확인

</div>

---

## 🔄 3D 모델 생성 프로세스

### 전체 생성 플로우

{% mermaid %}
flowchart TB
A[텍스트 설명] --> B[Preview 생성]
B --> C{상태 확인}
C -->|PENDING/IN_PROGRESS| D[3초 대기]
D --> C
C -->|SUCCEEDED| E[Refine 요청]
E --> F{상태 확인}
F -->|PENDING/IN_PROGRESS| G[3초 대기]
G --> F
F -->|SUCCEEDED| H[FBX URL 추출]
H --> I[URL 반환]

    C -->|FAILED| J[에러 ID 반환]
    F -->|FAILED| J
    
    style B fill:#4a90e2
    style E fill:#4a90e2
    style I fill:#4caf50
    style J fill:#e74c3c

{% endmermaid %}

---

## 🎯 단계별 상세 구현

### 1️⃣ **Preview 생성**

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🖼️ 빠른 프리뷰 모델</h4>

```java

@Nullable
private String createPreview(String prompt, String apiKey) {
    try {
        JsonObject requestBody = createPreviewRequestBody(prompt);
        JsonObject responseJson = callMeshyApi(requestBody, apiKey);
        return extractResourceId(responseJson);
    } catch (Exception e) {
        log.error("프리뷰 생성 중 오류 발생: {}", e.getMessage());
        return null;
    }
}

@NotNull
private JsonObject createPreviewRequestBody(String prompt) {
    JsonObject requestBody = new JsonObject();
    requestBody.addProperty("mode", "preview");
    requestBody.addProperty("prompt", prompt);
    requestBody.addProperty("art_style", "realistic");
    requestBody.addProperty("ai_model", "meshy-4");
    requestBody.addProperty("topology", "triangle");
    requestBody.addProperty("target_polycount", 30000);
    requestBody.addProperty("should_remesh", true);
    return requestBody;
}
```

**특징:**

- 빠른 생성 (1-3분)
- 낮은 품질
- 기본 형태 확인용
- 다음 단계 필수

</div>

### 2️⃣ **상태 확인 (Polling)**

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔄 진행 상황 모니터링</h4>

```java
private boolean isTaskFailed(String taskId, String apiKey) {
    try {
        for (int i = 0; i < MAX_POLLING_ATTEMPTS; i++) {
            JsonObject taskStatus = getTaskStatus(taskId, apiKey);
            if (taskStatus == null) {
                log.error("작업 상태 조회 실패");
                return true;
            }

            String status = taskStatus.get("status").getAsString();
            int progress = taskStatus.get("progress").getAsInt();

            log.info("작업 상태: {}, 진행률: {}%", status, progress);

            if ("SUCCEEDED".equals(status)) {
                return false;
            } else if ("FAILED".equals(status) || "CANCELED".equals(status)) {
                if (taskStatus.has("task_error") &&
                        taskStatus.getAsJsonObject("task_error").has("message")) {
                    String errorMessage = taskStatus.getAsJsonObject("task_error")
                            .get("message").getAsString();
                    log.error("작업 실패: {}", errorMessage);
                }
                return true;
            }

            Thread.sleep(POLLING_INTERVAL_MS);
        }

        log.error("작업 생성 시간 초과");
        return true;
    } catch (Exception e) {
        log.error("상태 확인 중 오류 발생: {}", e.getMessage());
        return true;
    }
}
```

**상태 값:**

- PENDING: 대기 중
- IN_PROGRESS: 처리 중
- SUCCEEDED: 성공
- FAILED: 실패
- CANCELED: 취소됨

</div>

### 3️⃣ **Refine 생성**

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">💎 고품질 최종 모델</h4>

```java

@Nullable
private String refineModel(String previewId, String apiKey) {
    try {
        JsonObject requestBody = createRefineRequestBody(previewId);
        JsonObject responseJson = callMeshyApi(requestBody, apiKey);
        return extractResourceId(responseJson);
    } catch (Exception e) {
        log.error("모델 정제 중 오류 발생: {}", e.getMessage());
        return null;
    }
}

@NotNull
private JsonObject createRefineRequestBody(String previewId) {
    JsonObject requestBody = new JsonObject();
    requestBody.addProperty("mode", "refine");
    requestBody.addProperty("preview_task_id", previewId);
    requestBody.addProperty("enable_pbr", true);
    return requestBody;
}
```

**특징:**

- 고품질 생성 (3-5분)
- FBX 포맷 (Unity 최적)
- 텍스처 포함
- 최종 사용 가능

</div>

---

## 🔑 다중 API 키 관리

### 로드밸런싱 전략

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚖️ API 키 분산</h4>

```java
// EnvironmentApiKeyProvider에서
@Override
public String getMeshyKey(int index) {
    int keyIndex = index % MESHY_KEYS.length;
    String key = MESHY_KEYS[keyIndex];

    if (key == null) {
        throw new NoAvailableKeyException("사용 가능한 MESHY_KEY가 없습니다. Index: " + keyIndex);
    }

    return key;
}
```

**장점:**

- API 한도 분산
- 동시 요청 증가
- 장애 격리
- 비용 분산

**사용 예:**

```java
// 오브젝트 인덱스 기반 키 선택
String apiKey = apiKeyProvider.getMeshyKey(keyIndex);
log.

info("{}의 모델 생성 시작, 키 인덱스: {}",objectName, keyIndex);
```

</div>

---

## 📊 성능 특성

### 처리 시간 분석

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⏱️ 단계별 소요 시간</h4>

| 단계             | 최소 | 평균  | 최대  |
|----------------|----|-----|-----|
| **Preview 생성** | 1분 | 2분  | 3분  |
| **Preview 폴링** | -  | 30초 | 1분  |
| **Refine 생성**  | 3분 | 4분  | 5분  |
| **Refine 폴링**  | -  | 30초 | 1분  |
| **총 시간**       | 4분 | 7분  | 10분 |

  <div style="margin-top: 15px; padding: 10px; background: #c8e6c9; border-radius: 5px;">
    <strong>💡 최적화 팁:</strong> 여러 모델을 병렬로 생성하여 전체 시간 단축
  </div>
</div>

---

## 🛡️ 에러 처리

### 에러 타입별 처리

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚠️ 에러 ID 체계</h4>

```java

@Override
public String generateModel(String prompt, String objectName, int keyIndex) {
    try {
        String apiKey = apiKeyProvider.getMeshyKey(keyIndex);
        log.info("{}의 모델 생성 시작, 키 인덱스: {}", objectName, keyIndex);
        return processModelGeneration(prompt, objectName, apiKey);
    } catch (Exception e) {
        log.error("{}의 모델 생성 중 오류 발생: {}", objectName, e.getMessage());
        return "error-general-" + UUID.randomUUID().toString();
    }
}

@NotNull
private String processModelGeneration(String prompt, String objectName, String apiKey) {
    try {
        String previewId = createPreview(prompt, apiKey);
        if (previewId == null) {
            log.error("{}의 프리뷰 생성 실패", objectName);
            return "error-preview-" + UUID.randomUUID();
        }

        log.info("{}의 프리뷰가 ID: {}로 생성됨", objectName, previewId);
        return processPreview(previewId, objectName, apiKey);
    } catch (Exception e) {
        log.error("{}의 프리뷰 생성 단계에서 오류 발생: {}", objectName, e.getMessage());
        return "error-preview-exception-" + UUID.randomUUID().toString();
    }
}
```

**에러 ID 패턴:**

| 패턴                     | 의미        | 예시                      |
|------------------------|-----------|-------------------------|
| `error-preview-{UUID}` | 프리뷰 생성 실패 | error-preview-abc123    |
| `timeout-preview-{ID}` | 프리뷰 타임아웃  | timeout-preview-xyz789  |
| `error-refine-{ID}`    | 정제 실패     | error-refine-preview123 |
| `error-general-{UUID}` | 일반 오류     | error-general-def456    |

**에러 복구:**

- 실패한 모델은 추적 ID에 기록
- 다른 모델 생성은 계속 진행
- 부분 성공 허용

</div>

---

## 📈 API 사용 현황

### HTTP 클라이언트 설정

```java

@NotNull
@Contract(" -> new")
private OkHttpClient createHttpClient() {
    return new OkHttpClient.Builder()
            .connectTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .readTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .writeTimeout(TIMEOUT_SECONDS, TimeUnit.SECONDS)
            .build();
}
```

### API 호출 통계

| 메트릭       | 값     | 설명         |
|-----------|-------|------------|
| **성공률**   | 95%+  | 대부분 성공     |
| **평균 응답** | 200ms | API 응답 시간  |
| **타임아웃**  | 30초   | 연결/읽기/쓰기   |
| **재시도**   | 없음    | 상위 레벨에서 처리 |

---

## 🎯 결과 추적

### 모델 추적 ID 관리

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📍 추적 ID 활용</h4>

**성공 시 (FBX URL):**

```json
{
  "SpaceHelmet": "https://assets.meshy.ai/abc123/model.fbx",
  "ControlPanel": "https://assets.meshy.ai/def456/model.fbx"
}
```

**실패 포함:**

```json
{
  "SpaceHelmet": "https://assets.meshy.ai/abc123/model.fbx",
  "BrokenDoor": "timeout-preview-xyz789",
  "failed_models": {
    "BrokenDoor": "timeout-preview-xyz789"
  }
}
```

**클라이언트 활용:**

- FBX URL로 직접 모델 다운로드
- 실패한 모델 대체 처리
- 진행 상황 표시

</div>

---

## 🚀 최적화 전략

<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e3f2fd; padding: 20px; border-radius: 10px;">
    <h4 style="margin: 0 0 10px 0;">현재 최적화</h4>
    <ul style="margin: 0;">
      <li>3개 API 키 로드밸런싱</li>
      <li>병렬 모델 생성</li>
      <li>효율적 폴링 (3초)</li>
      <li>타임아웃 관리 (10분)</li>
    </ul>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px;">
    <h4 style="margin: 0 0 10px 0;">추가 가능 최적화</h4>
    <ul style="margin: 0;">
      <li>웹훅 기반 알림</li>
      <li>프리뷰 스킵 옵션</li>
      <li>모델 캐싱</li>
      <li>품질 레벨 선택</li>
    </ul>
  </div>
</div>

---

## 💻 실제 사용 예시

### 전체 처리 흐름

```java

@NotNull
private String refineModelAfterPreview(String previewId, String objectName, String apiKey) {
    try {
        String refineId = refineModel(previewId, apiKey);
        if (refineId == null) {
            log.error("{}의 모델 정제 실패", objectName);
            return "error-refine-" + previewId;
        }

        log.info("{}의 정제 작업이 ID: {}로 시작됨. 완료 대기 중...", objectName, refineId);

        // Refine 작업 완료 대기
        if (isTaskFailed(refineId, apiKey)) {
            log.error("{}의 정제 작업 완료 시간 초과", objectName);
            return "timeout-refine-" + refineId;
        }

        // 완료된 작업의 상세 정보 조회
        JsonObject taskDetails = getCompletedTaskDetails(refineId, apiKey);
        if (taskDetails == null) {
            log.error("{}의 완료된 작업 정보 조회 실패", objectName);
            return "error-fetch-details-" + refineId;
        }

        // FBX URL 추출
        String fbxUrl = extractFbxUrl(taskDetails);
        if (fbxUrl == null) {
            log.error("{}의 FBX URL 추출 실패", objectName);
            return "error-no-fbx-" + refineId;
        }

        log.info("{}의 모델 생성 완료. FBX URL: {}", objectName, fbxUrl);
        return fbxUrl;

    } catch (Exception e) {
        log.error("{}의 모델 정제 단계에서 오류 발생: {}", objectName, e.getMessage());
        return "error-refine-exception-" + previewId;
    }
}
```

---

## 💰 비용 분석

| 항목         | 단가        | 월간 사용량     | 월간 비용    |
|------------|-----------|------------|----------|
| Preview 생성 | $0.05     | 3,000개     | $150     |
| Refine 생성  | $0.15     | 3,000개     | $450     |
| **총 비용**   | **$0.20** | **3,000개** | **$600** |

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>Meshy 서비스는 <strong>텍스트를 3D로</strong> 변환하는 마법을 제공합니다.</p>
</div>