# 7.1 서버 관련 이슈

## 🔧 서버 문제 해결 가이드

<div style="background: linear-gradient(135deg, #ff6b6b 0%, #ee5a24 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">ERoom 서버 트러블슈팅</h3>
  <p style="margin: 10px 0 0 0;">서버 운영 중 발생할 수 있는 주요 문제와 해결 방법</p>
</div>

---

## 🚨 일반적인 서버 문제

### 1. 서버 시작 실패

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">❌ 포트 바인딩 오류</h4>

**증상:**
```
java.net.BindException: Address already in use: bind
```

**원인:**
- 포트 8080이 이미 사용 중
- 이전 서버 인스턴스가 종료되지 않음

**해결 방법:**
```bash
# 포트 사용 확인 (Windows)
netstat -ano | findstr :8080

# 포트 사용 확인 (Linux/Mac)
lsof -i :8080

# 프로세스 종료
kill -9 <PID>

# 또는 다른 포트로 실행
java -jar eroom-server.jar 9090
```
</div>

### 2. 환경 변수 문제

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚠️ API 키 누락</h4>

**증상:**
```
Anthropic API 키가 설정되지 않았습니다. 서버를 종료합니다.
```

**원인:**
- 필수 환경 변수가 설정되지 않음
- 환경 변수명 오타

**해결 방법:**
```bash
# 필수 환경 변수 확인
echo $ANTHROPIC_KEY
echo $MESHY_KEY_1
echo $EROOM_PRIVATE_KEY

# 환경 변수 설정 (Linux/Mac)
export ANTHROPIC_KEY="sk-ant-api03-..."
export MESHY_KEY_1="your-meshy-key"
export EROOM_PRIVATE_KEY="your-api-key"

# 환경 변수 설정 (Windows)
set ANTHROPIC_KEY=sk-ant-api03-...
set MESHY_KEY_1=your-meshy-key
set EROOM_PRIVATE_KEY=your-api-key

# .env 파일 사용 (권장)
# .env 파일 생성 후:
source .env  # Linux/Mac
```

**주의사항:**
- API 키에 특수문자가 있으면 따옴표로 감싸기
- 환경 변수는 서버 시작 전에 설정해야 함
- MESHY_KEY_2, MESHY_KEY_3는 선택사항
</div>

### 3. 메모리 부족

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">💾 OutOfMemoryError</h4>

**증상:**
```
java.lang.OutOfMemoryError: Java heap space
```

**원인:**
- 기본 힙 메모리 부족
- 동시 요청 과다
- 메모리 누수

**해결 방법:**
```bash
# 힙 메모리 증가
java -Xms1g -Xmx2g -jar eroom-server.jar

# 권장 설정
java -Xms512m -Xmx2g \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -jar eroom-server.jar

# 메모리 사용량 모니터링
jstat -gc <PID> 1000
```
</div>

---

## 🔍 API 관련 문제

### 4. 인증 실패

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔒 401 Unauthorized</h4>

**증상:**
```json
{
  "error": "인증이 필요합니다"
}
```

**원인:**
- Authorization 헤더 누락
- 잘못된 API 키
- API 키 환경 변수 미설정

**해결 방법:**
```bash
# 서버 로그에서 API 키 확인
# EROOM_PRIVATE_KEY가 설정되지 않으면 자동 생성됨
grep "API 키가 설정되었습니다" server.log

# 올바른 헤더 사용
curl http://localhost:8080/health \
  -H "Authorization: correct-api-key"

# 환경 변수 재설정
export EROOM_PRIVATE_KEY="new-secure-key"
# 서버 재시작 필요
```
</div>

### 5. 요청 검증 실패

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">✋ 400 Bad Request</h4>

**일반적인 검증 오류:**

| 오류 메시지 | 원인 | 해결 방법 |
|------------|------|-----------|
| "UUID가 비어있습니다" | uuid 필드 누락 또는 빈 문자열 | uuid 필드 추가 |
| "테마가 비어있습니다" | theme 필드 누락 또는 공백 | 유효한 테마 입력 |
| "키워드가 비어있습니다" | keywords 배열 누락 또는 빈 배열 | 최소 1개 키워드 추가 |
| "빈 키워드가 포함되어 있습니다" | keywords 배열에 빈 문자열 | 모든 키워드 확인 |
| "유효하지 않은 난이도입니다" | difficulty가 easy/normal/hard가 아님 | 올바른 난이도 선택 |
| "유효하지 않은 roomPrefab URL 형식입니다" | URL이 https://로 시작하지 않음 | https:// URL 사용 |

**검증 통과 예시:**
```json
{
  "uuid": "user_12345",
  "theme": "우주 정거장",
  "keywords": ["SF", "퍼즐", "생존"],
  "difficulty": "normal",
  "room_prefab": "https://example.com/space.fbx"
}
```
</div>

---

## 🔄 큐 및 처리 문제

### 6. 큐 정체

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🚦 처리 지연</h4>

**증상:**
- 요청이 QUEUED 상태에서 오래 대기
- active가 항상 1이고 queued가 계속 증가

**원인:**
- maxConcurrentRequests = 1로 설정됨
- AI API 응답 지연
- 이전 요청이 타임아웃되지 않음

**모니터링:**
```bash
# 큐 상태 확인
curl http://localhost:8080/queue/status \
  -H "Authorization: your-api-key"

# 응답 예시
{
  "queued": 15,
  "active": 1,
  "completed": 100,
  "maxConcurrent": 1
}
```

