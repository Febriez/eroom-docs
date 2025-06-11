# 3.5 Anthropic AI 연동

## 🤖 Anthropic 서비스 개요

<div style="background: linear-gradient(to right, #4facfe 0%, #00f2fe 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">Claude AI 기반 콘텐츠 생성</h3>
  <p style="margin: 10px 0 0 0;">시나리오와 게임 스크립트를 자동으로 생성하는 AI 통합 서비스</p>
</div>

---

## 🏗️ AnthropicService 구조

### 주요 구성 요소

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔧 서비스 아키텍처</h4>
  
  ```java
  public class AnthropicService {
      private final ApiKeyConfig apiKeyConfig;
      private final ConfigUtil configUtil;
      private volatile AnthropicClient client;
      
      // 주요 메서드
      public JsonObject generateScenario(String prompt, JsonObject requestData)
      public Map<String, String> generateUnifiedScripts(String prompt, JsonObject requestData)
  }
  ```
  
  **특징:**
  - ✅ Claude Sonnet 4 모델 사용
  - ✅ 싱글톤 클라이언트 패턴
  - ✅ 자동 Base64 인코딩
  - ✅ 강력한 에러 처리
</div>

---

## 🎯 시나리오 생성

### generateScenario() 메서드

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎭 AI 시나리오 생성 프로세스</h4>
  
  **입력 파라미터:**
  - `scenarioPrompt`: config.json의 시나리오 프롬프트
  - `requestData`: 사용자 요청 데이터 (테마, 키워드, 난이도 등)
  
  **처리 과정:**
  ```mermaid
  flowchart LR
      A[요청 데이터] --> B[MessageCreateParams 생성]
      B --> C[Claude API 호출]
      C --> D[응답 텍스트 추출]
      D --> E[JSON 파싱]
      E --> F[검증 및 반환]
  ```
  
  **모델 설정:**
  ```json
  {
    "model": "claude-sonnet-4-20250514",
    "maxTokens": 16000,
    "temperature": 0.9,  // 창의적 생성
    "system": "시나리오 생성 프롬프트"
  }
  ```
</div>

### 시나리오 응답 구조

```json
{
  "scenario_data": {
    "theme": "버려진 우주정거장",
    "difficulty": "normal",
    "description": "2157년, 목성 궤도의 연구 정거장...",
    "escape_condition": "메인 에어락을 열고 구조선 도킹",
    "puzzle_flow": "1. 전력 복구 → 2. 산소 확보 → 3. 통신 수리"
  },
  "object_instructions": [
    {
      "name": "GameManager",
      "type": "game_manager",
      "functional_description": "게임 상태 관리 싱글톤"
    },
    {
      "name": "PowerGenerator",
      "type": "interactive_object",
      "visual_description": "낡은 핵융합 발전기, 붉은 경고등",
      "interaction_method": "e_key",
      "puzzle_role": "전력 공급 퍼즐의 핵심"
    }
  ]
}
```

---

## 💻 스크립트 생성

### generateUnifiedScripts() 메서드

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 Unity C# 스크립트 자동 생성</h4>
  
  **특징:**
  - 모든 오브젝트의 스크립트를 한 번에 생성
  - Unity6 최신 API 활용
  - Base64 자동 인코딩
  
  **모델 설정:**
  ```json
  {
    "temperature": 0.1,  // 정확한 코드 생성
    "maxTokens": 16000,
    "system": "Unity6 스크립트 생성 프롬프트"
  }
  ```
  
  **생성 과정:**
  1. 시나리오 데이터 기반 스크립트 생성 요청
  2. Claude가 구분자로 분리된 스크립트들 생성
  3. 파싱 및 Base64 인코딩
  4. Map<String, String> 형태로 반환
</div>

---

## 🔄 응답 파싱

