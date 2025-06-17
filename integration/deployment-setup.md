# 5.2 배포 환경 구성

## 🚀 배포 환경 개요

<div style="background: linear-gradient(to right, #f093fb 0%, #f5576c 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">로컬 Java 서버 + Firebase Firestore</h3>
  <p style="margin: 10px 0 0 0;">간단하면서도 확장 가능한 하이브리드 아키텍처</p>
</div>

---

## 🏗️ 아키텍처 구성

### 시스템 구성도

{% mermaid %}
graph TB
subgraph "Client Side"
U[Unity Client]
W[Web Dashboard]
end

    subgraph "Server Side (로컬)"
        S[Java Server :8080]
        C[Config Files]
        L[Log Files]
    end
    
    subgraph "Cloud Services"
        F[(Firebase Firestore)]
        A[Anthropic API]
        M[Meshy API]
    end
    
    U --> S
    W --> S
    S --> A
    S --> M
    U -.-> F
    W -.-> F
    
    style S fill:#4a90e2
    style F fill:#f39c12
{% endmermaid %}

---

## 💾 Firebase Firestore 선택 이유

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔥 Firestore의 장점</h4>

| 특징           | 설명          | ERoom에서의 활용     |
  |--------------|-------------|-----------------|
| **실시간 동기화**  | 자동 데이터 동기화  | 클라이언트 간 즉시 업데이트 |
| **오프라인 지원**  | 로컬 캐시 자동 관리 | 네트워크 없이도 게임 가능  |
| **자동 확장**    | 무제한 확장성     | 사용자 증가 대응       |
| **NoSQL 구조** | 유연한 스키마     | 다양한 게임 데이터 저장   |
| **보안 규칙**    | 세밀한 권한 제어   | 사용자별 데이터 보호     |
| **무료 티어**    | 충분한 무료 사용량  | 초기 비용 절감        |
</div>

### Firestore 데이터 구조

```javascript
// Firestore 컬렉션 구조
firestore/
├── users/
│   └── {uuid}/
│       ├── profile: {
│       │   name: "사용자명",
│       │   createdAt: timestamp,
│       │   totalRooms: 15
│       │   }
│       └── rooms/
│           └── {ruid}/
│               ├── metadata: {
│               │   theme: "우주정거장",
│               │   difficulty: "normal",
│               │   createdAt: timestamp,
│               │   completedAt: timestamp
│               │   }
│               ├── scenario: { ... }
│               ├── scripts: { ... }
│               └── models: { ... }
└── statistics/
    ├── daily/
    │   └── {date}/
    │       └── { totalRooms, totalUsers, ... }
    └── global/
        └── { totalRooms, popularThemes, ... }
```

---

## 🖥️ 로컬 서버 환경 설정

### 시스템 요구사항

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">💻 하드웨어 요구사항</h4>

| 구성 | 최소 사양 | 권장 사양 |
  |------|-----------|-----------|
| **CPU** | 2 Core | 4 Core 이상 |
| **RAM** | 4GB | 8GB 이상 |
| **저장공간** | 10GB | 50GB SSD |
| **네트워크** | 10Mbps | 100Mbps 이상 |
| **OS** | Windows 10 / Ubuntu 20.04 | 최신 버전 |
</div>

### Java 환경 구성

```bash
# Java 17 설치 확인
java -version
# 출력: openjdk version "17.0.x"

# 환경 변수 설정 (Linux/Mac)
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# 환경 변수 설정 (Windows)
setx JAVA_HOME "C:\Program Files\Java\jdk-17"
setx PATH "%JAVA_HOME%\bin;%PATH%"
```

---

## 🔧 서버 설정 파일

### 환경별 설정 관리

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚙️ 설정 파일 구조</h4>

```
eroom-server/
├── config/
│   ├── config.json          # 기본 설정
│   ├── config.dev.json      # 개발 환경
│   └── config.prod.json     # 운영 환경
├── logs/
│   ├── server.log           # 일반 로그
│   └── error.log            # 에러 로그
└── scripts/
    ├── start.sh             # 서버 시작
    └── stop.sh              # 서버 종료
```
</div>

