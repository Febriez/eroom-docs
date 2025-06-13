# 2.3 데이터 모델링

## 📊 데이터 모델 개요

<div style="background: linear-gradient(to right, #f093fb 0%, #f5576c 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">계층적 데이터 구조 설계</h3>
  <p style="margin: 10px 0 0 0;">요청부터 응답까지 일관된 데이터 흐름을 위한 모델링</p>
</div>

---

## 🔄 데이터 플로우 다이어그램

{% mermaid %}
graph LR
subgraph "Request Models"
RCR[RoomCreationRequest]
end

    subgraph "Internal Models"
        QR[QueuedRoomRequest]
        JS[JobState]
        MGR[ModelGenerationResult]
    end
    
    subgraph "Response Models"
        RCR2[RoomCreationResponse]
        SR[StatusResponse]
        ER[ErrorResponse]
    end
    
    RCR --> QR
    QR --> JS
    JS --> RCR2
    JS --> SR
    JS --> ER
    
    style RCR fill:#4a90e2
    style RCR2 fill:#4caf50
    style JS fill:#f39c12

{% endmermaid %}

---

## 📋 핵심 데이터 모델

### 1️⃣ **요청 모델 (Request Models)**

#### RoomCreationRequest

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">룸 생성 요청 데이터</h4>

| 필드          | 타입       | 필수 | 설명                  | 제약사항                           |
|-------------|----------|----|---------------------|--------------------------------|
| uuid        | String   | ✅  | 사용자 고유 식별자          | 비어있지 않음                        |
| theme       | String   | ✅  | 방탈출 테마 (예: "우주정거장") | 비어있지 않음                        |
| keywords    | String[] | ✅  | 키워드 배열 (최소 1개)      | 빈 키워드 없음                       |
| difficulty  | String   | ❌  | 난이도                 | easy/normal/hard (기본값: normal) |
| room_prefab | String   | ✅  | Unity 프리팹 URL       | https:// 로 시작                  |

</div>

```java

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoomCreationRequest {
    private String uuid;
    private String theme;
    private String[] keywords;
    private String difficulty;

    @SerializedName("room_prefab")
    private String roomPrefab;

    @Nullable
    public String getValidatedDifficulty() {
        if (difficulty == null || difficulty.trim().isEmpty()) {
            return "normal"; // 기본값
        }

        String normalized = difficulty.trim().toLowerCase();
        return switch (normalized) {
            case "easy", "normal", "hard" -> normalized;
            default -> "normal"; // 잘못된 값은 기본값으로
        };
    }
}
```

---

### 2️⃣ **내부 처리 모델 (Internal Models)**

#### JobState (작업 상태 관리)

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">비동기 작업 상태 추적</h4>

```java
public record JobState(
        Status status,      // QUEUED, PROCESSING, COMPLETED, FAILED
        JsonObject result   // 최종 결과 또는 에러 정보
) {
}
```

<div style="margin-top: 15px;">
<strong>상태 전이도:</strong>

{% mermaid %}
stateDiagram-v2
[*] --> QUEUED
QUEUED --> PROCESSING
PROCESSING --> COMPLETED
PROCESSING --> FAILED
COMPLETED --> [*]
FAILED --> [*]
{% endmermaid %}
</div>
</div>

#### QueuedRoomRequest

```java
private record QueuedRoomRequest(
        String ruid,                    // 서버 생성 고유 ID
        RoomCreationRequest request     // 원본 요청 데이터
) {
}
```

#### ModelGenerationResult

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">3D 모델 생성 결과</h4>

| 필드         | 타입     | 설명                           |
|------------|--------|------------------------------|
| objectName | String | 오브젝트 이름 (예: "SpaceHelmet")   |
| trackingId | String | Meshy AI 추적 ID, URL 또는 에러 코드 |

```java

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ModelGenerationResult {
    private String objectName;
    private String trackingId;
}
```

</div>

---

### 3️⃣ **응답 모델 (Response Models)**

#### RoomCreationResponse (완전한 응답 - 사용되지 않음)

<div style="background: #fff3cd; padding: 25px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">현재 구현에서 사용되지 않음</h4>

  <p><strong>참고:</strong> 현재 구현에서는 모든 응답이 JsonObject로 직접 생성됩니다. 
  RoomCreationResponse 클래스는 정의되어 있지만 실제로 사용되지 않습니다.</p>
</div>

#### 실제 사용되는 응답 구조 (JsonObject)

**성공 응답:**

```json
{
  "uuid": "user_12345",
  "ruid": "room_a1b2c3d4e5f6",
  "theme": "우주정거장",
  "difficulty": "normal",
  "keywords": [
    "미래",
    "과학",
    "생존"
  ],
  "room_prefab": "https://example.com/prefab/space_station.fbx",
  "scenario": {
    "scenario_data": {
      ...
    },
    "object_instructions": [
      ...
    ]
  },
  "scripts": {
    "GameManager.cs": "base64_encoded_content",
    "PowerGenerator.cs": "base64_encoded_content"
  },
  "model_tracking": {
    "PowerGenerator": "https://meshy.ai/.../model.fbx",
    "OxygenTank": "res_tracking_id_2"
  },
  "success": true,
  "timestamp": "1234567890"
}
```

**에러 응답:**

```json
{
  "ruid": "room_12345",
  "uuid": "user_12345",
  "success": false,
  "error": "상세한 에러 메시지",
  "timestamp": "1234567890"
}
```

---

## 🔗 데이터 관계도

