# E-room API Documentation

{% hint style="info" %}
**Version 2.1** - ruid 기반 시스템
{% endhint %}

## 개요

E-room 서버는 RESTful API를 통해 VR 방탈출 게임의 방 생성, 상태 조회, 건강성 확인 기능을 제공합니다. 모든 API는 JSON 형식으로 통신하며, 특히 방 생성 기능은 **비동기 큐 시스템**을
통해 처리되어 클라이언트가 긴 시간 동안 응답을 기다릴 필요 없이 안정적으로 요청을 처리할 수 있습니다.

## 기본 정보

### Base URL

```
http://192.168.0.248:8080
```

### Content-Type

```
application/json
```

---

## API 엔드포인트

### 1. 서버 상태 확인 (Root)

{% swagger method="get" path="/" baseUrl="http://192.168.0.248:8080" summary="서버 기본 상태 확인" %}
{% swagger-description %}
서버의 기본 상태를 확인하는 엔드포인트입니다. 서버가 정상적으로 작동 중인지 빠르게 확인할 수 있습니다.
{% endswagger-description %}

{% swagger-response status="200: OK" description="서버 정상 작동" %}

```javascript
// 서버 상태 응답
```

{% endswagger-response %}
{% endswagger %}

**예시:**

```bash
curl -X GET http://192.168.0.248:8080/
```

### 2. 건강성 및 큐 상태 조회 (Health Check)

{% swagger method="get" path="/health" baseUrl="http://192.168.0.248:8080" summary="서버 건강성 및 큐 상태 조회" %}
{% swagger-description %}
서버의 상세한 건강성 상태와 큐 시스템의 현재 상태를 함께 확인할 수 있는 엔드포인트입니다.
{% endswagger-description %}

{% swagger-response status="200: OK" description="건강성 상태 정보" %}

```json
{
  "status": "healthy",
  "queue": {
    "queued": 2,
    "active": 1,
    "completed": 21,
    "maxConcurrent": 1
  }
}
```

{% endswagger-response %}
{% endswagger %}

**예시:**

```bash
curl -X GET http://192.168.0.248:8080/health
```

### 3. 방 생성 요청 (비동기)

{% swagger method="post" path="/room/create" baseUrl="http://192.168.0.248:8080" summary="방 생성 요청" %}
{% swagger-description %}
방 생성을 요청하는 핵심 엔드포인트입니다. 요청은 즉시 처리 큐에 등록되며, 서버는 고유한 ruid(Room Unique ID)를 생성하여 즉시 반환합니다. 실제 생성 작업은 백그라운드에서 비동기적으로 수행됩니다.
{% endswagger-description %}

{% swagger-parameter in="body" name="uuid" type="string" required="true" %}
사용자 계정 ID. 방을 생성하는 유저를 식별하기 위한 값
{% endswagger-parameter %}

{% swagger-parameter in="body" name="theme" type="string" required="true" %}
방탈출 게임의 주제/테마
{% endswagger-parameter %}

{% swagger-parameter in="body" name="keywords" type="string[]" required="true" %}
게임에 포함될 오브젝트 키워드 배열
{% endswagger-parameter %}

{% swagger-parameter in="body" name="difficulty" type="string" required="false" %}
게임 난이도 ("easy", "normal", "hard")
{% endswagger-parameter %}

{% swagger-parameter in="body" name="room_prefab" type="string" required="true" %}
Unity 방 프리팹의 HTTPS URL
{% endswagger-parameter %}

{% swagger-response status="202: Accepted" description="작업이 성공적으로 큐에 등록됨" %}

```json
{
  "ruid": "room_a1b2c3d4e5f6a7b8",
  "status": "Queued",
  "message": "Room creation request has been accepted. Poll /room/result?ruid=room_a1b2c3d4e5f6a7b8 for status."
}
```

{% endswagger-response %}

{% swagger-response status="400: Bad Request" description="잘못된 요청" %}

```json
{
  "success": false,
  "error": "Invalid request body or missing 'uuid' (userId)."
}
```

{% endswagger-response %}
{% endswagger %}

{% hint style="warning" %}
**비동기 처리:** 클라이언트는 반환된 ruid를 사용하여 `/room/result` 엔드포인트에서 작업 결과를 조회해야 합니다.
{% endhint %}

#### 요청 예시

```bash
curl -X POST http://192.168.0.248:8080/room/create \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "user-account-id-007",
    "theme": "Ancient Tomb Exploration",
    "keywords": ["sarcophagus", "torch", "hieroglyphs"],
    "room_prefab": "https://cdn.example.com/ancient-tomb.fbx"
  }'
```

#### 응답 필드 설명

| 필드        | 타입     | 설명                     |
|-----------|--------|------------------------|
| `ruid`    | String | 서버가 생성한 고유한 방 작업 식별자   |
| `status`  | String | 현재 작업 상태 ("Queued" 고정) |
| `message` | String | 다음 행동에 대한 안내 메시지       |

### 4. 생성 결과 조회 (폴링)

{% swagger method="get" path="/room/result" baseUrl="http://192.168.0.248:8080" summary="방 생성 결과 조회" %}
{% swagger-description %}
POST /room/create 요청 시 반환된 ruid를 사용하여 방 생성 작업의 현재 상태를 조회하거나 최종 결과를 가져옵니다. 클라이언트는 이 엔드포인트를 주기적으로(예: 5초마다) 호출하여 상태를 확인할 수
있습니다.
{% endswagger-description %}

