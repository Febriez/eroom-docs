# 3.3 API 설계 명세

## 개요
Eroom 서버는 RESTful API를 통해 VR 방탈출 게임의 방 생성, 상태 조회, 건강성 확인 기능을 제공합니다. 모든 API는 JSON 형식으로 통신하며, 비동기 처리를 통해 높은 성능을 보장합니다.

### Base URL
```
http://localhost:8080
```

### Content-Type
모든 요청과 응답은 `application/json` 형식을 사용합니다.

---

## 1. 서버 상태 확인 (Root)

### Endpoint
```http
GET /
```

### 설명
서버의 기본 상태를 확인하는 엔드포인트입니다. 서버가 정상적으로 작동 중인지 빠르게 확인할 수 있습니다.

### Request
- **Method**: `GET`
- **Parameters**: 없음
- **Body**: 없음

### Response

#### 성공 응답 (200 OK)
```json
{
  "status": "online",
  "message": "Eroom 서버가 작동 중입니다"
}
```

#### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `status` | String | 서버 상태 (`"online"` 고정) |
| `message` | String | 상태 메시지 |

### Example
```bash
curl -X GET http://localhost:8080/
```

---

## 2. 건강성 검사 (Health Check)

### Endpoint
```http
GET /health
```

### 설명
서버의 상세한 건강성 상태와 큐 시스템의 현재 상태를 확인할 수 있는 엔드포인트입니다. 로드밸런싱이나 모니터링 시스템에서 활용할 수 있습니다.

### Request
- **Method**: `GET`
- **Parameters**: 없음
- **Body**: 없음

### Response

#### 성공 응답 (200 OK)
```json
{
  "status": "healthy",
  "queue": {
    "queued": 3,
    "active": 1,
    "completed": 15,
    "maxConcurrent": 1
  }
}
```

#### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `status` | String | 서버 건강성 상태 (`"healthy"` 고정) |
| `queue` | Object | 큐 시스템 상태 정보 |
| `queue.queued` | Integer | 대기 중인 요청 수 |
| `queue.active` | Integer | 현재 처리 중인 요청 수 |
| `queue.completed` | Integer | 완료된 요청 수 (누적) |
| `queue.maxConcurrent` | Integer | 최대 동시 처리 가능한 요청 수 |

### Example
```bash
curl -X GET http://localhost:8080/health
```

---

## 3. 큐 상태 조회

### Endpoint
```http
GET /queue/status
```

### 설명
요청 처리 큐의 현재 상태를 실시간으로 조회할 수 있는 엔드포인트입니다. 시스템 모니터링이나 클라이언트에서 대기 시간을 예측할 때 사용할 수 있습니다.

### Request
- **Method**: `GET`
- **Parameters**: 없음
- **Body**: 없음

### Response

#### 성공 응답 (200 OK)
```json
{
  "queued": 2,
  "active": 1,
  "completed": 8,
  "maxConcurrent": 1
}
```

#### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `queued` | Integer | 대기열에 있는 요청 수 |
| `active` | Integer | 현재 처리 중인 요청 수 |
| `completed` | Integer | 지금까지 완료된 총 요청 수 |
| `maxConcurrent` | Integer | 동시 처리 가능한 최대 요청 수 |

### Example
```bash
curl -X GET http://localhost:8080/queue/status
```

---

## 4. 방 생성 (Room Creation)

### Endpoint
```http
POST /room/create
```

### 설명
VR 방탈출 게임의 방을 생성하는 핵심 엔드포인트입니다. 제공된 테마와 키워드를 바탕으로 AI가 시나리오를 생성하고, Unity C# 스크립트를 작성하며, 3D 모델을 생성합니다. 처리 시간이 오래 걸릴 수 있으므로 큐 시스템을 통해 비동기로 처리됩니다.

### Request

#### Request Body
```json
{
  "uuid": "user-12345-session-67890",
  "theme": "Space Station Escape",
  "keywords": ["oxygen tank", "control panel", "spacesuit", "emergency door"],
  "difficulty": "normal",
  "room_prefab": "https://example.com/space-station-prefab.fbx"
}
```

#### Request Fields
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `uuid` | String | ✅ | 클라이언트 식별자 (세션 ID 등) |
| `theme` | String | ✅ | 방탈출 게임의 주제/테마 |
| `keywords` | String[] | ✅ | 게임에 포함될 오브젝트 키워드 배열 |
| `difficulty` | String | ❌ | 게임 난이도 (`"easy"`, `"normal"`, `"hard"`) |
| `room_prefab` | String | ✅ | Unity 방 프리팹의 HTTPS URL |

