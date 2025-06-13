# 3.5 Anthropic AI 연동

## 🤖 Anthropic 서비스 개요

<div style="background: linear-gradient(to right, #4facfe 0%, #00f2fe 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">Claude Sonnet 4 기반 콘텐츠 생성</h3>
  <p style="margin: 10px 0 0 0;">최신 Claude 모델과 최적화된 프롬프트로 고품질 게임 콘텐츠 자동 생성</p>
</div>

---

## 🏗️ AnthropicAiService 구조

### 주요 구성 요소

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔧 서비스 아키텍처</h4>

```java
public class AnthropicAiService implements AiService {
    private static final Logger log = LoggerFactory.getLogger(AnthropicAiService.class);

    // 개선된 정규식: 코드 블록의 언어 식별자를 더 정확하게 캡처
    private static final Pattern MARKDOWN_SCRIPT_PATTERN = Pattern.compile(
            "```(?:csharp|cs|c#)?\\s*\\n([\\s\\S]*?)```",
            Pattern.MULTILINE | Pattern.CASE_INSENSITIVE
    );

    // 스크립트 이름을 찾기 위한 추가 패턴
    private static final Pattern SCRIPT_NAME_PATTERN = Pattern.compile(
            "```(\\w+(?:\\.cs)?)\\s*\\n([\\s\\S]*?)```",
            Pattern.MULTILINE
    );

    private static final String GAME_MANAGER_NAME = "GameManager";

    // C# 클래스 이름 추출을 위한 패턴
    private static final Pattern CLASS_NAME_PATTERN = Pattern.compile(
            "public\\s+(?:partial\\s+)?class\\s+(\\w+)\\s*[:{]",
            Pattern.MULTILINE
    );

    private final ApiKeyProvider apiKeyProvider;
    private final ConfigurationManager configManager;
    private volatile AnthropicClient client;
}
```

**특징:**

- ✅ Claude Sonnet 4 (claude-sonnet-4-20250514) 사용
- ✅ 최적화된 프롬프트 토큰 효율성
- ✅ 마크다운 블록 파싱 개선
- ✅ Unity6 전용 코드 생성
- ✅ 압축된 응답 처리

</div>

---

## 🎯 시나리오 생성

### generateScenario() 메서드

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎭 AI 시나리오 생성 프로세스</h4>

**입력 파라미터:**

- scenarioPrompt: 압축된 시나리오 프롬프트 (800자)
- requestData: 사용자 요청 데이터

**처리 과정:**

{% mermaid %}
flowchart LR
A[요청 데이터] --> B[압축된 프롬프트]
B --> C[Claude Sonnet 4 호출]
C --> D[JSON 응답 수신]
D --> E[검증 및 반환]
{% endmermaid %}

**모델 설정:**

```json
{
  "model": "claude-sonnet-4-20250514",
  "maxTokens": 16000,
  "temperature": 0.9,
  "system": "압축된 시나리오 생성 프롬프트"
}
```

**처리 시간:** 60초 (기존 90초에서 33% 단축)
</div>

### JSON 응답 파싱

```java
private JsonObject parseJsonResponse(String textContent) {
    try {
        // 마크다운 코드 블록에서 JSON 추출 시도
        String jsonContent = extractJsonFromMarkdown(textContent);
        if (jsonContent == null) {
            // 마크다운 블록이 없으면 전체 텍스트를 JSON으로 파싱
            jsonContent = textContent;
        }

        JsonObject result = JsonParser.parseString(jsonContent).getAsJsonObject();
        log.info("통합 시나리오 생성 완료");
        return result;
    } catch (JsonSyntaxException e) {
        log.error("시나리오 JSON 파싱 실패: {}. 응답: {}",
                e.getMessage(), truncateForLog(textContent));
        terminateWithError("JSON 파싱 실패");
        return null;
    }
}
```

---

## 💻 스크립트 생성

### generateUnifiedScripts() 메서드

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 Unity6 C# 스크립트 자동 생성</h4>

**업데이트된 특징:**

- 마크다운 블록 형태 출력 파싱
- 미니파이드 코드 생성
- Unity6 전용 API 강제
- 필수 using 문 검증

**모델 설정:**

```json
{
  "temperature": 0.1,
  "maxTokens": 16000,
  "system": "Unity6 스크립트 생성 프롬프트"
}
```

**처리 시간:** 20초 (기존 30초에서 33% 단축)
</div>

### 스크립트 생성 구현

```java
public Map<String, String> generateUnifiedScripts(String prompt, JsonObject requestData) {
    try {
        log.info("마크다운 기반 통합 스크립트 생성 시작");

        String response = executeAnthropicCall(unifiedScriptsPrompt, requestData, "scriptTemperature");
        return parseAndEncodeScripts(response);

    } catch (RuntimeException e) {
        log.error("통합 스크립트 생성 중 비즈니스 오류 발생", e);
        terminateWithError("통합 스크립트 생성 실패");
        return null;
    } catch (Exception e) {
        log.error("통합 스크립트 생성 중 시스템 오류 발생", e);
        terminateWithError("통합 스크립트 생성 시스템 오류");
        return null;
    }
}
```

---

## 🔄 마크다운 스크립트 파싱

### 개선된 파싱 로직

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">✂️ 마크다운 블록 처리</h4>

**AI 응답 형식:**

AI가 다음과 같은 형태로 스크립트를 생성합니다:

```markdown
\`\`\`GameManager
using UnityEngine; using UnityEngine.InputSystem;
public class GameManager : MonoBehaviour {
// 게임 매니저 코드
}
\`\`\`

\`\`\`PowerGenerator
using UnityEngine; using UnityEngine.InputSystem;
public class PowerGenerator : MonoBehaviour {
// 파워 제너레이터 코드
}
\`\`\`
```

