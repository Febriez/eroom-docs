# 7.3 AI 연동 문제

## 🤖 AI 서비스 통합 트러블슈팅

<div style="background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">Claude & Meshy AI 연동 문제 해결</h3>
  <p style="margin: 10px 0 0 0;">AI API 통합 시 발생하는 주요 문제와 최적화 방법</p>
</div>

---

## 🔑 API 키 관련 문제

### 1. Claude API 키 오류

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">❌ Anthropic API 인증 실패</h4>

**증상:**
```
Anthropic API 키가 설정되지 않았습니다. 서버를 종료합니다.
```

**원인:**
- API 키 환경 변수 누락
- 잘못된 API 키 형식
- 만료된 API 키

**해결 방법:**
```bash
# API 키 형식 확인 (sk-ant-api03-로 시작)
echo $ANTHROPIC_KEY

# 올바른 형식 예시
export ANTHROPIC_KEY="sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# API 키 검증 스크립트
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-3-sonnet-20240229",
    "max_tokens": 1,
    "messages": [{"role": "user", "content": "Hi"}]
  }'
```

**API 키 문제 진단:**
| 오류 메시지 | 원인 | 해결 방법 |
|------------|------|-----------|
| "Invalid API key" | 잘못된 키 | Console에서 키 재확인 |
| "Insufficient credits" | 크레딧 부족 | 결제 정보 업데이트 |
| "Rate limit exceeded" | 요청 한도 초과 | 대기 후 재시도 |
| "Model not found" | 잘못된 모델명 | claude-sonnet-4-20250514 확인 |
</div>

### 2. Meshy API 키 관리

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔑 다중 API 키 설정</h4>

**Meshy 키 로드밸런싱:**
```bash
# 최소 1개 필수, 최대 3개 설정 가능
export MESHY_KEY_1="your-first-meshy-key"
export MESHY_KEY_2="your-second-meshy-key"  # 선택
export MESHY_KEY_3="your-third-meshy-key"   # 선택

# 키 검증
for i in 1 2 3; do
  key_var="MESHY_KEY_$i"
  if [ ! -z "${!key_var}" ]; then
    echo "$key_var is set"
  fi
done
```

**키 할당 전략:**
```java
// ApiKeyProvider 구현
public String getMeshyKey(int index) {
    int keyIndex = index % MESHY_KEYS.length;
    String key = MESHY_KEYS[keyIndex];
    
    if (key == null) {
        throw new NoAvailableKeyException("사용 가능한 MESHY_KEY가 없습니다. Index: " + keyIndex);
    }
    
    return key;
}
```

**키별 사용량 모니터링:**
- 각 키마다 월 1000개 모델 생성 제한
- 3개 키 사용 시 월 3000개까지 가능
- 키 로테이션으로 부하 분산
</div>

---

## 📡 API 통신 문제

### 3. Claude API 응답 오류

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🚨 시나리오 생성 실패</h4>

**일반적인 오류와 해결:**

| 문제 | 증상 | 해결 방법 |
|------|------|-----------|
| **토큰 한도 초과** | "max_tokens_exceeded" | maxTokens를 16000으로 설정 확인 |
| **JSON 파싱 실패** | "JSON 파싱 실패" | 프롬프트에 JSON 형식 명시 |
| **응답 없음** | "생성 응답이 비어있습니다" | Temperature 조정 (0.9) |
| **타임아웃** | 60초 이상 대기 | 프롬프트 최적화 |

**프롬프트 디버깅:**
```java
// 프롬프트 로깅 추가
private String executeAnthropicCall(String systemPrompt, JsonObject requestData, String temperatureKey) {
    // 디버그 모드에서 프롬프트 출력
    if (log.isDebugEnabled()) {
        log.debug("System Prompt Length: {} chars", systemPrompt.length());
        log.debug("Request Data: {}", requestData.toString());
    }
    
    try {
        MessageCreateParams params = createMessageParams(systemPrompt, requestData, temperatureKey);
        
        // API 호출 시간 측정
        long startTime = System.currentTimeMillis();
        Message response = getClient().messages().create(params);
        long duration = System.currentTimeMillis() - startTime;
        
        log.info("Claude API 응답 시간: {}ms", duration);
        
        return extractResponseText(response);
    } catch (Exception e) {
        log.error("Claude API 호출 실패: {}", e.getMessage());
        throw new RuntimeException("AI 응답 생성 실패", e);
    }
}
```
</div>

