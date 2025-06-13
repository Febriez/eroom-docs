# 룸 생성 API

## POST /room/create

### 개요
AI 기반 방탈출 게임 룸을 생성하는 비동기 API입니다. 요청을 받으면 즉시 추적 ID를 반환하고, 백그라운드에서 AI 시나리오 생성, 스크립트 생성, 3D 모델 생성을 처리합니다.

---

## 요청 상세

### HTTP 메서드
```
POST /room/create
```

### 필수 헤더
```http
Authorization: your_api_key
Content-Type: application/json; charset=utf-8
```

### 요청 본문

```json
{
  "uuid": "user_12345",
  "theme": "우주정거장",
  "keywords": ["미래", "과학", "생존"],
  "difficulty": "normal",
  "room_prefab": "https://example.com/prefab/space_station.fbx"
}
```

### 요청 필드 설명

| 필드 | 타입 | 필수 | 설명 | 제약사항 |
|------|------|------|------|----------|
| uuid | String | ✅ | 사용자 고유 식별자 | 비어있지 않음 |
| theme | String | ✅ | 방탈출 테마 | 비어있지 않음 |
| keywords | String[] | ✅ | 테마 관련 키워드 배열 | 최소 1개, 빈 키워드 없음 |
| difficulty | String | ❌ | 난이도 | easy/normal/hard (기본값: normal) |
| room_prefab | String | ✅ | Unity 프리팹 URL | https:// 로 시작 |

---

## 응답 상세

### 성공 응답 (202 Accepted)

```json
{
  "ruid": "room_a1b2c3d4e5f6",
  "status": "대기중",
  "message": "방 생성 요청이 수락되었습니다. 상태 확인을 위해 /room/result?ruid=room_a1b2c3d4e5f6를 폴링하세요.",
  "success": true
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| ruid | String | 룸 고유 식별자 (결과 조회용) |
| status | String | 현재 상태 ("대기중") |
| message | String | 안내 메시지 |
| success | Boolean | 성공 여부 |

### 에러 응답

#### 400 Bad Request - 잘못된 요청

```json
{
  "success": false,
  "error": "유효하지 않은 요청 본문 또는 'uuid' (userId)가 누락되었습니다.",
  "timestamp": "1234567890"
}
```

#### 401 Unauthorized - 인증 실패

```json
{
  "error": "인증이 필요합니다"
}
```

---

## 입력 검증 규칙

### 검증 메시지

| 검증 항목 | 에러 메시지 | 해결 방법 |
|-----------|-------------|-----------|
| UUID 누락 | "UUID가 비어있습니다" | uuid 필드 제공 |
| 테마 누락 | "테마가 비어있습니다" | theme 필드 제공 |
| 키워드 없음 | "키워드가 비어있습니다" | 최소 1개 키워드 추가 |
| 빈 키워드 | "빈 키워드가 포함되어 있습니다" | 모든 키워드에 값 입력 |
| URL 누락 | "roomPrefab URL이 비어있습니다" | room_prefab 필드 제공 |
| 잘못된 URL | "유효하지 않은 roomPrefab URL 형식입니다" | https:// 로 시작하는 URL |
| 잘못된 난이도 | "유효하지 않은 난이도입니다. easy, normal, hard 중 하나를 선택하세요." | 올바른 난이도 값 사용 |

---

## 처리 흐름

### 백그라운드 처리 단계

{% mermaid %}
graph TD
A[요청 수신] --> B[입력 검증]
B --> C[큐에 등록]
C --> D[ruid 반환]

    D --> E[백그라운드 처리 시작]
    E --> F[시나리오 생성]
    F --> G[3D 모델 생성 시작]
    F --> H[스크립트 생성]
    G --> I[모델 생성 완료 대기]
    H --> J[결과 통합]
    I --> J
    J --> K[완료]
{% endmermaid %}

### 예상 처리 시간

| 단계 | 소요 시간 | 설명 |
|------|-----------|------|
| 시나리오 생성 | 60초 | AI가 게임 시나리오 생성 |
| 스크립트 생성 | 20초 | Unity C# 스크립트 생성 |
| 3D 모델 생성 | 5-8분 | Meshy AI로 3D 모델 생성 |
| **전체** | **5-8분** | 병렬 처리로 시간 단축 |

---

## 사용 예시

### cURL을 이용한 요청

```bash
curl -X POST http://localhost:8080/room/create \
  -H "Authorization: your_api_key" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "uuid": "user_12345",
    "theme": "중세 성의 지하 감옥",
    "keywords": ["던전", "기사", "보물", "열쇠"],
    "difficulty": "hard",
    "room_prefab": "https://example.com/prefabs/medieval_dungeon.fbx"
  }'
