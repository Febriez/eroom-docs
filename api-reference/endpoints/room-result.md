# 결과 조회 API

## GET /room/result

### 개요
룸 생성 요청의 처리 상태를 확인하고, 완료된 경우 전체 결과를 조회하는 API입니다. 폴링 방식으로 사용됩니다.

---

## 요청 상세

### HTTP 메서드
    GET /room/result?ruid={room_unique_id}

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
    "PowerGenerator": "res_abc123def456",
    "OxygenTank": "res_ghi789jkl012",
    "ControlPanel": "res_mno345pqr678"
  },
  "success": true,
  "timestamp": "1234567890"
}
```

#### 4. FAILED - 실패 (200 OK)

```json
{
  "ruid": "room_a1b2c3d4e5f6",
  "uuid": "user_12345",
  "success": false,
  "error": "시나리오 생성 중 오류가 발생했습니다",
  "timestamp": "1234567890"
}
```

### 에러 응답

#### 400 Bad Request - 파라미터 오류

```json
{
  "success": false,
  "error": "Query parameter 'ruid' is required."
}
```

#### 404 Not Found - 결과 없음

```json
{
  "success": false,
  "error": "Job with ruid 'room_xxx' not found. It may have been already claimed or never existed."
}
```

---

## 응답 필드 상세 설명

### scenario 객체

| 필드 | 설명 |
|------|------|
| scenario_data | 전체 시나리오 정보 |
| scenario_data.theme | AI가 해석한 테마 |
| scenario_data.description | 배경 스토리 |
| scenario_data.escape_condition | 탈출 조건 |
| scenario_data.puzzle_flow | 퍼즐 진행 순서 |
| object_instructions | 각 오브젝트별 상세 정보 배열 |

### scripts 객체

| 필드 | 설명 |
|------|------|
| 키 | 스크립트 파일명 (예: "GameManager.cs") |
| 값 | Base64로 인코딩된 C# 스크립트 내용 |

### model_tracking 객체

| 필드 | 설명 |
|------|------|
| 키 | 오브젝트 이름 |
| 값 | Meshy AI에서 생성된 3D 모델 추적 ID |

---

## 사용 예시

### cURL을 이용한 폴링

```bash
#!/bin/bash
RUID="room_a1b2c3d4e5f6"
API_KEY="your_api_key"

while true; do
  RESPONSE=$(curl -s "http://localhost:8080/room/result?ruid=$RUID" \
    -H "Authorization: $API_KEY")
  
  STATUS=$(echo $RESPONSE | jq -r '.status // "COMPLETED"')
  
  echo "Status: $STATUS"
  
  if [ "$STATUS" != "QUEUED" ] && [ "$STATUS" != "PROCESSING" ]; then
    echo "Result:"
    echo $RESPONSE | jq '.'
    break
  fi
  
  sleep 3
done
```

### Unity C#에서 폴링

```csharp
IEnumerator PollForResult(string ruid)
{
    float pollInterval = 2f;  // 시작 간격
    const float maxInterval = 10f;
    const float intervalMultiplier = 1.5f;
    
    while (true)
    {
        using (UnityWebRequest www = UnityWebRequest.Get(
            $"http://localhost:8080/room/result?ruid={ruid}"))
        {
            www.SetRequestHeader("Authorization", apiKey);
            
            yield return www.SendWebRequest();
            
            if (www.result == UnityWebRequest.Result.Success)
            {
                var response = JsonUtility.FromJson<RoomResultResponse>(
                    www.downloadHandler.text);
                
                if (response.status == "COMPLETED")
                {
                    ProcessCompletedRoom(response);
                    yield break;
                }
                else if (response.status == "FAILED")
                {
                    Debug.LogError($"Room creation failed: {response.error}");
                    yield break;
                }
                else
                {
                    Debug.Log($"Status: {response.status}, waiting...");
                }
            }
            else
            {
                Debug.LogError($"Poll failed: {www.error}");
            }
        }
        
        yield return new WaitForSeconds(pollInterval);
        
        // 폴링 간격 증가
        pollInterval = Mathf.Min(pollInterval * intervalMultiplier, maxInterval);
    }
}

