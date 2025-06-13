# 6.1 REST API 명세서

## 🌐 API 개요

<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">ERoom REST API v1.0</h3>
  <p style="margin: 10px 0 0 0;">AI 기반 방탈출 게임 생성을 위한 완전한 API 문서</p>
</div>

### Base URL

```
http://localhost:8080
```

### 공통 인증 헤더

모든 API 요청에는 다음 헤더가 필요합니다:

```http
Authorization: your_api_key
Content-Type: application/json; charset=utf-8
```

---

## 📋 API 엔드포인트 목록

| 메서드  | 엔드포인트         | 설명             | 인증 필요 |
|------|---------------|----------------|-------|
| GET  | /             | 서버 기본 상태 확인    | ✅     |
| GET  | /health       | 상세 헬스체크 및 큐 상태 | ✅     |
| POST | /room/create  | 새로운 룸 생성 요청    | ✅     |
| GET  | /room/result  | 룸 생성 결과 조회     | ✅     |
| GET  | /queue/status | 큐 처리 상태 확인     | ✅     |

---

## 🔍 엔드포인트 상세

### 1. GET / - 서버 상태 확인

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">기본 서버 상태 확인</h4>

**요청 예시:**

```bash
curl http://localhost:8080/ \
  -H "Authorization: your_api_key"
```

**정상 응답 (200 OK):**

```json
{
  "status": "online",
  "message": "Eroom 서버가 작동 중입니다"
}
```

**에러 응답 (401 Unauthorized):**

```json
{
  "error": "인증이 필요합니다"
}
```

<div style="margin-top: 15px; text-align: center;">
  <a href="endpoints/health-check.md" style="color: #667eea; text-decoration: none; font-weight: bold;">
    📖 자세한 내용은 이곳을 클릭해주세요 →
  </a>
</div>
</div>

### 2. GET /health - 상세 헬스체크

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">서버 상태 및 큐 통계</h4>

**요청 예시:**

```bash
curl http://localhost:8080/health \
  -H "Authorization: your_api_key"
```

**정상 응답 (200 OK):**

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

<div style="margin-top: 15px; text-align: center;">
  <a href="endpoints/health-check.md" style="color: #667eea; text-decoration: none; font-weight: bold;">
    📖 자세한 내용은 이곳을 클릭해주세요 →
  </a>
</div>
</div>

### 3. POST /room/create - 룸 생성 요청

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">AI 기반 룸 생성 시작</h4>

**요청 예시:**

```bash
curl -X POST http://localhost:8080/room/create \
  -H "Authorization: your_api_key" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "uuid": "user_12345",
    "theme": "우주정거장",
    "keywords": ["미래", "과학", "생존"],
    "difficulty": "normal",
    "room_prefab": "https://example.com/prefab/space_station.fbx"
  }'
```

**정상 응답 (202 Accepted):**

```json
{
  "ruid": "room_a1b2c3d4e5f6",
  "status": "대기중",
  "message": "방 생성 요청이 수락되었습니다. 상태 확인을 위해 /room/result?ruid=room_a1b2c3d4e5f6를 폴링하세요.",
  "success": true
}
```

**에러 응답 (400 Bad Request):**

```json
{
  "success": false,
  "error": "유효하지 않은 요청 본문 또는 'uuid' (userId)가 누락되었습니다.",
  "timestamp": "1234567890"
}
```

<div style="margin-top: 15px; text-align: center;">
  <a href="endpoints/room-create.md" style="color: #667eea; text-decoration: none; font-weight: bold;">
    📖 자세한 내용은 이곳을 클릭해주세요 →
  </a>
</div>
</div>

### 4. GET /room/result - 결과 조회

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">생성 결과 확인 및 다운로드</h4>

**요청 예시:**

```bash
curl "http://localhost:8080/room/result?ruid=room_a1b2c3d4e5f6" \
  -H "Authorization: your_api_key"
```

**처리 중 응답 (200 OK):**

```json
{
  "ruid": "room_a1b2c3d4e5f6",
  "status": "PROCESSING"
}
```

**완료 응답 (200 OK):**

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
      "theme": "버려진 우주정거장",
      "difficulty": "normal",
      "description": "2157년, 목성 궤도의 연구 정거장...",
      "escape_condition": "메인 에어락을 열고 탈출",
      "puzzle_flow": "전력 복구 → 산소 시스템 → 통신 → 탈출"
    },
    "object_instructions": []
  },
  "scripts": {
    "GameManager": "base64_encoded_content",
    "OxygenController": "base64_encoded_content"
  },
  "model_tracking": {
    "OxygenTank": "https://meshy.ai/.../model.fbx",
    "ControlPanel": "res_tracking_id_2"
  },
  "success": true,
  "timestamp": "1234567890"
}
```

<div style="margin-top: 15px; text-align: center;">
  <a href="endpoints/room-result.md" style="color: #667eea; text-decoration: none; font-weight: bold;">
    📖 자세한 내용은 이곳을 클릭해주세요 →
  </a>
</div>
</div>

### 5. GET /queue/status - 큐 상태 확인

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">처리 대기열 모니터링</h4>

**요청 예시:**

```bash
curl http://localhost:8080/queue/status \
  -H "Authorization: your_api_key"
