# 서버 상태 확인 API

## GET / - 기본 상태 확인

### 개요
서버의 기본 동작 상태를 확인하는 가장 간단한 엔드포인트입니다.

---

## 요청 상세

### HTTP 메서드
    GET /

### 필수 헤더
```http
Authorization: your_api_key
```

### 요청 본문
없음

---

## 응답 상세

### 성공 응답 (200 OK)

```json
{
  "status": "online",
  "message": "Eroom 서버가 작동 중입니다"
}
```

| 필드      | 타입     | 설명               |
|---------|--------|------------------|
| status  | String | 서버 상태 ("online") |
| message | String | 상태 메시지           |

### 에러 응답 (401 Unauthorized)

```json
{
  "error": "인증이 필요합니다"
}
```

---

## GET /health - 상세 헬스체크

### 개요
서버의 상세한 상태와 큐 처리 통계를 제공합니다.

---

## 요청 상세

### HTTP 메서드
    GET /health

### 필수 헤더
```http
Authorization: your_api_key
```

### 요청 본문
없음

---

## 응답 상세

### 성공 응답 (200 OK)

```json
{
  "status": "healthy",
  "queue": {
    "queued": 3,
    "active": 1,
    "completed": 150,
    "maxConcurrent": 1
  }
}
```

| 필드                  | 타입      | 설명            |
|---------------------|---------|---------------|
| status              | String  | 서버 건강 상태      |
| queue               | Object  | 큐 상태 정보       |
| queue.queued        | Integer | 대기 중인 요청 수    |
| queue.active        | Integer | 현재 처리 중인 요청 수 |
| queue.completed     | Integer | 완료된 총 요청 수    |
| queue.maxConcurrent | Integer | 최대 동시 처리 가능 수 |

---

## 사용 예시

### cURL을 이용한 요청

```bash
# 기본 상태 확인
curl http://localhost:8080/ \
  -H "Authorization: your_api_key"

# 상세 헬스체크
curl http://localhost:8080/health \
  -H "Authorization: your_api_key"
```

### Unity C#에서 요청

```csharp
IEnumerator CheckServerHealth()
{
    using (UnityWebRequest www = UnityWebRequest.Get("http://localhost:8080/health"))
    {
        www.SetRequestHeader("Authorization", apiKey);
        
        yield return www.SendWebRequest();
        
        if (www.result == UnityWebRequest.Result.Success)
        {
            HealthResponse response = JsonUtility.FromJson<HealthResponse>(www.downloadHandler.text);
            Debug.Log($"Server Status: {response.status}");
            Debug.Log($"Queue Status - Queued: {response.queue.queued}, Active: {response.queue.active}");
        }
        else
        {
            Debug.LogError($"Health check failed: {www.error}");
        }
    }
}

[System.Serializable]
public class HealthResponse
{
    public string status;
    public QueueStatus queue;
}

[System.Serializable]
public class QueueStatus
{
    public int queued;
    public int active;
    public int completed;
    public int maxConcurrent;
}
```

---

## 모니터링 활용

### 헬스체크 자동화

```bash
#!/bin/bash
# health-monitor.sh

while true; do
  RESPONSE=$(curl -s http://localhost:8080/health \
    -H "Authorization: $EROOM_PRIVATE_KEY")
  
  QUEUED=$(echo $RESPONSE | jq '.queue.queued')
  ACTIVE=$(echo $RESPONSE | jq '.queue.active')
  
  echo "[$(date)] Queued: $QUEUED, Active: $ACTIVE"
  
  # 큐가 너무 많이 쌓였을 때 알림
  if [ $QUEUED -gt 10 ]; then
    echo "⚠️  Warning: Queue is building up!"
  fi
  
  sleep 10
done
```

---

## 주의사항

1. **인증 필수**: Authorization 헤더 없이는 401 오류 발생
2. **응답 속도**: 일반적으로 10-20ms 이내 응답
3. **모니터링 주기**: 과도한 헬스체크는 서버 부하 유발 (10초 이상 권장)

---

## 관련 엔드포인트

- [GET /queue/status](queue-status.md) - 큐 상태만 확인
- [POST /room/create](room-create.md) - 룸 생성 요청

---

[← API 명세서로 돌아가기](../rest-api-spec.md)