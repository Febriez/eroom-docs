# 5.1 시스템 통합

## 🔄 시스템 통합 개요

<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">End-to-End 통합 검증</h3>
  <p style="margin: 10px 0 0 0;">서버와 Unity를 연결하여 완전한 방탈출 생성 시스템 구축</p>
</div>

---

## 🎯 통합 테스트 체크리스트

### 1️⃣ **서버 준비 단계**

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">✅ 서버 설정 확인</h4>

- [ ] 환경 변수 설정 완료
  ```bash
  # 필수 환경 변수
  export ANTHROPIC_KEY=sk-ant-api03-...
  export MESHY_KEY_1=...
  export MESHY_KEY_2=...  # 선택
  export MESHY_KEY_3=...  # 선택
  export EROOM_PRIVATE_KEY=your-secure-key
  ```

- [ ] config.json 검증
  ```json
  {
    "model": {
      "name": "claude-sonnet-4-20250514",
      "maxTokens": 16000,
      "scenarioTemperature": 0.9,
      "scriptTemperature": 0.1
    }
  }
  ```

- [ ] 서버 포트 8080 사용 가능
- [ ] 로그 디렉토리 생성 (`logs/`)

- [ ] 서버 시작 및 헬스체크
  ```bash
  java -jar eroom-server.jar
  
  # 다른 터미널에서
  curl http://localhost:8080/health \
    -H "Authorization: your-secure-key"
  ```
</div>

### 2️⃣ **Unity 클라이언트 준비**

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎮 Unity 설정</h4>

- [ ] Unity 2022.3 LTS 이상
- [ ] Input System Package 설치
- [ ] JSON 처리 라이브러리 준비
- [ ] API 클라이언트 스크립트 통합
- [ ] 테스트 씬 구성
</div>

---

## 🔗 JSON HTTP 통신 검증

### 요청/응답 포맷 확인

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📡 통신 프로토콜 테스트</h4>

**1. 룸 생성 요청 테스트**
```bash
curl -X POST http://localhost:8080/room/create \
  -H "Authorization: your-secure-key" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{
    "uuid": "test_user_001",
    "theme": "미래 우주정거장",
    "keywords": ["SF", "퍼즐", "생존"],
    "difficulty": "normal",
    "room_prefab": "https://example.com/space_station.fbx"
  }'
```

**예상 응답:**
```json
{
  "ruid": "room_a1b2c3d4e5f6",
  "status": "대기중",
  "message": "방 생성 요청이 수락되었습니다. 상태 확인을 위해 /room/result?ruid=room_a1b2c3d4e5f6를 폴링하세요.",
  "success": true
}
```

**2. 결과 조회 테스트**
```bash
curl "http://localhost:8080/room/result?ruid=room_a1b2c3d4e5f6" \
  -H "Authorization: your-secure-key"
```
</div>

---

## 🔄 통합 테스트 시나리오

### 전체 플로우 테스트

{% mermaid %}
graph LR
A[Unity 시작] --> B[API 키 설정]
B --> C[룸 생성 요청]
C --> D[ruid 수신]
D --> E[폴링 시작]
E --> F{상태 확인}
F -->|처리중| E
F -->|완료| G[데이터 수신]
G --> H[스크립트 디코딩]
H --> I[3D 모델 정보 확인]
I --> J[게임 씬 구성]

    style C fill:#4a90e2
    style G fill:#4caf50
    style J fill:#f39c12
{% endmermaid %}

---

## 📊 성능 검증

### 응답 시간 측정

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⏱️ 단계별 소요 시간</h4>

| 단계        | 목표 시간    | 허용 범위   | 측정 방법      |
  |-----------|----------|---------|------------|
| API 인증    | < 5ms    | 10ms    | 헤더 검증 시간   |
| 요청 파싱     | < 10ms   | 20ms    | JSON 변환 시간 |
| 큐 등록      | < 50ms   | 100ms   | 응답 반환까지    |
| 시나리오 생성   | ~60초     | 90초     | AI 처리 시간   |
| 스크립트 생성   | ~20초     | 30초     | AI 처리 시간   |
| 3D 모델 생성  | 5-8분     | 10분     | Meshy API  |
| **전체 생성** | **5-8분** | **10분** | 시작부터 완료까지  |

**부하 테스트:**
```bash
# 동시 요청 테스트 (현재 동시 처리 1개로 제한)
for i in {1..5}; do
  curl -X POST http://localhost:8080/room/create \
    -H "Authorization: your-secure-key" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d '{"uuid":"user_'$i'", "theme":"테스트", "keywords":["test"], "room_prefab":"https://example.com/test.fbx"}' &
done

# 큐 상태 확인
curl http://localhost:8080/queue/status \
  -H "Authorization: your-secure-key"
```
</div>

---

## 🛡️ 보안 검증

### 통신 보안 체크

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔐 보안 항목 검증</h4>