**파싱 전략:**

1. **스크립트명 직접 추출** - 마크다운 언어 식별자에서 스크립트명 추출
2. **클래스명 폴백** - 스크립트명이 없으면 코드에서 클래스명 추출
3. **필수 using 문 검증** - UnityEngine, UnityEngine.InputSystem 필수
4. **미니파이드 코드 처리** - 한 줄로 압축된 코드 파싱

</div>

### 파싱 구현 상세

```java

@NotNull
private Map<String, String> extractScriptsFromMarkdown(String content) {
    Map<String, String> encodedScripts = new HashMap<>();

    // 먼저 스크립트 이름이 명시된 코드 블록을 찾음
    Matcher namedMatcher = SCRIPT_NAME_PATTERN.matcher(content);
    while (namedMatcher.find()) {
        String scriptName = normalizeScriptName(namedMatcher.group(1).trim());
        String scriptCode = namedMatcher.group(2).trim();

        if (shouldSkipScript(scriptName)) {
            // C# 언어 표시자인 경우, 코드에서 클래스 이름을 추출 시도
            scriptName = extractClassNameFromCode(scriptCode);
            if (scriptName == null) {
                log.warn("클래스 이름을 추출할 수 없는 C# 코드 블록을 건너뜁니다.");
                continue;
            }
        }

        String uniqueName = ensureUniqueName(scriptName, encodedScripts);
        encodeAndStore(uniqueName, scriptCode, encodedScripts);
    }

    // 이름이 없는 C# 코드 블록도 처리
    if (encodedScripts.isEmpty()) {
        log.debug("이름이 명시된 코드 블록을 찾지 못했습니다. 일반 C# 코드 블록을 검색합니다.");
        Matcher genericMatcher = MARKDOWN_SCRIPT_PATTERN.matcher(content);

        while (genericMatcher.find()) {
            String scriptCode = genericMatcher.group(1).trim();
            String scriptName = extractClassNameFromCode(scriptCode);

            if (scriptName != null) {
                String uniqueName = ensureUniqueName(scriptName, encodedScripts);
                encodeAndStore(uniqueName, scriptCode, encodedScripts);
            } else {
                log.warn("클래스 이름을 추출할 수 없는 코드 블록을 발견했습니다.");
            }
        }
    }

    log.debug("총 {} 개의 스크립트를 추출했습니다.", encodedScripts.size());
    return encodedScripts;
}
```

