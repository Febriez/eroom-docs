# 4.2 클라이언트-서버 통신

## 🔗 통신 프로토콜 개요

<div style="background: linear-gradient(to right, #11998e, #38ef7d); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">JSON 기반 RESTful 통신</h3>
  <p style="margin: 10px 0 0 0;">Unity 클라이언트와 Java 서버 간의 효율적인 데이터 교환</p>
</div>

---

## 📡 통신 아키텍처

### 전체 통신 플로우

{% mermaid %}
sequenceDiagram
    participant Unity as Unity Client
    participant Server as ERoom Server
    participant AI as AI Services
    
    Unity->>Server: POST /room/create
    Note over Unity,Server: API Key 인증
    Server-->>Unity: { "ruid": "room_12345" }
    
    loop 폴링 (2-10초 간격)
        Unity->>Server: GET /room/result?ruid=room_12345
        Server-->>Unity: { "status": "PROCESSING" }
    end
    
    Server->>AI: 백그라운드 처리
    AI-->>Server: 완료
    
    Unity->>Server: GET /room/result?ruid=room_12345
    Server-->>Unity: { "status": "COMPLETED", data... }
```

---

## 🎮 Unity 클라이언트 구현

### HTTP 통신 설정

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔧 UnityWebRequest 사용</h4>
  
  ```csharp
  using UnityEngine;
  using UnityEngine.Networking;
  using System.Collections;
  using System.Text;
  
  public class EroomAPIClient : MonoBehaviour
  {
      private const string BASE_URL = "http://localhost:8080";
      private string apiKey = "your-api-key-here";
      
      // 룸 생성 요청
      public IEnumerator CreateRoom(RoomRequest request, 
                                   System.Action<string> onSuccess, 
                                   System.Action<string> onError)
      {
          string json = JsonUtility.ToJson(request);
          byte[] bodyRaw = Encoding.UTF8.GetBytes(json);
          
          using (UnityWebRequest www = new UnityWebRequest(
              BASE_URL + "/room/create", "POST"))
          {
              www.uploadHandler = new UploadHandlerRaw(bodyRaw);
              www.downloadHandler = new DownloadHandlerBuffer();
              
              // 헤더 설정
              www.SetRequestHeader("Authorization", apiKey);
              www.SetRequestHeader("Content-Type", "application/json");
              
              yield return www.SendWebRequest();
              
              if (www.result == UnityWebRequest.Result.Success)
              {
                  RoomCreateResponse response = 
                      JsonUtility.FromJson<RoomCreateResponse>(www.downloadHandler.text);
                  onSuccess?.Invoke(response.ruid);
              }
              else
              {
                  onError?.Invoke(www.error);
              }
          }
      }
  }
  ```
</div>

### 폴링 시스템 구현

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔄 지능형 폴링</h4>
  
  ```csharp
  public class RoomPollingSystem : MonoBehaviour
  {
      private float pollInterval = 2f;  // 시작 간격
      private const float MAX_INTERVAL = 10f;
      private const float INTERVAL_MULTIPLIER = 1.5f;
      
      public IEnumerator PollForResult(string ruid, 
                                       System.Action<RoomResult> onComplete)
      {
          while (true)
          {
              yield return new WaitForSeconds(pollInterval);
              
              // 결과 조회
              yield return GetRoomResult(ruid, (result) =>
              {
                  if (result.status == "COMPLETED" || result.status == "FAILED")
                  {
                      onComplete?.Invoke(result);
                      return;
                  }
                  
                  // 간격 증가 (최대값까지)
                  pollInterval = Mathf.Min(pollInterval * INTERVAL_MULTIPLIER, 
                                          MAX_INTERVAL);
              });
          }
      }
  }
  ```
</div>

---

## 🖥️ 서버 측 구현

### 요청 처리

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📥 요청 수신 및 검증</h4>
  
  **서버 처리 과정:**
  1. **인증 확인**: Authorization 헤더 검증
  2. **JSON 파싱**: Gson을 통한 자동 변환
  3. **데이터 검증**: 필수 필드 확인
  4. **큐 등록**: 비동기 처리 시작
  5. **즉시 응답**: ruid 반환
  
  **에러 응답 형식:**
  ```json
  {
    "success": false,
    "error": "구체적인 에러 메시지"
  }
  ```
</div>

---

## 📊 데이터 모델

### Unity 요청 모델

```csharp
[System.Serializable]
public class RoomRequest
{
    public string uuid;        // 사용자 ID
    public string theme;       // 방 테마
    public string[] keywords;  // 키워드 배열
    public string difficulty;  // easy/normal/hard
    public string room_prefab; // 프리팹 URL
}
```

### Unity 응답 모델

```csharp
[System.Serializable]
public class RoomResult
{
    public string uuid;
    public string ruid;
    public string status;      // QUEUED/PROCESSING/COMPLETED/FAILED
    public ScenarioData scenario;
    public Dictionary<string, string> scripts;  // Base64 인코딩
    public Dictionary<string, string> model_tracking;
    public bool success;
    public string error;
}
```

---

## 🔐 보안 고려사항

### API Key 관리

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🛡️ Unity에서의 보안</h4>
  
  **권장사항:**
  1. **ScriptableObject 사용**
     ```csharp
     [CreateAssetMenu(fileName = "APIConfig", menuName = "Config/API")]
     public class APIConfig : ScriptableObject
     {
         [SerializeField] private string apiKey;
         public string ApiKey => apiKey;
     }
     ```
  
  2. **환경별 설정 분리**
     - 개발: 테스트 API 키
     - 프로덕션: 실제 API 키
  
  3. **빌드 제외**
     - `.gitignore`에 설정 파일 추가
     - 빌드 시 난독화
</div>

---

## 📈 성능 최적화

### 네트워크 최적화

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e3f2fd; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>압축</h4>
    <p>Gzip 압축으로 데이터 크기 감소</p>
    <code>50KB → 15KB</code>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>캐싱</h4>
    <p>결과 로컬 캐싱</p>
    <code>중복 요청 방지</code>
  </div>
  <div style="background: #f3e5f5; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>타임아웃</h4>
    <p>적절한 타임아웃 설정</p>
    <code>30초</code>
  </div>
</div>

---

## 🔄 스크립트 통합

### Base64 디코딩 및 적용

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 생성된 스크립트 처리</h4>
  
  ```csharp
  public class ScriptIntegrator : MonoBehaviour
  {
      public void ProcessScripts(Dictionary<string, string> encodedScripts)
      {
          foreach (var kvp in encodedScripts)
          {
              string scriptName = kvp.Key;
              string base64Content = kvp.Value;
              
              // Base64 디코딩
              byte[] bytes = System.Convert.FromBase64String(base64Content);
              string scriptContent = Encoding.UTF8.GetString(bytes);
              
              // 파일로 저장 (에디터에서만)
              #if UNITY_EDITOR
              string path = $"Assets/Scripts/Generated/{scriptName}";
              System.IO.File.WriteAllText(path, scriptContent);
              UnityEditor.AssetDatabase.Refresh();
              #endif
              
              // 런타임 컴파일 (실험적)
              // CompileAndAttach(scriptName, scriptContent);
          }
      }
  }
  ```
  
  **주의사항:**
  - 생성된 스크립트는 Unity 에디터에서 검토 필요
  - 런타임 컴파일은 플랫폼 제한 있음
  - 보안 검증 필수
</div>

---

## 🐛 에러 처리

### 통신 에러 대응

| 에러 유형 | 원인 | 대응 방법 |
|-----------|------|-----------|
| **401 Unauthorized** | API 키 오류 | 키 확인, 재설정 |
| **404 Not Found** | 잘못된 ruid | 재요청 불가, 새로 생성 |
| **500 Server Error** | 서버 오류 | 재시도 (지수 백오프) |
| **Timeout** | 네트워크 지연 | 타임아웃 증가, 재시도 |

### 재시도 전략

```csharp
public IEnumerator RetryableRequest(System.Func<IEnumerator> request, 
                                   int maxRetries = 3)
{
    for (int i = 0; i < maxRetries; i++)
    {
        yield return request();
        
        if (/* 성공 */) break;
        
        // 지수 백오프
        float delay = Mathf.Pow(2, i) * 1f;
        yield return new WaitForSeconds(delay);
    }
}
```

---

## 📱 플랫폼별 고려사항

<div style="background: #f0f0f0; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎯 플랫폼 특성</h4>
  
  | 플랫폼 | 특별 고려사항 |
  |--------|---------------|
  | **Windows** | 방화벽 설정 확인 |
  | **macOS** | App Transport Security |
  | **WebGL** | CORS 정책 설정 필요 |
  | **Mobile** | 배터리 최적화, 데이터 사용량 |
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>클라이언트-서버 통신은 <strong>안정적</strong>이고 <strong>효율적</strong>인 게임 경험의 기반입니다.</p>
</div>