- [ ] **API Key 검증**
    - 잘못된 키로 요청 시 401 응답
    - 키 누락 시 적절한 에러 메시지
    - 환경 변수 미설정 시 자동 생성 키 사용

- [ ] **입력 검증**
    - SQL Injection 방지 (NoSQL 사용)
    - XSS 공격 방지 (HTML 렌더링 없음)
    - URL 형식 검증
    - 난이도 값 검증

- [ ] **HTTPS 준비** (프로덕션)
    - SSL 인증서 설정
    - 암호화 통신 확인
</div>

---

## 🔍 데이터 검증

### 생성된 콘텐츠 품질 확인

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">✨ 콘텐츠 검증 항목</h4>

**1. 시나리오 검증**
- [ ] 테마와 키워드 반영도
- [ ] 난이도별 퍼즐 개수 (Easy: 4-5, Normal: 5-7, Hard: 7-9)
- [ ] 스토리 일관성
- [ ] 탈출 조건 명확성
- [ ] GameManager가 첫 번째 오브젝트

**2. 스크립트 검증**
- [ ] 문법 오류 없음
- [ ] Unity6 API 사용
- [ ] 필수 using 문 포함
- [ ] GameManager 스크립트 포함
- [ ] 상호작용 로직 완성도

**3. 3D 모델 추적**
- [ ] 모든 오브젝트의 tracking ID
- [ ] 실패한 모델 별도 표시
- [ ] URL 형식 또는 res_ ID 형식
</div>

---

## 📈 통합 모니터링

### 실시간 모니터링 설정

```bash
# 서버 로그 모니터링
tail -f logs/server.log | grep -E "(INFO|WARN|ERROR)"

# 큐 상태 실시간 확인
watch -n 1 'curl -s http://localhost:8080/queue/status \
  -H "Authorization: your-secure-key" | jq'

# 시스템 리소스 모니터링
htop

# 서버 프로세스 확인 (ERROR 발생 시 자동 종료됨)
watch -n 5 'ps aux | grep eroom-server.jar'
```

### 주요 지표

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e3f2fd; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>큐 처리량</h4>
    <p>대기/처리중/완료</p>
    <code>실시간 추적</code>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>API 응답 시간</h4>
    <p>평균 < 100ms</p>
    <code>성능 지표</code>
  </div>
  <div style="background: #f3e5f5; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>서버 가동률</h4>
    <p>자동 종료 감지</p>
    <code>안정성 지표</code>
  </div>
</div>

---

## 🐛 통합 문제 해결

### 일반적인 통합 이슈

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚠️ 문제 해결 가이드</h4>

| 문제             | 원인        | 해결 방법              |
  |----------------|-----------|--------------------|
| **연결 실패**      | 서버 미실행    | 서버 상태 확인           |
| **401 오류**     | API 키 불일치 | 환경 변수 확인           |
| **서버 자동 종료**   | 치명적 에러 발생 | ERROR 로그 확인        |
| **JSON 파싱 실패** | 형식 오류     | Content-Type 헤더 확인 |
| **타임아웃**       | 네트워크 지연   | 폴링 간격 조정           |
| **스크립트 오류**    | 디코딩 실패    | Base64 인코딩 확인      |
</div>

### 서버 종료 원인 (ERROR 발생 시)

```bash
# 서버 종료를 유발하는 치명적 에러들
- Anthropic API 키가 설정되지 않았습니다
- 프롬프트 설정을 찾을 수 없습니다
- 설정 파일을 찾을 수 없습니다
- JSON 파싱 실패
- 시나리오 생성 응답이 비어있습니다
- Base64 인코딩 실패
```

---

## ✅ 통합 완료 기준

### 최종 검증 체크리스트

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎯 통합 성공 기준</h4>

- [ ] **기능 완성도**
    - 룸 생성 요청 → 결과 수신까지 전체 플로우 동작
    - 모든 난이도에서 정상 작동
    - 다양한 테마 테스트 완료

- [ ] **성능 달성**
    - 평균 처리 시간 8분 이내
    - API 응답 시간 100ms 이내
    - 큐 시스템 정상 작동

- [ ] **안정성 확보**
    - 24시간 연속 운영 테스트
    - 서버 자동 종료 없음
    - 메모리 누수 없음

- [ ] **보안 검증**
    - API 키 인증 동작
    - 입력 검증 완료
    - 에러 메시지 안전성
</div>

---

## 🚀 다음 단계

### 프로덕션 준비

1. **스케일링 계획**
    - 동시 처리 수 증가
    - 다중 서버 인스턴스
    - 로드 밸런서 구성

2. **모니터링 강화**
    - 자동 재시작 스크립트
    - 알림 시스템 구축
    - 대시보드 구성

3. **백업 및 복구**
    - 설정 파일 백업
    - 로그 아카이빙
    - 장애 복구 계획

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>시스템 통합은 <strong>품질</strong>과 <strong>안정성</strong>을 보장하는 핵심 단계입니다.</p>
</div>