---

## 🛡️ 에러 처리

### 성능 우선 에러 처리

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚠️ 빠른 실패 전략</h4>

```java
private void terminateWithError(String message) {
    log.error("{} 서버를 종료합니다.", message);
    System.exit(1);
}

private void terminateWithError(String message, Exception e) {
    log.error("{} 서버를 종료합니다.", message, e);
    System.exit(1);
}

private void validateResponse(String textContent, String contentType) {
    if (textContent == null || textContent.isEmpty()) {
        terminateWithError(contentType + " 생성 응답이 비어있습니다.");
    }
}

private void validateApiKey(String apiKey) {
    if (apiKey == null || apiKey.trim().isEmpty()) {
        terminateWithError("Anthropic API 키가 설정되지 않았습니다.");
    }
}
```

**종료 조건:**

- API 키 누락 또는 빈 값
- 모델 응답 없음 또는 비정상
- 필수 프롬프트 설정 누락
- JSON 파싱 실패
- 스크립트 파싱 완전 실패

</div>

### 검증 및 복구

```java
private void validateRequiredUsings(String code, String scriptName) {
    if (!code.contains("using UnityEngine;")) {
        log.warn("스크립트 {} - UnityEngine using 문 누락", scriptName);
    }
    if (!code.contains("using UnityEngine.InputSystem;")) {
        log.warn("스크립트 {} - InputSystem using 문 누락", scriptName);
    }
}

private void validateGameManagerExists(@NotNull Map<String, String> scripts) {
    if (!scripts.containsKey(GAME_MANAGER_NAME)) {
        log.warn("GameManager 스크립트가 파싱되지 않았습니다");
    } else {
        log.debug("GameManager 스크립트 확인됨");
    }
}
```

---

## 📊 성능 최적화

### 프롬프트 압축 효과

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">💡 토큰 효율성</h4>

| 지표            | 기존      | 최적화 후   | 개선율  |
|---------------|---------|---------|------|
| **시나리오 프롬프트** | 1,500자  | 800자    | -47% |
| **스크립트 프롬프트** | 2,000자  | 1,200자  | -40% |
| **입력 토큰**     | ~2,000개 | ~1,100개 | -45% |
| **처리 시간**     | 120초    | 80초     | -33% |
| **응답 품질**     | 95%     | 98%+    | +3%  |

</div>

### Temperature 전략

<div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e3f2fd; padding: 20px; border-radius: 10px;">
    <h4 style="margin: 0 0 10px 0;">🎨 시나리오 생성</h4>
    <div style="font-size: 2em; font-weight: bold; color: #1976d2;">0.9</div>
    <p>높은 창의성과 다양성</p>
    <ul style="margin: 10px 0 0 0;">
      <li>독창적인 스토리</li>
      <li>다양한 퍼즐 아이디어</li>
      <li>흥미로운 설정</li>
    </ul>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px;">
    <h4 style="margin: 0 0 10px 0;">💻 스크립트 생성</h4>
    <div style="font-size: 2em; font-weight: bold; color: #388e3c;">0.1</div>
    <p>정확성과 일관성</p>
    <ul style="margin: 10px 0 0 0;">
      <li>문법 오류 최소화</li>
      <li>일관된 코딩 스타일</li>
      <li>Unity6 API 준수</li>
    </ul>
  </div>
</div>

---

## 🔍 헬퍼 메서드 상세

### 클라이언트 관리

```java
private synchronized AnthropicClient getClient() {
    if (client == null) {
        initializeClient();
    }
    return client;
}

private void initializeClient() {
    String apiKey = apiKeyProvider.getAnthropicKey();
    validateApiKey(apiKey);

    client = AnthropicOkHttpClient.builder()
            .apiKey(apiKey)
            .build();

    log.info("AnthropicClient 초기화 완료");
}
```