**해결 방법:**
- 현재는 안정성을 위해 동시 처리 1개로 제한
- 향후 버전에서 동시 처리 수 증가 예정
- 긴급한 경우 서버 재시작으로 큐 초기화
</div>

### 7. 처리 실패

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">❌ 생성 실패</h4>

**일반적인 실패 원인:**

| 단계 | 오류 메시지 | 원인 | 해결 방법 |
|------|------------|------|-----------|
| **시나리오** | "통합 시나리오 생성 실패" | Claude API 오류 | API 키 확인, 재시도 |
| **시나리오** | "JSON 파싱 실패" | Claude 응답 형식 오류 | 프롬프트 확인, 로그 분석 |
| **스크립트** | "통합 스크립트 생성 실패" | 스크립트 파싱 오류 | 시나리오 데이터 확인 |
| **모델** | "error-preview-*" | Meshy 프리뷰 생성 실패 | Meshy API 키 확인 |
| **모델** | "timeout-preview-*" | 모델 생성 타임아웃 | 5분 후 재시도 |

**실패 응답 예시:**
```json
{
  "uuid": "user_12345",
  "ruid": "room_abc123",
  "success": false,
  "error": "통합 시나리오 생성 단계에서 오류 발생: JSON 파싱 실패",
  "timestamp": "1718123456789"
}
```
</div>

---

## 📊 성능 문제

### 8. 느린 응답 속도

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🐌 성능 저하</h4>

**증상:**
- API 응답 시간 증가
- 타임아웃 발생
- 전체적인 처리 속도 저하

**진단:**
```bash
# JVM 상태 확인
jstack <PID> > thread_dump.txt

# CPU 사용률 확인
top -p <PID>

# 네트워크 지연 확인
ping api.anthropic.com
ping api.meshy.ai
```

**최적화 방법:**
1. **JVM 튜닝**
   ```bash
   java -server \
        -XX:+UseG1GC \
        -XX:MaxGCPauseMillis=200 \
        -XX:+ParallelRefProcEnabled \
        -jar eroom-server.jar
   ```

2. **연결 풀 최적화**
    - OkHttpClient는 기본적으로 연결 재사용
    - 타임아웃 설정 확인 (30초)

3. **로그 레벨 조정**
   ```bash
   # 프로덕션에서는 INFO 레벨 권장
   java -Dlogback.configurationFile=logback-prod.xml -jar eroom-server.jar
   ```
</div>

---

## 🐛 디버깅 팁

### 9. 로그 분석

<div style="background: #f0f0f0; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📝 효과적인 로그 활용</h4>

**주요 로그 패턴:**

```bash
# 요청 추적
grep "ruid: room_" server.log

# 에러 추적
grep "ERROR" server.log

# AI 서비스 추적
grep "통합 시나리오\|통합 스크립트\|모델 생성" server.log

# 큐 상태 추적
grep "큐에 추가됨\|큐에서 요청 추출됨" server.log
```

**구조화된 로그 예시:**
```
[INFO] === 요청 제출 상세 정보 ===
[INFO] RUID: room_abc123
[INFO] User UUID: user_12345
[INFO] Theme: '우주 정거장'
[INFO] Keywords: SF, 퍼즐, 생존
[INFO] Difficulty: 'normal'
[INFO] Room Prefab: 'https://example.com/space.fbx'
```

**디버그 모드 활성화:**
```bash
# 상세 로그 출력
java -Dlog.level=DEBUG -jar eroom-server.jar
```
</div>

---

## 🚨 긴급 대응

### 10. 서버 행 (Hang) 현상

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🆘 서버 무응답</h4>

**증상:**
- 모든 API 요청 무응답
- 큐 처리 중단
- 로그 출력 없음

**긴급 조치:**
```bash
# 1. 스레드 덤프 생성
jstack <PID> > thread_dump_$(date +%Y%m%d_%H%M%S).txt

# 2. 힙 덤프 생성 (메모리 분석용)
jmap -dump:format=b,file=heap_dump.hprof <PID>

# 3. 강제 종료
kill -9 <PID>

# 4. 서버 재시작
java -jar eroom-server.jar

# 5. 로그 백업
cp server.log server.log.backup_$(date +%Y%m%d_%H%M%S)
```

**예방 조치:**
- 정기적인 헬스체크 모니터링
- 자동 재시작 스크립트 구성
- 리소스 사용량 알림 설정
</div>

---

## 📋 체크리스트

### 서버 운영 체크리스트

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">

**일일 점검 항목:**
- [ ] 서버 헬스체크 API 응답 확인
- [ ] 큐 상태 모니터링 (queued < 10)
- [ ] 에러 로그 확인
- [ ] 디스크 공간 확인 (로그 파일)

**주간 점검 항목:**
- [ ] 성공률 통계 확인
- [ ] 평균 처리 시간 분석
- [ ] API 키 로테이션 검토
- [ ] 로그 파일 아카이빙

**문제 발생 시:**
1. 로그 확인
2. 큐 상태 확인
3. 환경 변수 확인
4. 외부 API 상태 확인
5. 서버 재시작 (최후 수단)
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>추가 지원이 필요하시면 개발팀에 문의해주세요.</p>
  <p>더 많은 정보는 <a href="../api-reference/rest-api-spec.md">API 문서</a>를 참조하세요.</p>
</div>