### config.json 설정

```json
{
  "model": {
    "name": "claude-sonnet-4-20250514",
    "maxTokens": 16000,
    "scenarioTemperature": 0.9,
    "scriptTemperature": 0.1
  },
  "prompts": {
    "scenario": "Unity6 escape room scenario generator focused on engaging puzzle design using Unity6-specific features. INPUT: uuid (string), puid (string), theme (string), keywords (array), difficulty (easy/normal/hard), room_prefab_url (string containing accessible prefab data). KEYWORD EXPANSION: If provided keywords are insufficient for difficulty requirements, automatically generate additional theme-appropriate keywords to meet object count. OBJECT COUNT: Create interactive objects based on difficulty - Easy: 4-5 objects, Normal: 5-7 objects, Hard: 7-9 objects (GameManager excluded from count). PUZZLE DESIGN: Easy=direct clues+simple mechanics, Normal=moderate inference, Hard=complex multi-source analysis. Create logical progression with satisfying solutions. INTERACTION CONSTRAINTS: ONLY physical interactions - movement, rotation, opening/closing, item combination. FORBIDDEN: visual effects, lighting changes, color changes, transparency, glowing, particle systems, animations, audio. TECHNICAL REQUIREMENTS: Unity6 components only (BoxCollider, SphereCollider, CapsuleCollider, MeshCollider, Rigidbody, UI elements). LANGUAGE: Korean for failure_feedback and hint_messages (mysterious escape room atmosphere), English for all other values. NAMING: C# PascalCase for all object names (avoid C# reserved keywords like 'object', 'string', 'class', 'public', 'private', 'static', 'void', 'int', 'bool', 'float', 'return', 'if', 'else', 'for', 'while'). JSON STRUCTURE: {\"scenario_data\":{\"theme\":\"string\",\"difficulty\":\"string\",\"description\":\"string\",\"escape_condition\":\"string\",\"puzzle_flow\":\"string\"},\"object_instructions\":[{\"name\":\"GameManager\",\"type\":\"game_manager\",\"functional_description\":\"Singleton GameManager with: Dictionary<string,GameObject> registeredObjects, Dictionary<string,bool> puzzleStates, inventory system (Dictionary<string,int> quantities + Dictionary<string,bool> flags), dependency validation, state monitoring, victory condition checking\"},{\"name\":\"ObjectName\",\"type\":\"interactive_object\",\"visual_description\":\"Physical appearance for 3D modeling (no state changes)\",\"interaction_method\":\"left_click, right_click, e_key, f_key, arrow_keys, number_keys, wasd_keys, or combinations\",\"functional_description\":\"State management, interaction sequences, validation, inventory logic, dependencies, GameManager integration, error handling, H-key hints\",\"placement_suggestion\":\"Room location context\",\"puzzle_role\":\"Progression role\",\"dependencies\":\"Required states/items (comma-separated)\",\"success_outcome\":\"States to set, items to add\",\"failure_feedback\":\"Korean atmospheric messages\",\"hint_messages\":\"Array of 5-10 mysterious Korean phrases\"}]}. MANDATORY: First object must be GameManager with type 'game_manager'. Output valid JSON only.",
    "unified_scripts": "Unity6 C# script generator for escape room puzzle objects using Unity6-specific APIs and components. INPUT: scenario JSON with object_instructions array. CRITICAL REQUIREMENT: The first object in object_instructions array MUST be GameManager with type='game_manager' - generate its script FIRST and ALWAYS include it in output. UNITY6 FEATURES: Use Unity6 InputSystem, GameObject.FindAnyObjectByType<T>() instead of FindObjectOfType, Unity6 UI Toolkit when applicable. COMPONENTS ALLOWED: BoxCollider, SphereCollider, CapsuleCollider, MeshCollider, Rigidbody, UI elements (Text, Button, InputField). FORBIDDEN: ParticleSystem, AudioSource, Animator, Light, Renderer material changes. MANDATORY PROCESSING ORDER: 1. Generate GameManager script from object_instructions[0] (always type='game_manager') 2. Generate scripts for remaining objects with type='interactive_object' in sequence. OUTPUT FORMAT: Start with GameManager script (no separator), then add '===ScriptName:::' separator before each subsequent script. NEVER skip GameManager - it must always be the first script in output. GAMEMANAGER REQUIREMENTS: Must include public static GameManager Instance (singleton pattern), public bool room_clear=false, Dictionary<string,bool> puzzleStates=new(), Dictionary<string,GameObject> registeredObjects=new(), Dictionary<string,int> inventoryQuantity=new(), Dictionary<string,bool> inventoryBool=new(), public void ShowPlayerHint(string message), public void ShowRandomHint(string[] hints), public void RegisterObject(string name, GameObject obj), public bool GetPuzzleState(string key), public void SetPuzzleState(string key, bool value), public void CheckVictoryCondition(), public bool HasInventoryItem(string item), public void AddInventoryItem(string item, int amount=1), public bool ConsumeInventoryItem(string item, int amount=1), public bool ValidateDependencies(string[] deps). OBJECT SCRIPT REQUIREMENTS: public bool isSelected=false for selection system, Register with GameManager in Start() using RegisterObject, Unity6 InputSystem integration, Korean Debug.Log messages, H-key hint system with public string[] randomHints from hint_messages, public string[] dependencies, left_click for selection toggle + interaction_method for primary actions, proper state management and GameManager integration. REQUIRED IMPORTS: using UnityEngine; using UnityEngine.InputSystem; using System.Collections; using System.Collections.Generic; CODE STYLE: Clean, efficient, no redundant methods, use 'var' for local variables, PascalCase for classes/methods, Unity6 best practices, proper error handling."
  }
}
```