### 스크립트 구분자 파싱

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">✂️ 구분자 기반 파싱 로직</h4>
  
  **AI 응답 형식:**
  ```
  // GameManager.cs (구분자 없이 시작)
  using UnityEngine;
  public class GameManager : MonoBehaviour {
      // 코드 내용
  }
  
  ===PowerGenerator.cs:::
  using UnityEngine;
  public class PowerGenerator : MonoBehaviour {
      // 코드 내용
  }
  
  ===DoorController.cs:::
  using UnityEngine;
  public class DoorController : MonoBehaviour {
      // 코드 내용
  }
  ```
  
  **파싱 규칙:**
  - 첫 번째 스크립트 (GameManager)는 구분자 없음
  - 이후 스크립트는 `===ScriptName:::` 형식
  - 정규식 패턴: `(?:^|===)\\s*([^:]+):::([\\s\\S]*?)(?====|$)`
</div>

---

## 🛡️ 에러 처리

### 치명적 오류 처리 전략

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚠️ 시스템 종료 시나리오</h4>
  
  ```java
  // API 키 누락
  if (apiKey == null || apiKey.trim().isEmpty()) {
      log.error("Anthropic API 키가 설정되지 않았습니다. 서버를 종료합니다.");
      System.exit(1);
  }
  
  // 응답 없음
  if (textContent == null || textContent.isEmpty()) {
      log.error("시나리오 생성 응답이 비어있습니다. 서버를 종료합니다.");
      System.exit(1);
  }
  
  // JSON 파싱 실패
  catch (JsonSyntaxException e) {
      log.error("시나리오 JSON 파싱 실패: {}", e.getMessage());
      System.exit(1);
  }
  ```
  
  **이유:** AI 서비스는 핵심 기능이므로 실패 시 서버 운영 불가
</div>

---

## 📊 성능 최적화

### 클라이언트 재사용

```java
private synchronized AnthropicClient getClient() {
    if (client == null) {
        client = AnthropicOkHttpClient.builder()
            .apiKey(apiKey)
            .build();
    }
    return client;
}
```

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
      <li>예측 가능한 구조</li>
    </ul>
  </div>
</div>

---

## 🔍 Base64 인코딩

### 인코딩 프로세스

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔐 스크립트 인코딩</h4>
  
  ```java
  private Optional<String> encodeToBase64(String content) {
      if (content == null || content.isEmpty()) {
          return Optional.empty();
      }
      
      String encoded = Base64.getEncoder()
          .encodeToString(content.getBytes(StandardCharsets.UTF_8));
      return Optional.of(encoded);
  }
  ```
  
  **장점:**
  - JSON 안전한 전송
  - 특수 문자 처리 불필요
  - 크기 증가는 약 33%
  - 표준 디코딩 지원
</div>

---

## 📈 API 사용 통계

### 예상 사용량

| 항목 | 시나리오 생성 | 스크립트 생성 | 총계 |
|------|---------------|---------------|------|
| **토큰 입력** | ~2,000 | ~3,000 | ~5,000 |
| **토큰 출력** | ~1,500 | ~8,000 | ~9,500 |
| **처리 시간** | 1-3분 | 30초 | 1.5-3.5분 |
| **비용/요청** | $0.01 | $0.05 | $0.06 |

---

## 🚀 최적화 가능성

<div style="background: #f0f0f0; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔮 향후 개선 방향</h4>
  
  1. **프롬프트 캐싱**
     - 자주 사용되는 테마 캐싱
     - 프롬프트 최적화
  
  2. **스트리밍 응답**
     - 실시간 생성 진행률
     - 부분 결과 미리보기
  
  3. **다중 모델 지원**
     - Claude Opus 4 (고품질)
     - Claude Haiku (빠른 응답)
  
  4. **백업 전략**
     - 다른 LLM 폴백
     - 로컬 템플릿 시스템
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>Anthropic 서비스는 <strong>창의성</strong>과 <strong>정확성</strong>의 완벽한 조화를 제공합니다.</p>
</div>