```

### Unity C#에서 요청

```csharp
[System.Serializable]
public class RoomCreationRequest
{
    public string uuid;
    public string theme;
    public string[] keywords;
    public string difficulty;
    public string room_prefab;
}

[System.Serializable]
public class RoomCreationResponse
{
    public string ruid;
    public string status;
    public string message;
    public bool success;
}

IEnumerator CreateRoom(RoomCreationRequest request)
{
    string jsonRequest = JsonUtility.ToJson(request);
    byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(jsonRequest);
    
    using (UnityWebRequest www = new UnityWebRequest(
        "http://localhost:8080/room/create", "POST"))
    {
        www.uploadHandler = new UploadHandlerRaw(bodyRaw);
        www.downloadHandler = new DownloadHandlerBuffer();
        
        www.SetRequestHeader("Content-Type", "application/json; charset=utf-8");
        www.SetRequestHeader("Authorization", apiKey);
        
        yield return www.SendWebRequest();
        
        if (www.result == UnityWebRequest.Result.Success)
        {
            RoomCreationResponse response = JsonUtility.FromJson<RoomCreationResponse>(
                www.downloadHandler.text);
            
            Debug.Log($"Room creation started: {response.ruid}");
            
            // 결과 폴링 시작
            StartCoroutine(PollForResult(response.ruid));
        }
        else
        {
            Debug.LogError($"Room creation failed: {www.error}");
        }
    }
}
```

### JavaScript에서 요청

```javascript
async function createRoom(roomData) {
  try {
    const response = await fetch('http://localhost:8080/room/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'your_api_key'
      },
      body: JSON.stringify({
        uuid: roomData.userId,
        theme: roomData.theme,
        keywords: roomData.keywords,
        difficulty: roomData.difficulty || 'normal',
        room_prefab: roomData.prefabUrl
      })
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'Room creation failed');
    }
    
    const result = await response.json();
    console.log('Room creation started:', result.ruid);
    
    // 결과 폴링 시작
    return pollForResult(result.ruid);
    
  } catch (error) {
    console.error('Error creating room:', error);
    throw error;
  }
}
```

---

## 난이도별 특징

### 생성되는 콘텐츠 차이

| 난이도 | 오브젝트 수 | 퍼즐 복잡도 | 힌트 제공 |
|--------|-------------|-------------|-----------|
| **easy** | 4-5개 | 직접적/단순 | 자세한 힌트 |
| **normal** | 5-7개 | 중간 추론 필요 | 적절한 힌트 |
| **hard** | 7-9개 | 복잡한 다단계 | 최소한의 힌트 |

*GameManager는 오브젝트 수에 포함되지 않음*

---

## 키워드 자동 확장

서버는 제공된 키워드가 부족한 경우 테마에 맞는 키워드를 자동으로 추가합니다:

```json
// 요청
{
  "theme": "우주정거장",
  "keywords": ["우주"]
}

// AI가 확장
{
  "keywords": ["우주", "무중력", "산소", "에어락", "통신장치"]
}
```

---

## 주의사항

1. **비동기 처리**: 요청 후 즉시 ruid를 받고, 완료까지 폴링 필요
2. **처리 시간**: 전체 처리에 5-8분 소요
3. **큐 시스템**: 동시 처리 제한 (기본값: 1)
4. **결과 조회**: 한 번 조회하면 서버에서 삭제됨

---

## 에러 처리

### 일반적인 에러 시나리오

| 상황 | 에러 메시지 | 해결 방법 |
|------|-------------|-----------|
| JSON 형식 오류 | "JSON 요청 본문 파싱에 실패했습니다." | JSON 문법 확인 |
| 필수 필드 누락 | "UUID가 비어있습니다" | 모든 필수 필드 제공 |
| 인증 실패 | "인증이 필요합니다" | Authorization 헤더 확인 |

---

## 관련 엔드포인트

- [GET /room/result](room-result.md) - 생성 결과 조회
- [GET /queue/status](queue-status.md) - 큐 상태 확인
- [GET /health](health-check.md) - 서버 상태 확인

---

[← API 명세서로 돌아가기](../rest-api-spec.md)