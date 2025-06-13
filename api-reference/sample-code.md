# 6.3 샘플 코드

## 💻 샘플 코드 개요

<div style="background: linear-gradient(to right, #11998e, #38ef7d); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">실전 API 사용 예제</h3>
  <p style="margin: 10px 0 0 0;">cURL과 JSON을 활용한 완전한 API 통합 가이드</p>
</div>

---

## 🔧 cURL 기본 사용법

### 환경 설정

```bash
# 환경 변수 설정 (Linux/Mac)
export EROOM_API_KEY="your_api_key_here"
export EROOM_BASE_URL="http://localhost:8080"

# Windows PowerShell
$env:EROOM_API_KEY = "your_api_key_here"
$env:EROOM_BASE_URL = "http://localhost:8080"
```

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

### 1. 룸 생성 요청

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 JSON 요청 본문</h4>

**request.json:**
  ```json
  {
    "uuid": "user_12345",
    "theme": "미래 우주정거장",
    "keywords": ["SF", "퍼즐", "생존", "우주"],
    "difficulty": "normal",
    "room_prefab": "https://example.com/prefabs/space_station.fbx"
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

### 2. 결과 폴링 스크립트

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔄 자동 폴링</h4>

**poll-room.sh:**
  ```bash
  #!/bin/bash
  
  # 설정
  RUID=$1
  POLL_INTERVAL=2
  MAX_INTERVAL=10
  MULTIPLIER=1.5
  TIMEOUT=900  # 15분
  
  if [ -z "$RUID" ]; then
    echo "Usage: ./poll-room.sh <ruid>"
    exit 1
  fi
  
  echo "🔄 룸 생성 상태 확인 시작: $RUID"
  
  START_TIME=$(date +%s)
  CURRENT_INTERVAL=$POLL_INTERVAL
  
  while true; do
    # 현재 시간 체크
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    
    if [ $ELAPSED -gt $TIMEOUT ]; then
      echo "❌ 타임아웃: ${TIMEOUT}초 초과"
      exit 1
    fi
    
    # API 호출
    RESPONSE=$(curl -s "$EROOM_BASE_URL/room/result?ruid=$RUID" \
      -H "Authorization: $EROOM_API_KEY")
    
    STATUS=$(echo $RESPONSE | jq -r '.status // "UNKNOWN"')
    
    echo "[$(date +%H:%M:%S)] 상태: $STATUS (경과: ${ELAPSED}초)"
    
    case $STATUS in
      "QUEUED")
        echo "  ⏳ 대기 중..."
        ;;
      "PROCESSING")
        echo "  ⚙️  처리 중..."
        ;;
      "COMPLETED")
        echo "✅ 완료!"
        echo $RESPONSE | jq '.' > "room_${RUID}.json"
        echo "결과가 room_${RUID}.json에 저장되었습니다."
        exit 0
        ;;
      "FAILED")
        echo "❌ 실패!"
        echo $RESPONSE | jq '.'
        exit 1
        ;;
      *)
        # status 필드가 없으면 완료된 것으로 간주
        if echo $RESPONSE | jq -e '.success' > /dev/null; then
          echo "✅ 완료!"
          echo $RESPONSE | jq '.' > "room_${RUID}.json"
          echo "결과가 room_${RUID}.json에 저장되었습니다."
          exit 0
        else
          echo "⚠️  알 수 없는 상태"
          echo $RESPONSE | jq '.'
        fi
        ;;
    esac
    
    # 대기
    sleep $CURRENT_INTERVAL
    
    # 간격 증가
    CURRENT_INTERVAL=$(echo "$CURRENT_INTERVAL * $MULTIPLIER" | bc)
    if (( $(echo "$CURRENT_INTERVAL > $MAX_INTERVAL" | bc -l) )); then
      CURRENT_INTERVAL=$MAX_INTERVAL
    fi
  done
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
  "theme": "고대 이집트 피라미드",
  "keywords": ["미라", "보물"],
  "room_prefab": "https://example.com/pyramid.fbx"
}

