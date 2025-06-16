# 6.3 샘플 코드

## 💻 샘플 코드 개요

<div style="background: linear-gradient(to right, #11998e, #38ef7d); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">실전 API 사용 예제</h3>
  <p style="margin: 10px 0 0 0;">cURL과 JSON을 활용한 완전한 API 통합 가이드</p>
</div>

---

## 🔧 cURL 기본 사용법

### 서버 상태 확인

```bash
# 기본 상태 확인
curl $EROOM_BASE_URL/ \
  -H "Authorization: $EROOM_API_KEY"

# 상세 헬스체크 (jq로 포맷팅)
curl $EROOM_BASE_URL/health \
  -H "Authorization: $EROOM_API_KEY" | jq '.'
```

---

## 🚀 전체 워크플로우 예제

### 룸 생성 요청

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 JSON 요청 본문</h4>

**request.json:**
  ```json
  {
  "uuid": "user_12345",
  "theme": "victoria",
  "keywords": ["vase", "music box", "fire place"],
  "difficulty": "normal",
  "room_prefab": "https://github.com/BangTalBoyBand/Claude_Checking_Room_List/blob/main/testMap03.prefab"
}
  ```

**cURL 명령:**
  ```bash
  # 룸 생성 요청
  RESPONSE=$(curl -s -X POST $EROOM_BASE_URL/room/create \
    -H "Authorization: $EROOM_API_KEY" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @request.json)
  
  # ruid 추출
  RUID=$(echo $RESPONSE | jq -r '.ruid')
  echo "Room ID: $RUID"
  ```
</div>

---

## 📊 JSON 데이터 구조

### 요청/응답 헤더 형식

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔐 헤더 구조</h4>

**모든 요청에 필요한 헤더:**
  ```json
  {
    "Authorization": "your_api_key_here",
    "Content-Type": "application/json; charset=utf-8"
  }
  ```

**cURL에서 헤더 설정:**
  ```bash
  curl -X POST $EROOM_BASE_URL/room/create \
    -H "Authorization: $EROOM_API_KEY" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d '{"uuid": "user_123", ...}'
  ```
</div>

### 요청 본문 예제

```json
// 간단한 요청
{
  "uuid": "test_user",
  "theme": "victoria",
  "keywords": ["antique", "clock"],
  "room_prefab": "https://github.com/BangTalBoyBand/Claude_Checking_Room_List/blob/main/testMap03.prefab"
}

// 상세한 요청
{
  "uuid": "advanced_user",
  "theme": "modern_lab",
  "keywords": ["experiment", "computer", "laser", "robot", "security"],
  "difficulty": "hard",
  "room_prefab": "https://github.com/BangTalBoyBand/Claude_Checking_Room_List/blob/main/modernLab.prefab"
}
```

---

## 🛠️ 유틸리티 스크립트

### 큐 모니터링

```bash
#!/bin/bash
# queue-monitor.sh

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

while true; do
  clear
  echo "======================================"
  echo "       ERoom Queue Monitor"
  echo "======================================"
  echo "Time: $(date +"%Y-%m-%d %H:%M:%S")"
  echo ""
  
  # 큐 상태 가져오기
  QUEUE_STATUS=$(curl -s $EROOM_BASE_URL/queue/status \
    -H "Authorization: $EROOM_API_KEY")
  
  if [ $? -eq 0 ]; then
    QUEUED=$(echo $QUEUE_STATUS | jq '.queued')
    ACTIVE=$(echo $QUEUE_STATUS | jq '.active')
    COMPLETED=$(echo $QUEUE_STATUS | jq '.completed')
    MAX=$(echo $QUEUE_STATUS | jq '.maxConcurrent')
    
    # 상태별 색상
    if [ $QUEUED -gt 10 ]; then
      QUEUE_COLOR=$RED
    elif [ $QUEUED -gt 5 ]; then
      QUEUE_COLOR=$YELLOW
    else
      QUEUE_COLOR=$GREEN
    fi
    
    echo -e "대기 중: ${QUEUE_COLOR}$QUEUED${NC}"
    echo -e "처리 중: ${GREEN}$ACTIVE${NC} / $MAX"
    echo -e "완료됨: $COMPLETED"
    echo ""
    
    # 시각적 표시
    echo -n "Queue: "
    for i in $(seq 1 $QUEUED); do echo -n "⏳"; done
    echo ""
    echo -n "Active: "
    for i in $(seq 1 $ACTIVE); do echo -n "⚙️ "; done
    echo ""
    
    # 경고 메시지
    if [ $QUEUED -gt 10 ]; then
      echo ""
      echo -e "${RED}⚠️  경고: 큐가 혼잡합니다!${NC}"
    fi
  else
    echo -e "${RED}❌ 서버 연결 실패${NC}"
  fi
  
  echo ""
  echo "Press Ctrl+C to exit"
  sleep 3
done
```

