# 5.3 모니터링 & 운영

## 📊 모니터링 개요

<div style="background: linear-gradient(to right, #11998e, #38ef7d); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">실시간 시스템 모니터링</h3>
  <p style="margin: 10px 0 0 0;">로그 기반의 간단하면서도 효과적인 모니터링 전략</p>
</div>

---

## 📝 로그 모니터링

### 로그 레벨 구성

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📋 로그 레벨별 용도</h4>

| 레벨 | 용도 | 예시 |
|------|------|------|
| **INFO** | 정상 동작 기록 | 서버 시작, 요청 처리 완료 |
| **WARN** | 주의 필요 상황 | GameManager 누락, 중복 스크립트명 |
| **ERROR** | 오류 발생 (서버 종료) | AI API 실패, 파싱 오류 |
| **DEBUG** | 상세 디버깅 | 스크립트 파싱 상세, 처리 단계 |
</div>

### 주요 로그 패턴

```bash
# 서버 시작 확인
grep "서버가 성공적으로 시작되었습니다" logs/server.log

# API 요청 추적 (상세 로그)
grep "=== 요청 제출 상세 정보 ===" logs/server.log | tail -20

# 에러 모니터링 (ERROR 발생 시 서버 종료됨)
grep -E "(ERROR|서버를 종료합니다)" logs/server.log

# 처리 시간 분석
grep "통합 방 생성 완료" logs/server.log | \
  awk '{print $1, $2, $NF}'
```

---

## 🔍 실시간 모니터링

### 기본 모니터링 명령어

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">💻 시스템 모니터링</h4>

```bash
# 실시간 로그 추적
tail -f logs/server.log | grep --line-buffered -E "(INFO|WARN|ERROR)"

# 큐 상태 모니터링 (1초마다 갱신)
watch -n 1 'curl -s http://localhost:8080/queue/status \
  -H "Authorization: your-api-key" | jq'

# 프로세스 상태 확인
ps aux | grep java | grep eroom

# 포트 사용 확인
netstat -tlnp | grep 8080

# 서버 생존 확인 (ERROR 발생 시 자동 종료되므로)
while true; do
  if ! pgrep -f "eroom-server.jar" > /dev/null; then
    echo "⚠️  서버가 종료되었습니다! $(date)"
    # 알림 전송 또는 재시작
  fi
  sleep 5
done
```
</div>

### 모니터링 대시보드 스크립트

```bash
#!/bin/bash
# monitor.sh - 간단한 모니터링 대시보드

while true; do
  clear
  echo "=== ERoom Server Monitor ==="
  echo "Time: $(date)"
  echo ""
  
  # 서버 프로세스 확인
  if pgrep -f "eroom-server.jar" > /dev/null; then
    echo "🟢 Server Status: RUNNING"
  else
    echo "🔴 Server Status: STOPPED"
    echo "서버가 종료되었습니다. ERROR 로그를 확인하세요."
  fi
  
  echo ""
  
  # API 상태
  echo "🌐 API Status:"
  curl -s http://localhost:8080/health \
    -H "Authorization: $EROOM_PRIVATE_KEY" | jq . || echo "API 응답 없음"
  
  echo ""
  
  # 시스템 리소스
  echo "💻 System Resources:"
  echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
  echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
  
  echo ""
  
  # 최근 에러 (ERROR 발생 시 서버 종료)
  echo "⚠️  Recent Errors (last 5):"
  grep -E "(ERROR|서버를 종료합니다)" logs/server.log | tail -5
  
  sleep 5
done
```

---

## 📈 성능 메트릭

### 주요 모니터링 지표

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📊 핵심 성능 지표</h4>

| 지표 | 목표값 | 임계값 | 측정 방법 |
|------|--------|--------|-----------|
| **API 응답 시간** | < 100ms | > 500ms | 로그 분석 |
| **큐 대기 시간** | < 30s | > 2분 | 큐 상태 API |
| **전체 처리 시간** | 5-8분 | > 10분 | 시작-완료 로그 |
| **서버 가동률** | 99.9% | < 95% | 프로세스 모니터링 |
| **메모리 사용** | < 1GB | > 2GB | 시스템 모니터 |
</div>

### 상세 요청 로그 분석

