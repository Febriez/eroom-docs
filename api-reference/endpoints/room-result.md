# 결과 조회 API

## GET /room/result

### 개요
룸 생성 요청의 처리 상태를 확인하고, 완료된 경우 전체 결과를 조회하는 API입니다. 폴링 방식으로 사용됩니다.

---

## 요청 상세

### HTTP 메서드
```
GET /room/result?ruid={room_unique_id}
```

### 필수 헤더
```http
Authorization: your_api_key
```

### 쿼리 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| ruid | String | ✅ | 룸 고유 식별자 (POST /room/create 응답에서 받은 값) |

---

## 응답 상세

### 상태별 응답

#### 1. QUEUED - 대기 중 (200 OK)

```json
{
  "ruid": "room_a1b2c3d4e5f6",
  "status": "QUEUED"
}
```

#### 2. PROCESSING - 처리 중 (200 OK)

```json
{
  "ruid": "room_a1b2c3d4e5f6",
  "status": "PROCESSING"
}
```

#### 3. COMPLETED - 완료 (200 OK)

```json
{
  "uuid": "user_12345",
  "ruid": "room_a1b2c3d4e5f6",
  "theme": "우주정거장",
  "difficulty": "normal",
  "keywords": ["미래", "과학", "생존"],
  "room_prefab": "https://example.com/prefab/space_station.fbx",
  "scenario": {
    "scenario_data": {
      "theme": "버려진 우주정거장",
      "difficulty": "normal",
      "description": "2157년, 목성 궤도를 도는 연구 정거장 '호라이즌'...",
      "escape_condition": "메인 에어락을 열고 구조선에 탑승",
      "puzzle_flow": "전력 복구 → 산소 시스템 재가동 → 통신 수리 → 탈출"
    },
    "object_instructions": [
      {
        "name": "GameManager",
        "type": "game_manager",
        "functional_description": "Singleton GameManager with: Dictionary<string,GameObject> registeredObjects, Dictionary<string,bool> puzzleStates, inventory system..."
      },
      {
        "name": "PowerGenerator",
        "type": "interactive_object",
        "visual_description": "낡은 핵융합 발전기...",
        "interaction_method": "e_key",
        "functional_description": "전력 공급 퍼즐...",
        "placement_suggestion": "엔진룸 중앙",
        "puzzle_role": "첫 번째 퍼즐",
        "dependencies": "없음",
        "success_outcome": "main_power_on",
        "failure_feedback": "발전기가 작동하지 않습니다...",
        "hint_messages": ["배전반을 확인해보세요", "..."]
      }
    ]
  },
  "scripts": {
    "GameManager.cs": "dXNpbmcgVW5pdHlFbmdpbmU7CnVzaW5nIFN5c3RlbS5Db2xsZWN0aW9uczoK...",
    "PowerGenerator.cs": "dXNpbmcgVW5pdHlFbmdpbmU7CnVzaW5nIFVuaXR5RW5naW5lLklucHV0U3lz...",
    "OxygenController.cs": "dXNpbmcgVW5pdHlFbmdpbmU7CnB1YmxpYyBjbGFzcyBPeHlnZW5Db250cm9s..."
  },
  "model_tracking": {
    "PowerGenerator": "https://meshy.ai/.../power_generator.fbx",
    "OxygenTank": "res_ghi789jkl012",
    "ControlPanel": "res_mno345pqr678",
    "failed_models": {
      "ComplexMachine": "error-preview-abc123"
    }
  },
  "success": true,
  "timestamp": "1234567890"
}