### 시작 스크립트 (start.sh)

```bash
#!/bin/bash

# 환경 변수 로드
source .env

# JVM 옵션 설정
JVM_OPTS="-Xms512m -Xmx2g -XX:+UseG1GC"

# 로그 디렉토리 생성
mkdir -p logs

# 서버 시작
java $JVM_OPTS -jar eroom-server.jar \
  --config=config/config.json \
  >> logs/server.log 2>&1 &

# PID 저장
echo $! > server.pid

echo "Server started with PID: $(cat server.pid)"
```

---

## 🌐 네트워크 구성

### 포트 설정

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔌 포트 구성</h4>

| 포트 | 용도 | 설정 |
  |------|------|------|
| **8080** | HTTP API | 기본 서버 포트 |
| **8443** | HTTPS API | SSL 적용 시 |
| **9090** | 모니터링 | Metrics 엔드포인트 |

**방화벽 설정:**
  ```bash
  # Ubuntu/Debian
  sudo ufw allow 8080/tcp
  sudo ufw allow 8443/tcp
  
  # CentOS/RHEL
  sudo firewall-cmd --add-port=8080/tcp --permanent
  sudo firewall-cmd --reload
  
  # Windows
  netsh advfirewall firewall add rule name="ERoom Server" \
    dir=in action=allow protocol=TCP localport=8080
  ```
</div>

---

## 🔑 환경 변수 설정

### 필수 환경 변수

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔐 API 키 설정</h4>

**.env 파일 예제:**
```bash
# 서버 인증
EROOM_PRIVATE_KEY=your-secure-api-key

# AI 서비스
ANTHROPIC_KEY=sk-ant-api03-xxxxx

# 3D 모델 생성 (최소 1개 필수)
MESHY_KEY_1=your-meshy-key-1
MESHY_KEY_2=your-meshy-key-2
MESHY_KEY_3=your-meshy-key-3
```

**주의사항:**
- `.env` 파일은 반드시 `.gitignore`에 추가
- 프로덕션에서는 환경 변수 직접 설정 권장
- API 키는 절대 공개 저장소에 커밋하지 않음
</div>