```

**정상 응답 (200 OK):**

```json
{
  "queued": 5,
  "active": 1,
  "completed": 142,
  "maxConcurrent": 1
}
```

<div style="margin-top: 15px; text-align: center;">
  <a href="endpoints/queue-status.md" style="color: #667eea; text-decoration: none; font-weight: bold;">
    📖 자세한 내용은 이곳을 클릭해주세요 →
  </a>
</div>
</div>

---

## 🔄 API 사용 플로우

### 전체 워크플로우

{% mermaid %}
sequenceDiagram
participant Client
participant API
participant Queue
participant AI

    Client->>API: POST /room/create
    API->>Queue: 큐에 추가
    API-->>Client: 202 { ruid }
    
    loop 폴링
        Client->>API: GET /room/result?ruid=xxx
        API-->>Client: { status: "PROCESSING" }
    end
    
    Queue->>AI: 처리 시작
    AI-->>Queue: 완료
    
    Client->>API: GET /room/result?ruid=xxx
    API-->>Client: { status: "COMPLETED", data... }

{% endmermaid %}

---

## 📊 HTTP 상태 코드

| 코드      | 의미                    | 사용 시나리오     |
|---------|-----------------------|-------------|
| **200** | OK                    | 성공적인 GET 요청 |
| **202** | Accepted              | 비동기 작업 시작됨  |
| **400** | Bad Request           | 잘못된 요청 형식   |
| **401** | Unauthorized          | 인증 실패       |
| **404** | Not Found             | 리소스 없음      |
| **500** | Internal Server Error | 서버 오류       |

---

## 🔐 인증 및 보안

### API Key 사용법

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔑 인증 헤더 설정</h4>

**모든 요청에 필수:**

```
Authorization: your_api_key_here
```

**환경 변수 설정:**

```bash
export EROOM_PRIVATE_KEY="your-secure-api-key"
```

**보안 권장사항:**

- API 키를 코드에 하드코딩하지 마세요
- 환경 변수로 관리하세요
- 주기적으로 키를 변경하세요
- HTTPS 사용을 권장합니다 (프로덕션)

**자동 키 생성:**
환경 변수가 설정되지 않으면 서버가 자동으로 UUID 기반 키를 생성합니다.
</div>

---

## 📈 Rate Limiting

### 요청 제한

| 엔드포인트             | 제한     | 기간 |
|-------------------|--------|----|
| POST /room/create | 10 요청  | 1분 |
| GET /room/result  | 60 요청  | 1분 |
| GET /health       | 120 요청 | 1분 |

*현재 버전에서는 Rate Limiting이 구현되지 않았습니다. 향후 추가 예정입니다.*

---

## 🐛 에러 처리

### 표준 에러 응답 형식

```json
{
  "success": false,
  "error": "구체적인 에러 메시지",
  "timestamp": "1234567890"
}
```

### 일반적인 에러 시나리오

| 에러               | 원인          | 해결 방법        |
|------------------|-------------|--------------|
| 401 Unauthorized | API 키 누락/오류 | 올바른 API 키 사용 |
| 400 Bad Request  | 필수 필드 누락    | 요청 형식 확인     |
| 404 Not Found    | 잘못된 ruid    | ruid 확인      |
| 500 Server Error | 내부 서버 오류    | 로그 확인, 재시도   |

---

## 🚀 빠른 시작 가이드

### 1. 서버 시작

```bash
# 환경 변수 설정
export EROOM_PRIVATE_KEY="your-api-key"
export ANTHROPIC_KEY="sk-ant-api03-..."
export MESHY_KEY_1="your-meshy-key"

# 서버 실행
java -jar eroom-server.jar
```

### 2. 첫 요청 테스트

```bash
# 헬스체크
curl http://localhost:8080/health \
  -H "Authorization: your-api-key"

# 룸 생성
curl -X POST http://localhost:8080/room/create \
  -H "Authorization: your-api-key" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "uuid": "test_user",
    "theme": "우주 정거장",
    "keywords": ["SF", "퍼즐"],
    "room_prefab": "https://example.com/space.fbx"
  }'
```

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>상세한 API 사용법은 각 엔드포인트별 문서를 참조하세요.</p>
</div>