```bash
# 요청별 상세 정보 추출
grep "=== 요청 제출 상세 정보 ===" logs/server.log | \
  awk '/RUID:/{ruid=$2} /Theme:/{theme=$2} /Difficulty:/{diff=$2} END{print ruid, theme, diff}'

# 처리 시간 분석
grep -A5 "=== RoomService.createRoom() 완료 ===" logs/server.log | \
  grep "처리 시간:" | awk '{print $3}'
```

---

## 🚨 알림 설정

### 서버 종료 감지 및 알림

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔔 자동 감지 스크립트</h4>

```bash
#!/bin/bash
# server-monitor.sh - 서버 종료 감지 및 자동 재시작

LOG_FILE="logs/server.log"
PID_FILE="server.pid"
RESTART_DELAY=10

while true; do
  # 서버 프로세스 확인
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ! kill -0 $PID 2>/dev/null; then
      echo "🔴 서버가 종료되었습니다 (PID: $PID)"
      
      # 마지막 에러 로그 확인
      echo "마지막 에러:"
      grep -E "(ERROR|서버를 종료합니다)" "$LOG_FILE" | tail -5
      
      # 알림 전송 (옵션)
      # echo "ERoom 서버 종료됨" | mail -s "서버 알림" admin@example.com
      
      # 자동 재시작 (옵션)
      echo "🔄 ${RESTART_DELAY}초 후 재시작합니다..."
      sleep $RESTART_DELAY
      ./scripts/start.sh
      
      echo "✅ 서버 재시작 완료"
    fi
  fi
  
  sleep 5
done
```
</div>

### 치명적 에러 패턴

```bash
# 서버 종료를 유발하는 에러 패턴
FATAL_PATTERNS=(
  "Anthropic API 키가 설정되지 않았습니다"
  "프롬프트 설정을 찾을 수 없습니다"
  "설정 파일을 찾을 수 없습니다"
  "JSON 파싱 실패"
  "시나리오 생성 응답이 비어있습니다"
  "Base64 인코딩 실패"
)
```

---

## 🛠️ 운영 작업

### 일상 운영 체크리스트

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📅 일일 점검 항목</h4>

- [ ] **서버 프로세스 확인**
  ```bash
  ps aux | grep eroom-server.jar
  ```

- [ ] **서버 상태 확인**
  ```bash
  curl http://localhost:8080/health -H "Authorization: $EROOM_PRIVATE_KEY"
  ```

- [ ] **디스크 공간 확인**
  ```bash
  df -h | grep -E "/$|/logs"
  ```

- [ ] **로그 로테이션 확인**
  ```bash
  ls -lh logs/ | head -10
  ```

- [ ] **치명적 에러 검토**
  ```bash
  grep -E "(ERROR|서버를 종료합니다)" logs/server.$(date +%Y-%m-%d).log
  ```

- [ ] **큐 상태 확인**
  ```bash
  curl http://localhost:8080/queue/status -H "Authorization: $EROOM_PRIVATE_KEY"
  ```

- [ ] **상세 요청 로그 검토**
  ```bash
  grep "=== 백그라운드 처리 시작 ===" logs/server.log | tail -10
  ```
</div>

### 로그 관리

```bash
#!/bin/bash
# log-rotate.sh - 로그 로테이션 및 정리

LOG_DIR="logs"
ARCHIVE_DIR="logs/archive"
DAYS_TO_KEEP=30

# 아카이브 디렉토리 생성
mkdir -p $ARCHIVE_DIR

# 오래된 로그 압축
find $LOG_DIR -name "*.log" -mtime +7 -exec gzip {} \;

# 압축 파일 이동
mv $LOG_DIR/*.gz $ARCHIVE_DIR/

# 오래된 아카이브 삭제
find $ARCHIVE_DIR -name "*.gz" -mtime +$DAYS_TO_KEEP -delete

echo "로그 로테이션 완료: $(date)"
```

---

## 📊 통계 및 리포팅

### 운영 통계 수집

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📈 일일 통계 스크립트</h4>