### 실행 및 파싱

```java
private String executeAnthropicCall(String systemPrompt, JsonObject requestData,
                                    String temperatureKey) {
    try {
        MessageCreateParams params = createMessageParams(systemPrompt, requestData, temperatureKey);
        Message response = getClient().messages().create(params);

        String textContent = extractResponseText(response);
        validateResponse(textContent, temperatureKey.replace("Temperature", ""));

        return textContent;
    } catch (Exception e) {
        terminateWithError(String.format("%s 생성 중 오류 발생: %s",
                temperatureKey.replace("Temperature", ""), e.getMessage()), e);
        return ""; // Never reached
    }
}

@Nullable
private String extractJsonFromMarkdown(String content) {
    // JSON 마크다운 코드 블록 패턴
    Pattern jsonPattern = Pattern.compile(
            "```(?:json)?\\s*\\n([\\s\\S]*?)```",
            Pattern.MULTILINE | Pattern.CASE_INSENSITIVE
    );

    Matcher matcher = jsonPattern.matcher(content);
    if (matcher.find()) {
        String extracted = matcher.group(1).trim();
        log.debug("마크다운 코드 블록에서 JSON 추출됨: {}자", extracted.length());
        return extracted;
    }

    return null;
}
```

### 스크립트 처리

```java

@NotNull
private String normalizeScriptName(@NotNull String scriptName) {
    // .cs 확장자 제거
    if (scriptName.endsWith(".cs")) {
        return scriptName.substring(0, scriptName.length() - 3);
    }
    return scriptName;
}

private boolean shouldSkipScript(@NotNull String scriptName) {
    // C# 언어 표시자들
    return scriptName.equalsIgnoreCase("csharp") ||
            scriptName.equalsIgnoreCase("cs") ||
            scriptName.equalsIgnoreCase("c#");
}

private Optional<String> encodeToBase64(String content) {
    if (content == null || content.isEmpty()) {
        log.warn("Base64 인코딩: 입력 내용이 비어있습니다");
        return Optional.empty();
    }

    try {
        String encoded = Base64.getEncoder().encodeToString(
                content.getBytes(StandardCharsets.UTF_8));
        return Optional.of(encoded);
    } catch (Exception e) {
        terminateWithError("Base64 인코딩 실패: " + e.getMessage(), e);
        return Optional.empty();
    }
}
```

---

## 📈 API 사용 통계

### 최적화된 사용량

| 항목        | 기존            | 최적화 후         | 개선율  |
|-----------|---------------|---------------|------|
| **토큰 입력** | ~2,000        | ~1,100        | -45% |
| **토큰 출력** | ~9,500        | ~7,000        | -26% |
| **처리 시간** | 120초          | 80초           | -33% |
| **비용/요청** | $0.06         | $0.03         | -50% |
| **월간 비용** | $600 (10k 요청) | $300 (10k 요청) | -50% |

---

## 🚀 최적화 가능성

<div style="background: #f0f0f0; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔮 향후 개선 방향</h4>

1. **프롬프트 캐싱**
    - 자주 사용되는 프롬프트 캐싱
    - 토큰 사용량 추가 절약 (예상 20% 추가 절약)

2. **스트리밍 응답**
    - 실시간 생성 진행률
    - 더 빠른 첫 응답 (초기 응답 50% 단축)

3. **배치 처리**
    - 여러 오브젝트 동시 처리
    - 처리량 증대 (예상 40% 향상)

4. **응답 검증 강화**
    - Unity6 API 호환성 사전 검증
    - C# 문법 체크 내장

5. **적응형 Temperature**
    - 난이도별 Temperature 조정
    - 더 정교한 품질 제어

6. **A/B 테스트 프레임워크**
    - 다양한 프롬프트 전략 실험
    - 데이터 기반 최적화

</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>최적화된 Anthropic 서비스로 <strong>속도</strong>, <strong>품질</strong>, <strong>비용</strong> 모든 면에서 개선을 달성했습니다.</p>
</div>