---

## 🧪 테스트 시나리오

### 전체 플로우 테스트

```bash
#!/bin/bash
# full-test.sh

echo "🧪 ERoom API 전체 테스트"
echo "========================"

# 1. 서버 상태 확인
echo ""
echo "1️⃣ 서버 상태 확인..."
curl -s $EROOM_BASE_URL/health \
  -H "Authorization: $EROOM_API_KEY" | jq '.'

# 2. 룸 생성
echo ""
echo "2️⃣ 룸 생성 요청..."
CREATE_RESPONSE=$(curl -s -X POST $EROOM_BASE_URL/room/create \
  -H "Authorization: $EROOM_API_KEY" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "uuid": "test_'$(date +%s)'",
    "theme": "victoria",
    "keywords": ["vase", "music box", "antique", "clock"],
    "difficulty": "normal",
    "room_prefab": "https://github.com/BangTalBoyBand/Claude_Checking_Room_List/blob/main/testMap03.prefab"
  }')

echo $CREATE_RESPONSE | jq '.'
RUID=$(echo $CREATE_RESPONSE | jq -r '.ruid')

# 3. 큐 상태 확인
echo ""
echo "3️⃣ 큐 상태 확인..."
curl -s $EROOM_BASE_URL/queue/status \
  -H "Authorization: $EROOM_API_KEY" | jq '.'

# 4. 결과 폴링
echo ""
echo "4️⃣ 결과 대기 중..."
./poll-room.sh $RUID

# 5. 결과 처리
if [ -f "room_${RUID}.json" ]; then
  echo ""
  echo "5️⃣ 결과 처리..."
  ./process-result.sh "room_${RUID}.json"
fi

echo ""
echo "✅ 테스트 완료!"
```

---

## 🔍 디버깅 도구

### API 요청 디버그

```bash
#!/bin/bash
# debug-request.sh

# 상세 디버그 모드로 cURL 실행
curl -v -X POST $EROOM_BASE_URL/room/create \
  -H "Authorization: $EROOM_API_KEY" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "uuid": "debug_test",
    "theme": "modern_lab",
    "keywords": ["computer", "experiment"],
    "difficulty": "easy",
    "room_prefab": "https://github.com/BangTalBoyBand/Claude_Checking_Room_List/blob/main/testMap03.prefab"
  }' 2>&1 | tee debug.log

echo ""
echo "디버그 로그가 debug.log에 저장되었습니다."
```

### 에러 처리 예제

```bash
#!/bin/bash
# error-handling.sh

# API 호출 함수
call_api() {
  local endpoint=$1
  local method=${2:-GET}
  local data=${3:-}
  
  if [ "$method" = "POST" ]; then
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$EROOM_BASE_URL$endpoint" \
      -H "Authorization: $EROOM_API_KEY" \
      -H "Content-Type: application/json; charset=utf-8" \
      -d "$data")
  else
    RESPONSE=$(curl -s -w "\n%{http_code}" "$EROOM_BASE_URL$endpoint" \
      -H "Authorization: $EROOM_API_KEY")
  fi
  
  # 응답과 상태 코드 분리
  BODY=$(echo "$RESPONSE" | sed '$d')
  STATUS_CODE=$(echo "$RESPONSE" | tail -n1)
  
  # 상태 코드별 처리
  case $STATUS_CODE in
    200|202)
      echo "$BODY"
      return 0
      ;;
    400)
      echo "❌ 잘못된 요청: $(echo $BODY | jq -r '.error')"
      return 1
      ;;
    401)
      echo "❌ 인증 실패: API 키를 확인하세요"
      return 1
      ;;
    404)
      echo "❌ 리소스를 찾을 수 없습니다"
      return 1
      ;;
    500)
      echo "❌ 서버 오류"
      return 1
      ;;
    *)
      echo "❌ 알 수 없는 오류: $STATUS_CODE"
      return 1
      ;;
  esac
}

# 사용 예제
echo "정상 요청 테스트:"
call_api "/health"

echo ""
echo "에러 요청 테스트 (잘못된 JSON):"
call_api "/room/create" "POST" '{"invalid": json}'
```