{% mermaid %}
erDiagram
RoomCreationRequest ||--o{ QueuedRoomRequest : "queued as"
QueuedRoomRequest ||--|| JobState : "tracked by"
JobState ||--|| JsonObject : "results in"

    RoomCreationRequest {
        string uuid
        string theme
        array keywords
        string difficulty
        string room_prefab
    }
    
    JobState {
        enum status
        json result
    }
    
    JsonObject {
        string uuid
        string ruid
        json scenario
        json scripts
        json model_tracking
        boolean success
    }

{% endmermaid %}

---

## 📦 JSON 구조 상세

### Scenario 객체 구조

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">시나리오 데이터 구조</h4>

```json
{
  "scenario_data": {
    "theme": "우주정거장",
    "difficulty": "normal",
    "description": "버려진 우주정거장에서의 탈출",
    "escape_condition": "메인 에어락 열기",
    "puzzle_flow": "단계별 퍼즐 진행 설명"
  },
  "object_instructions": [
    {
      "name": "GameManager",
      "type": "game_manager",
      "functional_description": "전체 게임 상태 관리"
    },
    {
      "name": "SpaceHelmet",
      "type": "interactive_object",
      "visual_description": "우주 헬멧, 투명한 바이저",
      "interaction_method": "left_click",
      "functional_description": "산소 공급 시스템 활성화",
      "placement_suggestion": "에어락 근처",
      "puzzle_role": "산소 공급 퍼즐의 핵심",
      "dependencies": "PowerGenerator",
      "success_outcome": "oxygen_enabled",
      "failure_feedback": "전원이 꺼져있습니다.",
      "hint_messages": [
        "헬멧의 전원 버튼을 찾아보세요",
        "먼저 발전기를 작동시켜야 합니다"
      ]
    }
  ]
}
```

</div>

### Scripts 객체 구조

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">스크립트 저장 구조</h4>

  <p>모든 스크립트는 Base64로 인코딩되어 전송됩니다:</p>

```json
{
  "GameManager": "dXNpbmcgVW5pdHlFbmdpbmU7CnVzaW5nIFN5c3RlbS5Db2xsZWN0aW9uczoK...",
  "SpaceHelmet": "dXNpbmcgVW5pdHlFbmdpbmU7CnVzaW5nIFVuaXR5RW5naW5lLklucHV0U3lz...",
  "DoorController": "dXNpbmcgVW5pdHlFbmdpbmU7CnB1YmxpYyBjbGFzcyBEb29yQ29udHJvbGxl..."
}
```

  <div style="margin-top: 15px; padding: 10px; background: #ede7f6; border-radius: 5px;">
    <strong>💡 디코딩 예제:</strong>

```csharp
string decodedScript = Encoding.UTF8.GetString(
    Convert.FromBase64String(base64String)
);
```

  </div>
</div>

### Model Tracking 객체 구조

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">3D 모델 추적 정보</h4>

```json
{
  "PowerGenerator": "https://meshy.ai/.../power_generator.fbx",
  "OxygenTank": "res_ghi789jkl012",
  "ControlPanel": "res_mno345pqr678",
  "failed_models": {
    "ComplexMachine": "error-preview-timeout",
    "BrokenPanel": "error-general-uuid123"
  }
}
```

**추적 ID 타입:**

- URL 형식: 직접 다운로드 가능한 FBX 파일
- res_ 접두사: Meshy API 리소스 ID
- error_ 접두사: 생성 실패한 모델
- timeout_ 접두사: 시간 초과된 모델

</div>

---

## 🛡️ 데이터 검증 규칙

### 입력 검증 (RoomRequestValidator)

| 필드          | 검증 규칙                         |
|-------------|-------------------------------|
| uuid        | 비어있지 않음, 공백 제거                |
| theme       | 비어있지 않음, 최대 100자              |
| keywords    | 최소 1개, 각 키워드 비어있지 않음          |
| difficulty  | easy/normal/hard 중 하나 또는 null |
| room_prefab | https:// 로 시작하는 유효한 URL       |

### 시나리오 검증 (DefaultScenarioValidator)

```java
private void validateStructure(JsonObject scenario) {
    if (!scenario.has("scenario_data") ||
            !scenario.has("object_instructions")) {
        throw new RuntimeException("시나리오 구조가 올바르지 않습니다");
    }
}

private void validateObjectInstructions(JsonObject scenario) {
    JsonArray objects = scenario.getAsJsonArray("object_instructions");
    if (objects.isEmpty()) {
        throw new RuntimeException("오브젝트 설명이 없습니다");
    }

    // GameManager 확인
    JsonObject firstObject = objects.get(0).getAsJsonObject();
    if (!firstObject.get("name").getAsString().equals("GameManager")) {
        throw new RuntimeException("첫 번째 오브젝트가 GameManager가 아닙니다");
    }
}
```

---

## 💾 저장소 매핑

### Firebase Firestore 구조 (클라이언트 측)

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">클라이언트 측 데이터 저장 구조</h4>

```
firestore/
├── users/
│   └── {uuid}/
│       ├── profile
│       └── rooms/
│           └── {ruid}/
│               ├── metadata
│               ├── scenario
│               ├── scripts
│               └── models
└── global/
    └── statistics/
        ├── total_rooms
        └── daily_usage
```

</div>

---

## 📊 데이터 크기 예측

| 데이터 유형      | 평균 크기  | 최대 크기  |
|-------------|--------|--------|
| 요청 데이터      | ~1 KB  | 5 KB   |
| 시나리오        | ~10 KB | 50 KB  |
| 스크립트 (각)    | ~5 KB  | 20 KB  |
| 전체 응답       | ~50 KB | 200 KB |
| 3D 모델 메타데이터 | ~2 KB  | 5 KB   |

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>이 데이터 모델은 <strong>확장성</strong>과 <strong>유지보수성</strong>을 고려하여 설계되었습니다.</p>
</div>