---

## 📊 로깅 및 모니터링

### 로그 설정

```xml
<!-- logback.xml -->
<configuration>
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/server.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/server.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="FILE" />
    </root>
</configuration>
```

### 모니터링 대시보드

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e3f2fd; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>시스템 리소스</h4>
    <p>CPU, 메모리 사용률</p>
    <code>htop / Task Manager</code>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>API 메트릭</h4>
    <p>요청 수, 응답 시간</p>
    <code>/health 엔드포인트</code>
  </div>
  <div style="background: #f3e5f5; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>로그 분석</h4>
    <p>에러율, 경고 추적</p>
    <code>tail -f logs/*.log</code>
  </div>
</div>

---

## 🔒 보안 설정

### 프로덕션 보안 체크리스트

<div style="background: #ffcdd2; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🛡️ 필수 보안 설정</h4>

- [ ] **환경 변수 보호**
  ```bash
  # .env 파일 권한 설정
  chmod 600 .env
  ```

- [ ] **API 키 로테이션**
    - 주기적 키 변경
    - 이전 키 만료 처리

- [ ] **접근 제어**
    - IP 화이트리스트
    - Rate Limiting (향후 구현)

- [ ] **로그 보안**
    - 민감 정보 마스킹
    - 로그 파일 권한 제한

- [ ] **HTTPS 설정** (프로덕션)
    - SSL 인증서 설치
    - HTTP → HTTPS 리다이렉트
</div>

---

## 🚦 배포 프로세스

### 배포 단계

{% mermaid %}
flowchart LR
A[코드 준비] --> B[환경 설정]
B --> C[빌드]
C --> D[테스트]
D --> E[배포]
E --> F[검증]
F --> G[모니터링]

    style E fill:#4caf50
    style F fill:#ff9800
{% endmermaid %}

### 배포 스크립트

```bash
#!/bin/bash
# deploy.sh

echo "🚀 ERoom Server 배포 시작..."

# 1. 기존 서버 종료
./scripts/stop.sh

# 2. 백업
cp eroom-server.jar backup/eroom-server-$(date +%Y%m%d).jar

# 3. 새 버전 배포
cp target/eroom-server.jar .

# 4. 설정 검증
java -jar eroom-server.jar --validate-config

# 5. 서버 시작
./scripts/start.sh

# 6. 헬스체크
sleep 10
curl -f http://localhost:8080/health \
  -H "Authorization: $EROOM_PRIVATE_KEY" || exit 1

echo "✅ 배포 완료!"
```

---

## 📈 확장 계획

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔮 향후 확장 옵션</h4>

1. **수직 확장**
    - 서버 스펙 업그레이드
    - JVM 힙 크기 증가
    - 동시 처리 수 증가

2. **수평 확장**
    - 다중 서버 인스턴스
    - 로드 밸런서 추가
    - Redis 큐 도입

3. **클라우드 이전**
    - AWS/GCP 마이그레이션
    - Kubernetes 오케스트레이션
    - 자동 스케일링
</div>

---

## 🔧 문제 해결

### 일반적인 배포 이슈

| 문제 | 원인 | 해결 방법 |
|------|------|-----------|
| 서버 시작 실패 | 포트 사용 중 | `lsof -i :8080` 확인 |
| API 키 오류 | 환경 변수 미설정 | `.env` 파일 확인 |
| 메모리 부족 | JVM 힙 부족 | `-Xmx` 값 증가 |
| 로그 없음 | 권한 문제 | `logs` 디렉토리 권한 확인 |

---

<div style="background: #f0f0f0; padding: 20px; border-radius: 10px; margin-top: 30px; text-align: center;">
  <p style="margin: 0;">
    로컬 서버와 클라우드 서비스의 조합은 <strong>유연성</strong>과 <strong>비용 효율성</strong>을 제공합니다.
  </p>
</div>