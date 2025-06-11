# 6.2 에러 코드 정의

## 🚨 에러 코드 개요

<div style="background: linear-gradient(to right, #f093fb 0%, #f5576c 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">체계적인 에러 처리</h3>
  <p style="margin: 10px 0 0 0;">명확한 에러 메시지와 HTTP 상태 코드로 문제를 신속하게 파악</p>
</div>

---

## 📊 HTTP 상태 코드

### 성공 응답

| 코드 | 상태 | 사용 시나리오 |
|------|------|---------------|
| **200** | OK | 정상적인 GET 요청 완료 |
| **202** | Accepted | 비동기 작업 시작 (룸 생성 요청) |

### 클라이언트 에러 (4xx)

| 코드 | 상태 | 사용 시나리오 |
|------|------|---------------|
| **400** | Bad Request | 잘못된 요청 형식, 필수 파라미터 누락 |
| **401** | Unauthorized | API 키 인증 실패 |
| **404** | Not Found | 존재하지 않는 리소스 (ruid) |

### 서버 에러 (5xx)

| 코드 | 상태 | 사용 시나리오 |
|------|------|---------------|
| **500** | Internal Server Error | 예상치 못한 서버 오류 |

---

## 🔍 에러 응답 형식

### 표준 에러 응답 구조

```json
{
  "success": false,
  "error": "구체적인 에러 메시지",
  "timestamp": "1234567890"
}
```

### 필드 설명

| 필드 | 타입 | 설명 |
|------|------|------|
| `success` | Boolean | 항상 false |
| `error` | String | 사람이 읽을 수 있는 에러 메시지 |
| `timestamp` | String | 에러 발생 시각 (Unix timestamp) |

---

## 📋 엔드포인트별 에러

### 1. 인증 에러 (모든 엔드포인트)

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔐 401 Unauthorized</h4>
  
  **헤더 누락:**
  ```json
  {
    "error": "인증이 필요합니다"
  }
  ```
  
  **잘못된 API 키:**
  ```json
  {
    "error": "인증 실패"
  }
  ```
  
  **해결 방법:**
  - Authorization 헤더 확인
  - API 키 값 검증
  - 환경 변수 설정 확인
</div>

### 2. POST /room/create 에러

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 400 Bad Request</h4>
  
  **JSON 파싱 실패:**
  ```json
  {
    "success": false,
    "error": "Failed to parse JSON request body."
  }
  ```
  
  **필수 필드 누락:**
  ```json
  {
    "success": false,
    "error": "Invalid request body or missing 'uuid' (userId)."
  }
  ```
  
  **검증 실패 메시지들:**
  - "UUID가 비어있습니다"
  - "테마가 비어있습니다"
  - "키워드가 비어있습니다"
  - "빈 키워드가 포함되어 있습니다"
  - "roomPrefab URL이 비어있습니다"
  - "유효하지 않은 roomPrefab URL 형식입니다"
  - "유효하지 않은 난이도입니다. easy, normal, hard 중 하나를 선택하세요."
</div>

### 3. GET /room/result 에러

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔍 조회 관련 에러</h4>
  
  **400 Bad Request - 파라미터 누락:**
  ```json
  {
    "success": false,
    "error": "Query parameter 'ruid' is required."
  }
  ```
  
  **404 Not Found - 결과 없음:**
  ```json
  {
    "success": false,
    "error": "Job with ruid 'room_12345' not found. It may have been already claimed or never existed."
  }
  ```
</div>

---

## 🔄 처리 실패 에러

### 백그라운드 처리 중 발생 가능한 에러

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚙️ 처리 단계별 에러</h4>
  
  **시나리오 생성 실패:**
  ```json
  {
    "ruid": "room_12345",
    "uuid": "user_12345",
    "success": false,
    "error": "통합 시나리오 생성 실패: LLM 응답이 null입니다.",
    "timestamp": "1234567890"
  }
  ```
  
  **스크립트 생성 실패:**
  ```json
  {
    "success": false,
    "error": "통합 스크립트 생성 실패",
    "timestamp": "1234567890"
  }
  ```
  
  **시스템 오류:**
  ```json
  {
    "success": false,
    "error": "시스템 오류가 발생했습니다",
    "timestamp": "1234567890"
  }
  ```
</div>

---

## 📊 에러 코드 매핑

### 비즈니스 로직 에러

| 에러 메시지 | 원인 | 해결 방법 |
|-------------|------|-----------|
| "UUID가 비어있습니다" | uuid 필드 누락/공백 | uuid 값 제공 |
| "테마가 비어있습니다" | theme 필드 누락/공백 | theme 값 제공 |
| "키워드가 비어있습니다" | keywords 배열 비어있음 | 최소 1개 키워드 추가 |
| "유효하지 않은 난이도" | 잘못된 difficulty 값 | easy/normal/hard 중 선택 |