#### Validation Rules
- `uuid`: 비어있으면 안됨
- `theme`: 비어있으면 안됨
- `keywords`: 최소 1개 이상, 각 키워드는 비어있으면 안됨
- `difficulty`: 생략 시 `"normal"`로 기본값 설정, 유효값: `"easy"`, `"normal"`, `"hard"`
- `room_prefab`: HTTPS URL 형식이어야 함

### Response

#### 성공 응답 (200 OK)
```json
{
  "uuid": "user-12345-session-67890",
  "puid": "room_a1b2c3d4e5f6",
  "theme": "Space Station Escape",
  "keywords": ["oxygen tank", "control panel", "spacesuit", "emergency door"],
  "difficulty": "normal",
  "room_prefab": "https://example.com/space-station-prefab.fbx",
  "scenario": {
    "scenario_data": {
      "theme": "Space Station Escape",
      "difficulty": "normal",
      "description": "The player must escape from a malfunctioning space station...",
      "escape_condition": "All systems must be restored and the escape pod must be activated",
      "puzzle_flow": "oxygen system check -> power restoration -> communication system activation -> escape pod launch"
    },
    "object_instructions": [
      {
        "name": "GameManager",
        "type": "game_manager",
        "functional_description": "Singleton GameManager with: Dictionary<string,GameObject> registeredObjects, Dictionary<string,bool> puzzleStates, inventory system (Dictionary<string,int> quantities + Dictionary<string,bool> flags), dependency validation, state monitoring, victory condition checking"
      },
      {
        "name": "OxygenTank",
        "type": "interactive_object",
        "visual_description": "metallic oxygen tank with pressure gauges and valves",
        "interaction_method": "left_click",
        "functional_description": "State management for oxygen system restoration",
        "placement_suggestion": "Near the life support control area",
        "puzzle_role": "Primary oxygen system puzzle",
        "dependencies": "",
        "success_outcome": "oxygen_restored=true",
        "failure_feedback": "산소 탱크가 올바르게 작동하지 않는 것 같다...",
        "hint_messages": ["산소 게이지를 확인해보자", "밸브를 조작해야 할 것 같다", "압력 수치가 중요해 보인다"]
      }
    ]
  },
  "scripts": {
    "GameManager.cs": "dXNpbmcgU3lzdGVtLkNvbGxlY3Rpb25zOw0KdXNpbmcgU3lzdGVt...",
    "OxygenTank.cs": "dXNpbmcgVW5pdHlFbmdpbmU7DQp1c2luZyBTeXN0ZW0uQ29sbGVj..."
  },
  "model_tracking": {
    "OxygenTank": "model_abc123def456",
    "ControlPanel": "model_ghi789jkl012"
  },
  "success": true,
  "timestamp": "1703123456789"
}
```

#### Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `uuid` | String | 요청시 제공된 클라이언트 식별자 |
| `puid` | String | 시스템에서 생성한 고유한 방 식별자 |
| `theme` | String | 생성된 방의 테마 |
| `keywords` | String[] | 사용된 키워드 배열 |
| `difficulty` | String | 적용된 난이도 |
| `room_prefab` | String | 방 프리팹 URL |
| `scenario` | Object | AI가 생성한 시나리오 데이터 |
| `scenario.scenario_data` | Object | 시나리오 메타데이터 |
| `scenario.scenario_data.theme` | String | 시나리오 테마 |
| `scenario.scenario_data.difficulty` | String | 시나리오 난이도 |
| `scenario.scenario_data.description` | String | 시나리오 상세 설명 |
| `scenario.scenario_data.escape_condition` | String | 탈출 조건 |
| `scenario.scenario_data.puzzle_flow` | String | 퍼즐 진행 순서 (화살표로 연결된 문자열) |
| `scenario.object_instructions` | Object[] | 오브젝트별 상세 지시사항 |
| `scenario.object_instructions[0]` | Object | **반드시 GameManager** (type: "game_manager") |
| `scenario.object_instructions[].name` | String | 오브젝트 이름 (C# PascalCase) |
| `scenario.object_instructions[].type` | String | `"game_manager"` 또는 `"interactive_object"` |
| `scenario.object_instructions[].visual_description` | String | 3D 모델 생성용 시각적 설명 (interactive_object만) |
| `scenario.object_instructions[].interaction_method` | String | 상호작용 방법 (interactive_object만) |
| `scenario.object_instructions[].functional_description` | String | 기능적 설명 |
| `scenario.object_instructions[].placement_suggestion` | String | 배치 제안 (interactive_object만) |
| `scenario.object_instructions[].puzzle_role` | String | 퍼즐에서의 역할 (interactive_object만) |
| `scenario.object_instructions[].dependencies` | String | 의존성 (쉼표로 구분, interactive_object만) |
| `scenario.object_instructions[].success_outcome` | String | 성공시 결과 (interactive_object만) |
| `scenario.object_instructions[].failure_feedback` | String | 실패 메시지 (한국어, interactive_object만) |
| `scenario.object_instructions[].hint_messages` | String[] | 힌트 메시지 배열 (한국어, interactive_object만) |
| `scripts` | Object | Base64로 인코딩된 Unity C# 스크립트들 |
| `scripts.GameManager.cs` | String | **반드시 첫 번째로 생성되는** GameManager 스크립트 |
| `scripts.*.cs` | String | 각 interactive_object의 스크립트 |
| `model_tracking` | Object | 3D 모델 생성 상태 추적 ID들 |
| `model_tracking.*` | String | 각 오브젝트의 Meshy API 추적 ID |
| `success` | Boolean | 요청 성공 여부 |
| `timestamp` | String | 응답 생성 시간 (Unix timestamp) |

#### 오류 응답 (500 Internal Server Error)
```json
{
  "uuid": "user-12345-session-67890",
  "success": false,
  "error": "통합 시나리오 생성 실패: LLM 응답이 null입니다.",
  "timestamp": "1703123456789"
}
```

#### Error Response Fields
| Field | Type | Description |
|-------|------|-------------|
| `uuid` | String | 요청시 제공된 클라이언트 식별자 |
| `success` | Boolean | 항상 `false` |
| `error` | String | 구체적인 오류 메시지 |
| `timestamp` | String | 오류 발생 시간 (Unix timestamp) |

### Example
```bash
curl -X POST http://localhost:8080/room/create \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "user-12345-session-67890",
    "theme": "Space Station Escape",
    "keywords": ["oxygen tank", "control panel", "spacesuit", "emergency door"],
    "difficulty": "normal",
    "room_prefab": "https://example.com/space-station-prefab.fbx"
  }'
```

---

## AI 시스템 설정

### LLM 모델 설정
```json
{
  "model": {
    "name": "claude-sonnet-4-20250514",
    "maxTokens": 16000,
    "scenarioTemperature": 0.9,
    "scriptTemperature": 0.1
  }
}
```

### 오브젝트 개수 규칙
난이도에 따른 interactive_object 개수 (GameManager 제외):
- **Easy**: 4-5개 오브젝트
- **Normal**: 5-7개 오브젝트
- **Hard**: 7-9개 오브젝트

### 키워드 자동 확장
제공된 키워드가 난이도 요구사항에 부족할 경우, AI가 테마에 적합한 추가 키워드를 자동 생성합니다.

### Unity6 기술 제약사항

#### 허용되는 컴포넌트
- **Collider**: BoxCollider, SphereCollider, CapsuleCollider, MeshCollider
- **Physics**: Rigidbody
- **UI**: Text, Button, InputField
- **Input**: Unity6 InputSystem

#### 금지되는 기능
- **시각 효과**: ParticleSystem, 조명 변경, 색상 변경, 투명도, 글로우
- **오디오**: AudioSource, 음향 효과
- **애니메이션**: Animator, 애니메이션 시스템
- **머티리얼**: Renderer 머티리얼 변경

#### 상호작용 제한
물리적 상호작용만 허용:
- 이동, 회전, 열기/닫기, 아이템 결합
- 시각적 효과나 애니메이션 금지

---

## 스크립트 생성 규칙

### 필수 처리 순서
1. **GameManager 스크립트**: 항상 첫 번째로 생성
2. **Interactive Object 스크립트**: 순차적으로 생성
3. **스크립트 구분자**: `===ScriptName:::`로 각 스크립트 구분

### GameManager 필수 구성요소
```csharp
public class GameManager : MonoBehaviour 
{
    public static GameManager Instance; // 싱글톤
    public bool room_clear = false;
    Dictionary<string,bool> puzzleStates = new();
    Dictionary<string,GameObject> registeredObjects = new();
    Dictionary<string,int> inventoryQuantity = new();
    Dictionary<string,bool> inventoryBool = new();
    
    // 필수 메서드들
    public void ShowPlayerHint(string message) { }
    public void ShowRandomHint(string[] hints) { }
    public void RegisterObject(string name, GameObject obj) { }
    public bool GetPuzzleState(string key) { }
    public void SetPuzzleState(string key, bool value) { }
    public void CheckVictoryCondition() { }
    public bool HasInventoryItem(string item) { }
    public void AddInventoryItem(string item, int amount=1) { }
    public bool ConsumeInventoryItem(string item, int amount=1) { }
    public bool ValidateDependencies(string[] deps) { }
}
```

### Interactive Object 스크립트 요구사항
- `public bool isSelected = false` (선택 시스템용)
- Start()에서 GameManager.RegisterObject() 호출
- Unity6 InputSystem 통합
- 한국어 Debug.Log 메시지
- H-키 힌트 시스템
- left_click으로 선택 토글 + interaction_method로 주요 액션

---

## 오류 처리

### 공통 오류 코드
| HTTP Status | 설명 |
|-------------|------|
| `200` | 성공 |
| `400` | 잘못된 요청 (유효성 검사 실패) |
| `500` | 서버 내부 오류 |

### 오류 응답 형식
모든 오류 응답은 다음 형식을 따릅니다:
```json
{
  "uuid": "요청한 UUID (있는 경우)",
  "success": false,
  "error": "구체적인 오류 메시지",
  "timestamp": "오류 발생 시간"
}
```

### 일반적인 오류 메시지
- `"UUID가 비어있습니다"` - 필수 필드 누락
- `"테마가 비어있습니다"` - 필수 필드 누락
- `"키워드가 비어있습니다"` - 필수 필드 누락
- `"유효하지 않은 roomPrefab URL 형식입니다"` - URL 형식 오류
- `"유효하지 않은 난이도입니다"` - difficulty 값 오류
- `"통합 시나리오 생성 실패"` - AI 시나리오 생성 실패
- `"통합 스크립트 생성 실패"` - AI 스크립트 생성 실패
- `"시스템 오류가 발생했습니다"` - 예상치 못한 서버 오류

---

## 성능 특성

### 처리 시간
- **상태 확인 API** (`/`, `/health`, `/queue/status`): < 100ms
- **방 생성 API** (`/room/create`): 30초 - 10분 (AI 처리 및 3D 모델 생성 포함)

### 동시 처리 제한
- 현재 최대 동시 처리: **1개 요청**
- 초과 요청은 큐에서 대기

### 타임아웃 설정
- **3D 모델 생성**: 10분
- **스크립트 생성**: 설정 없음 (AI 응답 대기)
- **전체 요청**: 설정 없음 (큐에서 순차 처리)

---

## 사용 예시 시나리오

### 1. 기본 방 생성 플로우
```bash
# 1. 서버 상태 확인
curl -X GET http://localhost:8080/health

# 2. 방 생성 요청
curl -X POST http://localhost:8080/room/create \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "session-abc123",
    "theme": "Gothic Mansion Escape",
    "keywords": ["key", "candle", "mirror", "book"],
    "difficulty": "hard",
    "room_prefab": "https://cdn.example.com/gothic-mansion.fbx"
  }'

# 3. 처리 중 큐 상태 확인
curl -X GET http://localhost:8080/queue/status
```

### 2. 최소 필수 정보로 방 생성
```bash
curl -X POST http://localhost:8080/room/create \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "minimal-request",
    "theme": "School Classroom",
    "keywords": ["blackboard", "desk"],
    "room_prefab": "https://cdn.example.com/classroom.fbx"
  }'
```

---

## 보안 고려사항

### 입력 검증
- 모든 문자열 입력은 XSS 방지를 위해 검증됩니다
- URL은 HTTPS 프로토콜만 허용됩니다
- 키워드 배열은 중복 제거 및 정규화됩니다

### 리소스 보호
- 동시 처리 제한으로 서버 리소스를 보호합니다
- 큐 시스템으로 과부하를 방지합니다
- 타임아웃 설정으로 무한 대기를 방지합니다

### API 키 관리
- 외부 서비스 (Anthropic, Meshy) API 키는 환경변수로 관리됩니다
- API 키는 로그에 노출되지 않습니다