```bash
#!/bin/bash
# daily-stats.sh

DATE=$(date +%Y-%m-%d)
LOG_FILE="logs/server.$DATE.log"

echo "=== ERoom 일일 통계 ($DATE) ==="
echo ""

# 서버 재시작 횟수
echo "🔄 서버 재시작:"
echo "- 종료 횟수: $(grep -c "서버를 종료합니다" $LOG_FILE)"
echo ""

# 요청 통계
echo "📊 요청 통계:"
echo "- 총 룸 생성 요청: $(grep -c "방 생성 요청 큐에 추가됨" $LOG_FILE)"
echo "- 성공: $(grep -c "통합 방 생성 완료" $LOG_FILE)"
echo "- 실패: $(grep -c "백그라운드 처리 중 오류 발생" $LOG_FILE)"
echo ""

# 성능 통계
echo "⚡ 성능 통계:"
echo "- 평균 처리 시간:"
grep "처리 시간:" $LOG_FILE | awk '{sum+=$3; count++} END {print sum/count "ms"}'
echo ""

# 오브젝트 통계
echo "🎮 오브젝트 통계:"
echo "- 평균 오브젝트 수:"
grep "오브젝트 설명 [0-9]* 개" $LOG_FILE | \
  awk '{sum+=$4; count++} END {print sum/count}'
echo ""

# 에러 통계
echo "⚠️  에러 통계:"
echo "- ERROR 수: $(grep -c ERROR $LOG_FILE)"
echo "- WARN 수: $(grep -c WARN $LOG_FILE)"
echo ""

# 치명적 에러 목록
echo "☠️  치명적 에러 (서버 종료 유발):"
grep "서버를 종료합니다" $LOG_FILE | awk -F'-' '{print $1}' | sort | uniq -c
```
</div>

---

## 🔧 문제 해결

### 일반적인 운영 이슈

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🚨 긴급 대응 가이드</h4>

| 증상 | 확인 사항 | 조치 방법 |
|------|-----------|-----------|
| **서버 자동 종료** | ERROR 로그 확인 | 원인 수정 후 재시작 |
| **API 키 오류** | 환경 변수 확인 | `.env` 파일 수정 |
| **프롬프트 오류** | config.json | 설정 파일 검증 |
| **메모리 부족** | 힙 사용량 | JVM 힙 크기 증가 |
| **디스크 풀** | 로그 크기 | 로그 정리/로테이션 |
| **큐 적체** | 큐 상태 | 서버 재시작 |
</div>

### 서버 재시작 절차

```bash
#!/bin/bash
# restart.sh - 안전한 서버 재시작

echo "🔄 서버 재시작 시작..."

# 1. 현재 큐 상태 확인
QUEUE_STATUS=$(curl -s http://localhost:8080/queue/status \
  -H "Authorization: $EROOM_PRIVATE_KEY")
echo "현재 큐 상태: $QUEUE_STATUS"

ACTIVE=$(echo $QUEUE_STATUS | jq '.active // 0')
if [ $ACTIVE -gt 0 ]; then
  echo "⚠️  처리 중인 작업이 있습니다. 완료를 기다립니다..."
  # 최대 10분 대기
  WAIT_TIME=0
  while [ $ACTIVE -gt 0 ] && [ $WAIT_TIME -lt 600 ]; do
    sleep 30
    WAIT_TIME=$((WAIT_TIME + 30))
    QUEUE_STATUS=$(curl -s http://localhost:8080/queue/status \
      -H "Authorization: $EROOM_PRIVATE_KEY")
    ACTIVE=$(echo $QUEUE_STATUS | jq '.active // 0')
  done
fi

# 2. 서버 종료
./scripts/stop.sh

# 3. 5초 대기
sleep 5

# 4. 서버 시작
./scripts/start.sh

# 5. 헬스체크
sleep 10
if curl -f http://localhost:8080/health \
  -H "Authorization: $EROOM_PRIVATE_KEY"; then
    echo "✅ 서버 재시작 완료!"
else
    echo "❌ 서버 시작 실패!"
    exit 1
fi
```

---

## 📈 장기 운영 전략

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎯 운영 최적화</h4>

1. **안정성 향상**
    - 자동 재시작 스크립트
    - 에러 패턴 분석 및 예방
    - 정기적인 설정 검증

2. **자동화 강화**
    - 로그 분석 자동화
    - 정기 백업 스케줄
    - 알림 시스템 구축

3. **모니터링 고도화**
    - Grafana 대시보드
    - Prometheus 메트릭
    - ELK 스택 도입

4. **에러 예방**
    - 환경 변수 사전 검증
    - 설정 파일 백업
    - API 키 만료 알림
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>효과적인 모니터링은 <strong>안정적인 서비스</strong>의 핵심입니다.</p>
</div>