### 시스템 에러

| 에러 유형 | 예상 메시지 | 서버 동작 |
|-----------|-------------|-----------|
| API 키 누락 | "Anthropic API 키가 설정되지 않았습니다" | 서버 종료 |
| 설정 오류 | "프롬프트 설정을 찾을 수 없습니다" | 서버 종료 |
| AI 응답 없음 | "시나리오 생성 응답이 비어있습니다" | 서버 종료 |

---

## 🛠️ 에러 처리 모범 사례

### 클라이언트 측 에러 처리

```csharp
// Unity C# 예제
public void HandleApiError(UnityWebRequest www)
{
    try
    {
        var errorResponse = JsonUtility.FromJson<ErrorResponse>(
            www.downloadHandler.text);
        
        switch (www.responseCode)
        {
            case 400:
                HandleBadRequest(errorResponse.error);
                break;
            case 401:
                HandleUnauthorized();
                break;
            case 404:
                HandleNotFound(errorResponse.error);
                break;
            case 500:
                HandleServerError(errorResponse.error);
                break;
            default:
                HandleUnknownError(www.responseCode);
                break;
        }
    }
    catch (Exception e)
    {
        Debug.LogError($"Failed to parse error response: {e.Message}");
    }
}

void HandleBadRequest(string error)
{
    if (error.Contains("UUID"))
    {
        ShowMessage("사용자 ID가 필요합니다.");
    }
    else if (error.Contains("테마"))
    {
        ShowMessage("방탈출 테마를 입력해주세요.");
    }
    else if (error.Contains("키워드"))
    {
        ShowMessage("최소 하나의 키워드를 입력해주세요.");
    }
    else
    {
        ShowMessage($"요청 오류: {error}");
    }
}
```

### JavaScript 에러 처리

```javascript
async function handleApiCall(url, options) {
  try {
    const response = await fetch(url, options);
    
    if (!response.ok) {
      const error = await response.json();
      
      switch (response.status) {
        case 400:
          throw new BadRequestError(error.error);
        case 401:
          throw new UnauthorizedError('인증이 필요합니다');
        case 404:
          throw new NotFoundError(error.error);
        case 500:
          throw new ServerError(error.error || '서버 오류');
        default:
          throw new ApiError(`Unknown error: ${response.status}`);
      }
    }
    
    return await response.json();
    
  } catch (error) {
    if (error instanceof ApiError) {
      handleKnownError(error);
    } else {
      handleNetworkError(error);
    }
    throw error;
  }
}

class ApiError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
  }
}

class BadRequestError extends ApiError {
  constructor(message) {
    super(message, 400);
  }
}
```

---

## 📈 에러 모니터링

### 에러 로그 분석

```bash
#!/bin/bash
# error-analysis.sh

LOG_FILE="logs/server.log"
OUTPUT="error-report.txt"

echo "=== ERoom 에러 분석 리포트 ===" > $OUTPUT
echo "분석 시간: $(date)" >> $OUTPUT
echo "" >> $OUTPUT

# 에러 타입별 집계
echo "## 에러 타입별 통계" >> $OUTPUT
grep ERROR $LOG_FILE | awk -F': ' '{print $2}' | \
  sort | uniq -c | sort -rn >> $OUTPUT

echo "" >> $OUTPUT

# 시간대별 에러 발생
echo "## 시간대별 에러 발생" >> $OUTPUT
grep ERROR $LOG_FILE | awk '{print $1}' | \
  cut -d: -f1 | sort | uniq -c >> $OUTPUT

echo "" >> $OUTPUT

# 최근 에러
echo "## 최근 10개 에러" >> $OUTPUT
grep ERROR $LOG_FILE | tail -10 >> $OUTPUT

echo "리포트 생성 완료: $OUTPUT"
```

---

## 🔧 에러 복구 전략

### 재시도 가능한 에러

| 에러 | 재시도 권장 | 재시도 전략 |
|------|--------------|--------------|
| 500 Server Error | ✅ | 지수 백오프 |
| 네트워크 타임아웃 | ✅ | 3회까지 |
| 404 Not Found | ❌ | 재시도 불가 |
| 401 Unauthorized | ❌ | API 키 확인 필요 |
| 400 Bad Request | ❌ | 요청 수정 필요 |

### 자동 재시도 구현

```javascript
async function retryableRequest(fn, maxRetries = 3) {
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      
      // 재시도 불가능한 에러는 즉시 throw
      if (error.statusCode === 400 || 
          error.statusCode === 401 || 
          error.statusCode === 404) {
        throw error;
      }
      
      // 지수 백오프
      const delay = Math.pow(2, i) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  
  throw lastError;
}
```

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>명확한 에러 처리는 <strong>안정적인 서비스</strong>의 핵심입니다.</p>
</div>