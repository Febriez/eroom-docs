# 큐 상태 확인 API

## GET /queue/status

### 개요
서버의 요청 처리 큐 상태를 실시간으로 확인하는 API입니다. 현재 대기 중인 요청 수와 처리 상황을 모니터링할 수 있습니다.

---

## 요청 상세

### HTTP 메서드
```
GET /queue/status
```

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
  "queued": 5,
  "active": 1,
  "completed": 142,
  "maxConcurrent": 1
}
```

### 응답 필드 설명

| 필드              | 타입      | 설명                         |
|-----------------|---------|----------------------------|
| `queued`        | Integer | 현재 큐에 대기 중인 요청 수           |
| `active`        | Integer | 현재 처리 중인 요청 수              |
| `completed`     | Integer | 서버 시작 이후 완료된 총 요청 수        |
| `maxConcurrent` | Integer | 동시에 처리 가능한 최대 요청 수 (현재: 1) |

### 에러 응답 (401 Unauthorized)

```json
{
  "error": "인증 실패"
}
```

---

## 사용 예시

### cURL을 이용한 요청

```bash
curl http://localhost:8080/queue/status \
  -H "Authorization: your_api_key"
```

### Unity C#에서 모니터링

```csharp
public class QueueMonitor : MonoBehaviour
{
    [System.Serializable]
    public class QueueStatus
    {
        public int queued;
        public int active;
        public int completed;
        public int maxConcurrent;
    }
    
    private string apiKey = "your_api_key";
    private float updateInterval = 5f;
    
    void Start()
    {
        StartCoroutine(MonitorQueue());
    }
    
    IEnumerator MonitorQueue()
    {
        while (true)
        {
            yield return CheckQueueStatus();
            yield return new WaitForSeconds(updateInterval);
        }
    }
    
    IEnumerator CheckQueueStatus()
    {
        using (UnityWebRequest www = UnityWebRequest.Get(
            "http://localhost:8080/queue/status"))
        {
            www.SetRequestHeader("Authorization", apiKey);
            
            yield return www.SendWebRequest();
            
            if (www.result == UnityWebRequest.Result.Success)
            {
                QueueStatus status = JsonUtility.FromJson<QueueStatus>(
                    www.downloadHandler.text);
                
                UpdateUI(status);
                
                // 큐가 많이 쌓였을 때 경고
                if (status.queued > 10)
                {
                    ShowWarning("서버가 혼잡합니다. 처리가 지연될 수 있습니다.");
                }
            }
            else
            {
                Debug.LogError($"Queue status check failed: {www.error}");
            }
        }
    }
    
    void UpdateUI(QueueStatus status)
    {
        // UI 업데이트 로직
        Debug.Log($"Queue Status - Waiting: {status.queued}, Processing: {status.active}");
    }
}
```
---

## 활용 시나리오

### 서버 상태 표시

```csharp
public enum ServerLoad
{
    Low,      // queued < 5
    Normal,   // queued 5-10
    High,     // queued 11-20
    Critical  // queued > 20
}

ServerLoad GetServerLoad(int queued)
{
    if (queued < 5) return ServerLoad.Low;
    if (queued <= 10) return ServerLoad.Normal;
    if (queued <= 20) return ServerLoad.High;
    return ServerLoad.Critical;
}
```

---

## 성능 고려사항

### 폴링 주기 권장사항

| 용도       | 권장 주기  | 이유        |
|----------|--------|-----------|
| 실시간 모니터링 | 2-5초   | 빠른 업데이트   |
| 일반 확인    | 10-30초 | 서버 부하 감소  |
| 대시보드 표시  | 5-10초  | 균형잡힌 업데이트 |


---

## 시스템 정보

### 현재 설정

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚙️ 서버 설정</h4>

| 설정              | 값  | 설명          |
|-----------------|----|-------------|
| `maxConcurrent` | 1  | 동시 처 리 제한   |
| 워커 스레드          | 1  | 큐 처리 스레드 수  |
| 모델 생성 스레드       | 10 | 3D 모델 병렬 처리 |

현재 서버는 **한 번에 하나의 룸만** 처리하도록 설정되어 있습니다.
이는 AI API의 안정성과 비용 최적화를 위한 설계입니다.
</div>

---

## 문제 해결

| 증상                 | 가능한 원인      | 해결 방법               |
|--------------------|-------------|---------------------|
| queued가 계속 증가      | 서버 처리 속도 저하 | 서버  리소스 확인          |
| active가 0          | 워커 스레드 문제   | 서버 재시작              |
| 401 오류             | API 키 문제    | Authorization 헤더 확인 |
| completed가 증가하지 않음 | 처리 오류 발생    | 서버 로그 확인            |

---

## 관련 엔드포인트

- [GET /health](health-check.md) - 전체 서버 상태
- [POST /room/create](room-create.md) - 룸 생성 요청
- [GET /room/result](room-result.md) - 결과 조회

---

[← API 명세서로 돌아가기](../rest-api-spec.md)