{% swagger-parameter in="query" name="ruid" type="string" required="true" %}
조회할 작업의 ID
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="처리 중일 때" %}

```json
{
  "ruid": "room_1f9e8a7b6c5d4e3f",
  "status": "PROCESSING"
}
```

{% endswagger-response %}

{% swagger-response status="200: OK" description="성공적으로 완료되었을 때" %}

```json
{
  "uuid": "user-account-id-007",
  "ruid": "room_1f9e8a7b6c5d4e3f",
  "theme": "Ancient Tomb Exploration",
  "success": true,
  "scenario": {},
  "scripts": {},
  "model_tracking": {},
  "timestamp": "1703123456789"
}
```

{% endswagger-response %}

{% swagger-response status="200: OK" description="작업이 실패했을 때" %}

```json
{
  "uuid": "user-account-id-007",
  "ruid": "room_1f9e8a7b6c5d4e3f",
  "success": false,
  "error": "통합 시나리오 생성 실패: LLM 응답이 null입니다.",
  "timestamp": "1703123456789"
}
```

{% endswagger-response %}

{% swagger-response status="404: Not Found" description="ID를 찾을 수 없을 때" %}

```json
{
  "success": false,
  "error": "Job with ruid 'room_1f9e8a7b6c5d4e3f' not found. It may have been already claimed or never existed."
}
```

{% endswagger-response %}
{% endswagger %}

{% hint style="danger" %}
**중요:** 결과(성공 또는 실패)를 한 번 반환한 후에는 서버에서 해당 데이터가 삭제됩니다.
{% endhint %}

**예시:**

```bash
curl -X GET "http://192.168.0.248:8080/room/result?ruid=room_1f9e8a7b6c5d4e3f"
```

---

## 데이터 명세

### 최종 성공 결과 응답

| 필드               | 타입       | 설명                          |
|------------------|----------|-----------------------------|
| `uuid`           | String   | 요청시 제공된 사용자 계정 ID           |
| `ruid`           | String   | 시스템에서 생성한 고유한 방 작업 식별자      |
| `theme`          | String   | 생성된 방의 테마                   |
| `keywords`       | String[] | 사용된 키워드 배열                  |
| `difficulty`     | String   | 적용된 난이도                     |
| `room_prefab`    | String   | 방 프리팹 URL                   |
| `scenario`       | Object   | AI가 생성한 시나리오 데이터            |
| `scripts`        | Object   | Base64로 인코딩된 Unity C# 스크립트들 |
| `model_tracking` | Object   | 3D 모델 생성 상태 추적 ID들          |
| `success`        | Boolean  | 요청 성공 여부 (true)             |
| `timestamp`      | String   | 응답 생성 시간 (Unix timestamp)   |

---

## 사용 예시 시나리오

### Step 1: 사용자 ID 준비

클라이언트는 사용자 ID uuid를 준비합니다.

```javascript
const userId = "my-user-id";
```

### Step 2: 방 생성 요청

방 생성을 요청하고 응답으로 오는 ruid를 저장합니다.

```bash
curl -X POST http://192.168.0.248:8080/room/create \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "my-user-id",
    "theme": "Jungle Temple",
    "keywords": ["vine", "statue", "gem"],
    "room_prefab": "https://example.com/temple.fbx"
  }'
```

**응답:**

```json
{
  "ruid": "room_abcdef1234567890",
  "status": "Queued",
  "message": "Room creation request has been accepted. Poll /room/result?ruid=room_abcdef1234567890 for status."
}
```

### Step 3: 결과 조회 (폴링)

저장한 ruid로 결과를 주기적으로 폴링합니다.

```bash
# 처리 중일 때
curl -X GET "http://192.168.0.248:8080/room/result?ruid=room_abcdef1234567890"
# 응답: {"ruid":"room_abcdef1234567890","status":"PROCESSING"}

# 작업 완료 후
curl -X GET "http://192.168.0.248:8080/room/result?ruid=room_abcdef1234567890"
# 응답: {"ruid": "room_abcdef1234567890", "success": true, ...}
```

### Step 4: 결과 확인 완료

완료된 결과를 다시 조회하면 404 Not Found가 반환됩니다.

```bash
curl -X GET "http://192.168.0.248:8080/room/result?ruid=room_abcdef1234567890"
# 응답: {"success":false,"error":"Job with ruid '...' not found..."}
```

---

## 성능 특성

{% hint style="success" %}
**⚡ 빠른 응답:** POST `/room/create`의 응답 시간은 100ms 미만으로 매우 빠르며, 전체 방 생성에 소요되는 시간(30초~10분)은 백그라운드에서 처리됩니다.
{% endhint %}

## 주요 특징

- **비동기 큐 시스템:** 안정적인 방 생성 처리
- **ruid 기반 추적:** 고유한 식별자로 작업 상태 관리
- **폴링 방식:** 클라이언트가 편리하게 결과 조회
- **일회성 결과:** 보안을 위한 결과 자동 삭제

## 👥 **담당자**

**작성자**: 옥병준  
**최종 수정일**: 2025-06-11  
**문서 버전**: v2.0

---