// 상세한 요청
{
  "uuid": "advanced_user",
  "theme": "사이버펑크 해커 은신처",
  "keywords": ["네온", "홀로그램", "AI", "해킹", "미래"],
  "difficulty": "hard",
  "room_prefab": "https://example.com/cyberpunk_room.fbx"
}
```

---

## 🛠️ 유틸리티 스크립트

### 다양한 테마 테스트

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎨 테마별 룸 생성</h4>

**batch-create.sh:**
  ```bash
  #!/bin/bash
  
  # 테마 배열
  THEMES=(
    "중세 성의 지하 감옥"
    "버려진 우주 정거장"
    "빅토리아 시대 저택"
    "고대 마야 신전"
    "현대 연구소"
  )
  
  # 각 테마에 맞는 키워드
  declare -A KEYWORDS
  KEYWORDS["중세 성의 지하 감옥"]='["던전", "기사", "마법", "열쇠"]'
  KEYWORDS["버려진 우주 정거장"]='["우주", "산소", "AI", "탈출포드"]'
  KEYWORDS["빅토리아 시대 저택"]='["귀족", "비밀", "초상화", "시계"]'
  KEYWORDS["고대 마야 신전"]='["보물", "함정", "상형문자", "제단"]'
  KEYWORDS["현대 연구소"]='["실험", "보안", "컴퓨터", "바이러스"]'
  
  # 각 테마로 룸 생성
  for theme in "${THEMES[@]}"; do
    echo "🎮 테마: $theme"
    
    # JSON 생성
    JSON=$(cat <<EOF
  {
    "uuid": "batch_test_$(date +%s)",
    "theme": "$theme",
    "keywords": ${KEYWORDS[$theme]},
    "difficulty": "normal",
    "room_prefab": "https://example.com/generic_room.fbx"
  }
  EOF
    )
    
    # 요청 전송
    RESPONSE=$(curl -s -X POST $EROOM_BASE_URL/room/create \
      -H "Authorization: $EROOM_API_KEY" \
      -H "Content-Type: application/json; charset=utf-8" \
      -d "$JSON")
    
    RUID=$(echo $RESPONSE | jq -r '.ruid')
    echo "  RUID: $RUID"
    echo ""
    
    # 다음 요청 전 잠시 대기
    sleep 2
  done
  ```
</div>

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

## 📝 결과 처리 스크립트

### 스크립트 디코딩 및 저장

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">💾 결과 파일 처리</h4>

**process-result.sh:**
  ```bash
  #!/bin/bash
  
  RESULT_FILE=$1
  
  if [ -z "$RESULT_FILE" ]; then
    echo "Usage: ./process-result.sh <result.json>"
    exit 1
  fi
  
  # 출력 디렉토리 생성
  OUTPUT_DIR="output_$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$OUTPUT_DIR/scripts"
  mkdir -p "$OUTPUT_DIR/models"
  
  echo "📁 출력 디렉토리: $OUTPUT_DIR"
  
  # 시나리오 저장
  echo "📝 시나리오 추출..."
  jq '.scenario' $RESULT_FILE > "$OUTPUT_DIR/scenario.json"
  
  # 스크립트 디코딩 및 저장
  echo "💻 스크립트 디코딩..."
  jq -r '.scripts | to_entries[] | "\(.key):\(.value)"' $RESULT_FILE | \
  while IFS=: read -r filename base64content; do
    echo "  - $filename"
    echo "$base64content" | base64 -d > "$OUTPUT_DIR/scripts/$filename"
  done
  
  # 모델 추적 정보 저장
  echo "🎨 3D 모델 정보 저장..."
  jq '.model_tracking' $RESULT_FILE > "$OUTPUT_DIR/models/tracking.json"
  
  # 요약 정보 생성
  cat > "$OUTPUT_DIR/summary.txt" << EOF
  ERoom 생성 결과 요약
  ===================
  테마: $(jq -r '.theme' $RESULT_FILE)
  난이도: $(jq -r '.difficulty' $RESULT_FILE)
  키워드: $(jq -r '.keywords | join(", ")' $RESULT_FILE)
  
  생성된 스크립트:
  $(ls -1 $OUTPUT_DIR/scripts/)
  
  3D 모델:
  $(jq -r '.model_tracking | to_entries[] | "- \(.key): \(.value)"' $RESULT_FILE)
  
  생성 시간: $(date)
  EOF
  
  echo ""
  echo "✅ 처리 완료!"
  cat "$OUTPUT_DIR/summary.txt"
  ```
</div>

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
    "theme": "스팀펑크 비행선",
    "keywords": ["증기", "기계", "구리", "비행"],
    "difficulty": "normal",
    "room_prefab": "https://example.com/steampunk.fbx"
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
    "theme": "테스트 룸",
    "keywords": ["테스트"],
    "difficulty": "easy",
    "room_prefab": "https://example.com/test.fbx"
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

# 3. SQL Injection 시도
echo ""
echo "3️⃣ SQL Injection 테스트:"
curl -s -X POST $EROOM_BASE_URL/room/create \
  -H "Authorization: $EROOM_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "uuid": "user\"; DROP TABLE users;--",
    "theme": "test",
    "keywords": ["test"],
    "room_prefab": "https://example.com/test.fbx"
  }' | jq '.'
```

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>이 샘플 코드들을 활용하여 <strong>완전한 API 통합</strong>을 구현하세요.</p>
</div>