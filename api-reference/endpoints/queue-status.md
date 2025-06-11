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

| 필드 | 타입 | 설명 |
|------|------|------|
| `queued` | Integer | 현재 큐에 대기 중인 요청 수 |
| `active` | Integer | 현재 처리 중인 요청 수 |
| `completed` | Integer | 서버 시작 이후 완료된 총 요청 수 |
| `maxConcurrent` | Integer | 동시에 처리 가능한 최대 요청 수 |

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

### 실시간 모니터링 스크립트

```bash
#!/bin/bash
# queue-monitor.sh

API_KEY="your_api_key"

while true; do
  clear
  echo "=== ERoom Queue Monitor ==="
  echo "Time: $(date)"
  echo ""
  
  RESPONSE=$(curl -s http://localhost:8080/queue/status \
    -H "Authorization: $API_KEY")
  
  if [ $? -eq 0 ]; then
    echo $RESPONSE | jq '.'
    
    QUEUED=$(echo $RESPONSE | jq '.queued')
    ACTIVE=$(echo $RESPONSE | jq '.active')
    
    # 시각적 표시
    echo ""
    echo -n "Queued : "
    for i in $(seq 1 $QUEUED); do echo -n "⏳"; done
    echo ""
    echo -n "Active : "
    for i in $(seq 1 $ACTIVE); do echo -n "⚙️"; done
    echo ""
    
    # 경고 표시
    if [ $QUEUED -gt 10 ]; then
      echo ""
      echo "⚠️  Warning: High queue load!"
    fi
  else
    echo "❌ Failed to fetch queue status"
  fi
  
  sleep 2
done
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

### JavaScript 대시보드

```javascript
class QueueMonitor {
  constructor(apiKey) {
    this.apiKey = apiKey;
    this.updateInterval = 2000; // 2초
  }
  
  async start() {
    setInterval(() => this.updateStatus(), this.updateInterval);
  }
  
  async updateStatus() {
    try {
      const response = await fetch('http://localhost:8080/queue/status', {
        headers: {
          'Authorization': this.apiKey
        }
      });
      
      if (response.ok) {
        const status = await response.json();
        this.updateDashboard(status);
      }
    } catch (error) {
      console.error('Failed to fetch queue status:', error);
    }
  }
  
  updateDashboard(status) {
    // 대시보드 업데이트
    document.getElementById('queued').textContent = status.queued;
    document.getElementById('active').textContent = status.active;
    document.getElementById('completed').textContent = status.completed;
    
    // 진행률 표시
    const queueBar = document.getElementById('queue-bar');
    queueBar.style.width = `${Math.min(status.queued * 10, 100)}%`;
    
    // 경고 표시
    if (status.queued > 10) {
      document.getElementById('warning').style.display = 'block';
    } else {
      document.getElementById('warning').style.display = 'none';
    }
  }
}

// 사용
const monitor = new QueueMonitor('your_api_key');
monitor.start();
```

---

## 활용 시나리오

### 1. 서버 부하 모니터링

```javascript
// 큐 상태에 따른 요청 제어
async function shouldSubmitRequest() {
  const status = await getQueueStatus();
  
  // 큐가 너무 많이 쌓였으면 대기
  if (status.queued > 20) {
    console.log('Server is busy. Please wait...');
    return false;
  }
  
  return true;
}
```

### 2. 예상 대기 시간 계산

```javascript
function estimateWaitTime(queueStatus) {
  const averageProcessingTime = 7; // 분
  const position = queueStatus.queued + 1;
  
  // 동시 처리를 고려한 예상 시간
  const estimatedMinutes = Math.ceil(position / queueStatus.maxConcurrent) 
                          * averageProcessingTime;
  
  return {
    minutes: estimatedMinutes,
    message: `예상 대기 시간: 약 ${estimatedMinutes}분`
  };
}
```

### 3. 서버 상태 표시

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

## 모니터링 대시보드 예제

### HTML 구조

```html
<div class="queue-monitor">
  <h2>Server Queue Status</h2>
  
  <div class="stats">
    <div class="stat-item">
      <label>대기 중</label>
      <span id="queued">0</span>
    </div>
    <div class="stat-item">
      <label>처리 중</label>
      <span id="active">0</span>
    </div>
    <div class="stat-item">
      <label>완료됨</label>
      <span id="completed">0</span>
    </div>
  </div>
  
  <div class="queue-visualization">
    <div id="queue-bar" class="progress-bar"></div>
  </div>
  
  <div id="warning" class="warning" style="display: none;">
    ⚠️ 서버가 혼잡합니다. 처리가 지연될 수 있습니다.
  </div>
</div>
```

---

## 성능 고려사항

### 폴링 주기 권장사항

| 용도 | 권장 주기 | 이유 |
|------|-----------|------|
| 실시간 모니터링 | 2-5초 | 빠른 업데이트 |
| 일반 확인 | 10-30초 | 서버 부하 감소 |
| 대시보드 표시 | 5-10초 | 균형잡힌 업데이트 |

### 서버 부하 최소화

```javascript
// 적응형 폴링 주기
class AdaptiveMonitor {
  constructor() {
    this.baseInterval = 5000; // 5초
    this.currentInterval = this.baseInterval;
  }
  
  adjustInterval(queueStatus) {
    if (queueStatus.queued > 10) {
      // 큐가 많을 때는 더 자주 확인
      this.currentInterval = this.baseInterval / 2;
    } else if (queueStatus.queued === 0) {
      // 큐가 비었을 때는 덜 자주 확인
      this.currentInterval = this.baseInterval * 2;
    } else {
      this.currentInterval = this.baseInterval;
    }
  }
}
```

---

## 문제 해결

| 증상 | 가능한 원인 | 해결 방법 |
|------|-------------|-----------|
| queued가 계속 증가 | 서버 처리 속도 저하 | 서버 리소스 확인 |
| active가 0 | 워커 스레드 문제 | 서버 재시작 |
| 401 오류 | API 키 문제 | Authorization 헤더 확인 |

---

## 관련 엔드포인트

- [GET /health](health-check.md) - 전체 서버 상태
- [POST /room/create](room-create.md) - 룸 생성 요청
- [GET /room/result](room-result.md) - 결과 조회

---

[← API 명세서로 돌아가기](../rest-api-spec.md)