---

## 📊 성능 측정

### 응답 시간 측정

```bash
#!/bin/bash
# performance-test.sh

echo "🚀 API 성능 테스트"
echo "=================="

# 각 엔드포인트 테스트
ENDPOINTS=(
  "/"
  "/health"
  "/queue/status"
)

for endpoint in "${ENDPOINTS[@]}"; do
  echo ""
  echo "테스트: GET $endpoint"
  
  # 10회 반복 측정
  total_time=0
  for i in {1..10}; do
    time=$(curl -s -o /dev/null -w "%{time_total}" \
      "$EROOM_BASE_URL$endpoint" \
      -H "Authorization: $EROOM_API_KEY")
    
    total_time=$(echo "$total_time + $time" | bc)
    echo -n "."
  done
  
  avg_time=$(echo "scale=3; $total_time / 10" | bc)
  echo ""
  echo "평균 응답 시간: ${avg_time}초"
done
```

---

## 🔐 보안 테스트

### API 키 검증

```bash
#!/bin/bash
# security-test.sh

echo "🔐 보안 테스트"
echo "============="

# 1. 인증 없이 요청
echo ""
echo "1️⃣ 인증 없이 요청:"
curl -s $EROOM_BASE_URL/health | jq '.'

# 2. 잘못된 API 키
echo ""
echo "2️⃣ 잘못된 API 키:"
curl -s $EROOM_BASE_URL/health \
  -H "Authorization: wrong_api_key" | jq '.'

```

---

## 🎨 실제 사용 예제

### Victoria 테마 룸 생성

```bash
#!/bin/bash
# create-victoria-room.sh

echo "🏰 빅토리아 시대 룸 생성"
echo "======================"

# Victoria 테마 요청
VICTORIA_REQUEST='{
  "uuid": "user_victoria_'$(date +%s)'",
  "theme": "victoria",
  "keywords": ["vase", "music box", "fire place", "antique", "clock"],
  "difficulty": "normal",
  "room_prefab": "https://github.com/BangTalBoyBand/Claude_Checking_Room_List/blob/main/testMap03.prefab"
}'

echo "📝 요청 본문:"
echo $VICTORIA_REQUEST | jq '.'

echo ""
echo "🚀 룸 생성 시작..."
RESPONSE=$(curl -s -X POST $EROOM_BASE_URL/room/create \
  -H "Authorization: $EROOM_API_KEY" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$VICTORIA_REQUEST")

echo $RESPONSE | jq '.'
RUID=$(echo $RESPONSE | jq -r '.ruid')

if [ "$RUID" != "null" ]; then
  echo ""
  echo "✅ 룸 생성 요청 성공! RUID: $RUID"
  echo "🔄 결과를 기다리는 중..."
  ./poll-room.sh $RUID
else
  echo "❌ 룸 생성 요청 실패"
fi
```

### 모던 랩 테마 룸 생성

```bash
#!/bin/bash
# create-modern-lab-room.sh

echo "🔬 현대 연구소 룸 생성"
echo "==================="

# Modern Lab 테마 요청
LAB_REQUEST='{
  "uuid": "user_lab_'$(date +%s)'",
  "theme": "modern_lab",
  "keywords": ["experiment", "computer", "laser", "security", "robot"],
  "difficulty": "hard",
  "room_prefab": "https://github.com/BangTalBoyBand/Claude_Checking_Room_List/blob/main/modernLab.prefab"
}'

echo "📝 요청 본문:"
echo $LAB_REQUEST | jq '.'

echo ""
echo "🚀 룸 생성 시작..."
RESPONSE=$(curl -s -X POST $EROOM_BASE_URL/room/create \
  -H "Authorization: $EROOM_API_KEY" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d "$LAB_REQUEST")

echo $RESPONSE | jq '.'
RUID=$(echo $RESPONSE | jq -r '.ruid')

if [ "$RUID" != "null" ]; then
  echo ""
  echo "✅ 룸 생성 요청 성공! RUID: $RUID"
  echo "🔄 결과를 기다리는 중..."
  ./poll-room.sh $RUID
else
  echo "❌ 룸 생성 요청 실패"
fi
```

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>이 샘플 코드들을 활용하여 <strong>완전한 API 통합</strong>을 구현하세요.</p>
</div>