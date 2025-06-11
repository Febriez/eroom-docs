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
  | **WARN** | 주의 필요 상황 | API 키 미설정, 타임아웃 발생 |
  | **ERROR** | 오류 발생 | AI API 실패, 파싱 오류 |
  | **DEBUG** | 상세 디버깅 | 요청/응답 상세, 처리 단계 |
</div>

### 주요 로그 패턴

```bash
# 서버 시작 확인
grep "서버가 성공적으로 시작되었습니다" logs/server.log

# API 요청 추적
grep "방 생성 요청" logs/server.log | tail -20

# 에러 모니터링
grep -E "(ERROR|Exception)" logs/server.log

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
  
  # 서버 상태
  echo "🟢 Server Status:"
  curl -s http://localhost:8080/health \
    -H "Authorization: $EROOM_PRIVATE_KEY" | jq
  
  echo ""
  
  # 시스템 리소스
  echo "💻 System Resources:"
  echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
  echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
  
  echo ""
  
  # 최근 에러
  echo "⚠️  Recent Errors (last 5):"
  grep ERROR logs/server.log | tail -5
  
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
  | **에러율** | < 2% | > 5% | 에러 로그 비율 |
  | **메모리 사용** | < 1GB | > 2GB | 시스템 모니터 |
</div>

---

## 🚨 알림 설정

### 로그 기반 알림

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔔 알림 스크립트</h4>
  
  ```bash
  #!/bin/bash
  # alert.sh - 에러 감지 및 알림
  
  LOG_FILE="logs/server.log"
  LAST_CHECK_FILE=".last_check"
  
  # 마지막 체크 시간 이후 에러 확인
  if [ -f "$LAST_CHECK_FILE" ]; then
      NEW_ERRORS=$(find "$LOG_FILE" -newer "$LAST_CHECK_FILE" \
        -exec grep -H "ERROR" {} \; | wc -l)
  else
      NEW_ERRORS=0
  fi
  
  # 에러 발견 시 알림
  if [ $NEW_ERRORS -gt 0 ]; then
      echo "🚨 새로운 에러 발견: $NEW_ERRORS 건"
      
      # 이메일 알림 (설정 필요)
      # echo "ERoom 서버 에러 발생" | mail -s "서버 알림" admin@example.com
      
      # 슬랙 알림 (웹훅 설정 필요)
      # curl -X POST -H 'Content-type: application/json' \
      #   --data '{"text":"서버 에러 발생!"}' \
      #   YOUR_SLACK_WEBHOOK_URL
  fi
  
  # 체크 시간 업데이트
  touch "$LAST_CHECK_FILE"
  ```
</div>

---

## 🛠️ 운영 작업

### 일상 운영 체크리스트

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📅 일일 점검 항목</h4>
  
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
  
  - [ ] **에러 로그 검토**
    ```bash
    grep -c ERROR logs/server.$(date +%Y-%m-%d).log
    ```
  
  - [ ] **큐 상태 확인**
    ```bash
    # 적체된 요청이 없는지 확인
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
  
  # 요청 통계
  echo "📊 요청 통계:"
  echo "- 총 룸 생성 요청: $(grep -c "방 생성 요청" $LOG_FILE)"
  echo "- 성공: $(grep -c "통합 방 생성 완료" $LOG_FILE)"
  echo "- 실패: $(grep -c "통합 방 생성 중.*오류" $LOG_FILE)"
  echo ""
  
  # 성능 통계
  echo "⚡ 성능 통계:"
  echo "- 평균 처리 시간: $(grep "통합 방 생성 완료" $LOG_FILE | \
    awk -F'[: ]' '{sum+=$NF; count++} END {print sum/count "분"}')"
  echo ""
  
  # 에러 통계
  echo "⚠️  에러 통계:"
  echo "- ERROR 수: $(grep -c ERROR $LOG_FILE)"
  echo "- WARN 수: $(grep -c WARN $LOG_FILE)"
  ```
</div>

---

## 🔧 문제 해결

### 일반적인 운영 이슈

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🚨 긴급 대응 가이드</h4>
  
  | 증상 | 확인 사항 | 조치 방법 |
  |------|-----------|-----------|
  | **서버 무응답** | 프로세스 상태 | 서버 재시작 |
  | **메모리 부족** | 힙 사용량 | JVM 힙 크기 증가 |
  | **디스크 풀** | 로그 크기 | 로그 정리/로테이션 |
  | **API 키 오류** | 환경 변수 | 키 재설정 |
  | **큐 적체** | 큐 상태 | 처리 스레드 확인 |
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

# 2. 진행 중인 작업 대기
echo "진행 중인 작업 완료 대기 (최대 5분)..."
sleep 300

# 3. 서버 종료
./scripts/stop.sh

# 4. 5초 대기
sleep 5

# 5. 서버 시작
./scripts/start.sh

# 6. 헬스체크
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
  
  1. **성능 튜닝**
     - JVM 파라미터 최적화
     - 동시 처리 수 조정
     - 캐싱 전략 도입
  
  2. **자동화 강화**
     - 자동 재시작 스크립트
     - 로그 분석 자동화
     - 정기 백업 스케줄
  
  3. **모니터링 고도화**
     - Grafana 대시보드
     - Prometheus 메트릭
     - ELK 스택 도입
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>효과적인 모니터링은 <strong>안정적인 서비스</strong>의 핵심입니다.</p>
</div>