### 4. 스크립트 파싱 오류

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 마크다운 파싱 실패</h4>

**문제 상황:**
- 마크다운 코드 블록 인식 실패
- 스크립트 이름 추출 오류
- 중복 스크립트 이름

**개선된 파싱 로직:**
```java
// 마크다운 블록 패턴
private static final Pattern MARKDOWN_SCRIPT_PATTERN = Pattern.compile(
    "```(?:csharp|cs|c#)?\\s*\\n([\\s\\S]*?)```",
    Pattern.MULTILINE | Pattern.CASE_INSENSITIVE
);

// 스크립트 이름 패턴
private static final Pattern SCRIPT_NAME_PATTERN = Pattern.compile(
    "```(\\w+(?:\\.cs)?)\\s*\\n([\\s\\S]*?)```",
    Pattern.MULTILINE
);

// 클래스 이름 추출
private static final Pattern CLASS_NAME_PATTERN = Pattern.compile(
    "public\\s+(?:partial\\s+)?class\\s+(\\w+)\\s*[:{]",
    Pattern.MULTILINE
);
```

**파싱 실패 시 복구:**
```java
private Map<String, String> parseAndEncodeScripts(String content) {
    Map<String, String> encodedScripts = extractScriptsFromMarkdown(content);
    
    if (encodedScripts.isEmpty()) {
        // 대체 파싱 시도
        log.warn("기본 파싱 실패, 대체 방법 시도");
        encodedScripts = extractScriptsAlternative(content);
    }
    
    if (encodedScripts.isEmpty()) {
        log.error("모든 파싱 방법 실패. 응답 내용:\n{}", 
                  content.substring(0, Math.min(500, content.length())));
        terminateWithError("파싱된 스크립트가 없습니다.");
    }
    
    return encodedScripts;
}
```

**일반적인 파싱 문제:**
- 백틱 중첩 (```)
- 언어 식별자 오타 (c# vs cs vs csharp)
- 스크립트명에 .cs 확장자 포함/미포함
- GameManager 스크립트 누락
</div>

---

## 🎨 Meshy AI 문제

### 5. 3D 모델 생성 실패

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🚫 모델 생성 오류</h4>

**일반적인 실패 원인:**

| 에러 ID | 원인 | 해결 방법 |
|---------|------|-----------|
| `error-preview-*` | 프리뷰 생성 실패 | 프롬프트 단순화 |
| `timeout-preview-*` | 프리뷰 타임아웃 | 재시도 또는 건너뛰기 |
| `error-refine-*` | 정제 단계 실패 | 프리뷰 재생성 |
| `error-no-fbx-*` | FBX URL 없음 | API 응답 확인 |

**프롬프트 최적화:**
```java
// 실패하기 쉬운 프롬프트
"복잡한 기계 장치와 여러 개의 버튼, LED 표시등이 있는 제어 패널"

// 최적화된 프롬프트
"Control panel with buttons and lights, industrial style"

// 프롬프트 가이드라인
- 영어 사용 권장
- 100자 이내
- 구체적이고 명확한 설명
- 복잡한 구조 피하기
```

**에러 처리 전략:**
```java
@NotNull
private String processModelGeneration(String prompt, String objectName, String apiKey) {
    int retryCount = 0;
    int maxRetries = 2;
    
    while (retryCount < maxRetries) {
        try {
            String previewId = createPreview(prompt, apiKey);
            if (previewId != null) {
                return processPreview(previewId, objectName, apiKey);
            }
        } catch (Exception e) {
            log.warn("모델 생성 시도 {} 실패: {}", retryCount + 1, e.getMessage());
        }
        
        retryCount++;
        if (retryCount < maxRetries) {
            // 프롬프트 단순화
            prompt = simplifyPrompt(prompt);
        }
    }
    
    return "error-max-retries-" + UUID.randomUUID();
}

private String simplifyPrompt(String original) {
    // 프롬프트 단순화 로직
    if (original.length() > 100) {
        return original.substring(0, 100);
    }
    return original.replaceAll("[^a-zA-Z0-9\\s,.]", "");
}
```
</div>

### 6. 모델 생성 타임아웃

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⏱️ 처리 시간 초과</h4>

**타임아웃 관리:**
```java
private static final int MAX_POLLING_ATTEMPTS = 100;  // 5분 (3초 * 100)
private static final int POLLING_INTERVAL_MS = 3000;  // 3초

private boolean isTaskFailed(String taskId, String apiKey) {
    try {
        for (int i = 0; i < MAX_POLLING_ATTEMPTS; i++) {
            JsonObject taskStatus = getTaskStatus(taskId, apiKey);
            
            // 상태별 처리
            String status = taskStatus.get("status").getAsString();
            int progress = taskStatus.get("progress").getAsInt();
            
            // 진행률 기반 타임아웃 조정
            if (i > 50 && progress < 50) {
                log.warn("진행이 너무 느림. 취소 고려");
            }
            
            if ("SUCCEEDED".equals(status)) {
                return false;
            } else if ("FAILED".equals(status)) {
                logFailureReason(taskStatus);
                return true;
            }
            
            Thread.sleep(POLLING_INTERVAL_MS);
        }
        
        log.error("작업 생성 시간 초과: {}초 경과", 
                  (MAX_POLLING_ATTEMPTS * POLLING_INTERVAL_MS) / 1000);
        return true;
        
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        return true;
    }
}

private void logFailureReason(JsonObject taskStatus) {
    if (taskStatus.has("task_error")) {
        JsonObject error = taskStatus.getAsJsonObject("task_error");
        String message = error.get("message").getAsString();
        log.error("Meshy 작업 실패 원인: {}", message);
        
        // 실패 원인별 대응
        if (message.contains("NSFW")) {
            log.error("부적절한 콘텐츠로 판단됨");
        } else if (message.contains("quota")) {
            log.error("API 할당량 초과");
        }
    }
}
```
</div>

---

## 📊 성능 최적화

### 7. API 응답 속도 개선

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚡ 처리 시간 단축</h4>

**병렬 처리 최적화:**
```java
// RoomServiceImpl에서
private List<CompletableFuture<ModelGenerationResult>> startModelGeneration(JsonObject scenario) {
    List<CompletableFuture<ModelGenerationResult>> futures = new ArrayList<>();
    JsonArray objectInstructions = scenario.getAsJsonArray("object_instructions");
    
    // 스레드 풀 크기 최적화
    int optimalThreads = Math.min(objectInstructions.size(), 5);
    ExecutorService modelExecutor = Executors.newFixedThreadPool(optimalThreads);
    
    try {
        for (int i = 0; i < objectInstructions.size(); i++) {
            // 병렬 실행
            futures.add(CompletableFuture.supplyAsync(
                () -> generateModel(instruction, i),
                modelExecutor
            ));
        }
    } finally {
        modelExecutor.shutdown();
    }
    
    return futures;
}
```

**캐싱 전략:**
```java
// 프롬프트 캐싱 (향후 구현)
private final Map<String, String> promptCache = new ConcurrentHashMap<>();

private String getCachedPrompt(String type) {
    return promptCache.computeIfAbsent(type, k -> {
        String prompt = configManager.getPrompt(k);
        log.info("프롬프트 캐시 저장: {}", k);
        return prompt;
    });
}
```
</div>

### 8. 에러 복구 전략

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔄 장애 복구</h4>

**부분 실패 허용:**
```java
private JsonObject waitForModels(List<CompletableFuture<ModelGenerationResult>> futures) {
    JsonObject tracking = new JsonObject();
    JsonObject failedModels = new JsonObject();
    
    // 부분 성공 허용
    int successCount = 0;
    int failCount = 0;
    
    for (CompletableFuture<ModelGenerationResult> future : futures) {
        try {
            ModelGenerationResult result = future.get(MODEL_TIMEOUT_MINUTES, TimeUnit.MINUTES);
            if (result.getTrackingId().startsWith("error-")) {
                failCount++;
                failedModels.addProperty(result.getObjectName(), result.getTrackingId());
            } else {
                successCount++;
                tracking.addProperty(result.getObjectName(), result.getTrackingId());
            }
        } catch (TimeoutException e) {
            failCount++;
            log.warn("모델 생성 타임아웃");
        }
    }
    
    log.info("모델 생성 완료: 성공 {}, 실패 {}", successCount, failCount);
    
    // 최소 성공 기준
    if (successCount == 0) {
        log.error("모든 모델 생성 실패");
    }
    
    if (!failedModels.asMap().isEmpty()) {
        tracking.add("failed_models", failedModels);
    }
    
    return tracking;
}
```
</div>

---

## 💰 비용 관리

### 9. API 사용량 모니터링

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📈 사용량 추적</h4>

**비용 추정:**

| 서비스 | 요청당 비용 | 월간 예상 (1000 요청) |
|--------|------------|---------------------|
| **Claude Sonnet 4** | $0.03 | $30 |
| **Meshy Preview** | $0.05 | $50 |
| **Meshy Refine** | $0.15 | $150 |
| **총 비용** | $0.23 | $230 |

**사용량 로깅:**
```java
// 사용량 추적 (향후 구현)
@Component
public class ApiUsageTracker {
    private final AtomicInteger claudeRequests = new AtomicInteger();
    private final AtomicInteger meshyRequests = new AtomicInteger();
    
    public void trackClaudeUsage(String type, long tokens) {
        claudeRequests.incrementAndGet();
        log.info("Claude 사용: {} - {} 토큰", type, tokens);
        
        // 일일 한도 확인
        if (claudeRequests.get() > 1000) {
            log.warn("Claude API 일일 한도 접근");
        }
    }
    
    public void trackMeshyUsage(String objectName, boolean success) {
        meshyRequests.incrementAndGet();
        log.info("Meshy 사용: {} - {}", objectName, success ? "성공" : "실패");
    }
    
    @Scheduled(cron = "0 0 0 * * *")  // 매일 자정
    public void resetDailyCounters() {
        log.info("일일 사용량: Claude {}, Meshy {}", 
                 claudeRequests.get(), meshyRequests.get());
        claudeRequests.set(0);
        meshyRequests.set(0);
    }
}
```
</div>

### 10. 할당량 관리

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🚦 Rate Limiting</h4>

**API 한도:**

| API | 제한 | 단위 | 대응 방법 |
|-----|------|------|-----------|
| **Claude** | 1000 | 요청/일 | 요청 분산 |
| **Claude** | 50 | 요청/분 | 큐 시스템 활용 |
| **Meshy** | 1000 | 모델/월 | 다중 키 사용 |
| **Meshy** | 10 | 동시 요청 | 순차 처리 |

**Rate Limit 처리:**
```java
// 429 응답 처리
private JsonObject callMeshyApiWithRetry(JsonObject requestBody, String apiKey) {
    int maxRetries = 3;
    int retryDelay = 1000; // 1초
    
    for (int i = 0; i < maxRetries; i++) {
        try {
            JsonObject response = callMeshyApi(requestBody, apiKey);
            if (response != null) {
                return response;
            }
        } catch (RateLimitException e) {
            log.warn("Rate limit 도달. {}초 후 재시도", retryDelay / 1000);
            try {
                Thread.sleep(retryDelay);
                retryDelay *= 2; // 지수 백오프
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
    
    return null;
}
```
</div>

---

## 📋 AI 연동 체크리스트

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">

### 배포 전 체크리스트

**API 설정:**
- [ ] ANTHROPIC_KEY 환경 변수 설정
- [ ] MESHY_KEY_1 환경 변수 설정
- [ ] API 키 유효성 검증
- [ ] 할당량 및 크레딧 확인

**에러 처리:**
- [ ] API 타임아웃 설정 (30초)
- [ ] 재시도 로직 구현
- [ ] 부분 실패 처리
- [ ] 에러 로깅 상세화

**성능 최적화:**
- [ ] 프롬프트 압축 (800자)
- [ ] 병렬 처리 구현
- [ ] 연결 재사용
- [ ] 응답 캐싱 고려

**모니터링:**
- [ ] API 사용량 추적
- [ ] 응답 시간 로깅
- [ ] 성공률 모니터링
- [ ] 비용 추적

**프로덕션 준비:**
- [ ] Rate limit 대응
- [ ] 장애 복구 전략
- [ ] 백업 API 키
- [ ] 알림 시스템
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>AI 서비스에 대한 자세한 내용은 <a href="../backend/anthropic-service.md">Anthropic 서비스</a>와 <a href="../backend/meshy-service.md">Meshy 서비스</a>를 참조하세요.</p>
</div>