void ProcessCompletedRoom(RoomResultResponse response)
{
    // 시나리오 처리
    Debug.Log($"Room theme: {response.scenario.scenario_data.theme}");
    
    // 스크립트 디코딩 및 저장
    foreach (var script in response.scripts)
    {
        string scriptName = script.Key;
        string scriptContent = DecodeBase64(script.Value);
        SaveScript(scriptName, scriptContent);
    }
    
    // 3D 모델 정보 처리
    foreach (var model in response.model_tracking)
    {
        Debug.Log($"Model {model.Key}: {model.Value}");
    }
}

string DecodeBase64(string base64String)
{
    byte[] bytes = System.Convert.FromBase64String(base64String);
    return System.Text.Encoding.UTF8.GetString(bytes);
}
```

### JavaScript에서 폴링

```javascript
async function pollForResult(ruid) {
  let pollInterval = 2000; // 2초
  const maxInterval = 10000; // 10초
  const multiplier = 1.5;
  
  while (true) {
    try {
      const response = await fetch(`http://localhost:8080/room/result?ruid=${ruid}`, {
        headers: {
          'Authorization': 'your_api_key'
        }
      });
      
      const data = await response.json();
      
      if (data.status === 'COMPLETED') {
        console.log('Room creation completed!');
        processRoom(data);
        break;
      } else if (data.status === 'FAILED') {
        console.error('Room creation failed:', data.error);
        break;
      } else {
        console.log(`Status: ${data.status}, polling again...`);
      }
      
    } catch (error) {
      console.error('Polling error:', error);
    }
    
    await new Promise(resolve => setTimeout(resolve, pollInterval));
    pollInterval = Math.min(pollInterval * multiplier, maxInterval);
  }
}

function processRoom(roomData) {
  // 시나리오 처리
  console.log('Scenario:', roomData.scenario);
  
  // 스크립트 디코딩
  for (const [scriptName, base64Content] of Object.entries(roomData.scripts)) {
    const scriptContent = atob(base64Content);
    console.log(`Script ${scriptName}:`, scriptContent.substring(0, 100) + '...');
  }
  
  // 3D 모델 추적
  console.log('3D Models:', roomData.model_tracking);
}
```

---

## 중요 사항

### 1. 결과 자동 삭제
- **주의**: 결과를 한 번 조회하면 서버에서 자동으로 삭제됩니다
- 필요한 경우 클라이언트에서 결과를 저장해두세요

### 2. 폴링 최적화
    초기 간격: 2초
    증가율: 1.5배
    최대 간격: 10초
    권장 타임아웃: 15분

### 3. 상태 전이

{% mermaid %}
stateDiagram-v2
[*] --> QUEUED: 요청 등록
QUEUED --> PROCESSING: 처리 시작
PROCESSING --> COMPLETED: 성공
PROCESSING --> FAILED: 실패
COMPLETED --> [*]: 결과 조회
FAILED --> [*]: 에러 확인
{% endmermaid %}

---

## 데이터 활용 가이드

### 1. 스크립트 통합

```csharp
// Base64 디코딩 후 Unity 프로젝트에 저장
string decodedScript = Encoding.UTF8.GetString(
    Convert.FromBase64String(base64Script)
);

#if UNITY_EDITOR
string path = $"Assets/Scripts/Generated/{scriptName}";
File.WriteAllText(path, decodedScript);
AssetDatabase.Refresh();
#endif
```

### 2. 3D 모델 다운로드

```csharp
// model_tracking ID를 사용하여 Meshy API에서 모델 다운로드
// (Meshy API 문서 참조)
```

### 3. 시나리오 적용

```csharp
// scenario_data를 게임 설정에 적용
GameManager.Instance.SetupScenario(response.scenario.scenario_data);
```

---

## 문제 해결

| 문제            | 원인        | 해결 방법         |
|---------------|-----------|---------------|
| 404 Not Found | ruid가 잘못됨 | ruid 값 확인     |
| 결과가 비어있음      | 이미 조회됨    | 새로운 요청 생성     |
| 계속 PROCESSING | 처리 지연     | 더 기다리거나 로그 확인 |
| FAILED 상태     | 처리 중 오류   | error 메시지 확인  |

---

## 관련 엔드포인트

- [POST /room/create](room-create.md) - 룸 생성 요청
- [GET /queue/status](queue-status.md) - 큐 상태 확인

---

[← API 명세서로 돌아가기](../rest-api-spec.md)