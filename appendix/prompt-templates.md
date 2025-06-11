# 8.1 프롬프트 템플릿

## 🧠 프롬프트 엔지니어링 개요

<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 15px; color: white; margin: 20px 0;">
  <h3 style="margin: 0;">최적화된 AI 프롬프트 설계</h3>
  <p style="margin: 10px 0 0 0;">Claude AI의 성능을 최대한 이끌어내는 정교한 프롬프트 구조</p>
</div>

---

## 📝 시나리오 생성 프롬프트

### 전체 프롬프트 구조

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎭 Scenario Generation Prompt</h4>
  
  ```
  Unity6 escape room scenario generator focused on engaging puzzle design using Unity6-specific features. 
  
  INPUT: uuid (string), puid (string), theme (string), keywords (array), difficulty (easy/normal/hard), 
  room_prefab_url (string containing accessible prefab data). 
  
  KEYWORD EXPANSION: If provided keywords are insufficient for difficulty requirements, 
  automatically generate additional theme-appropriate keywords to meet object count. 
  
  OBJECT COUNT: Create interactive objects based on difficulty - 
  Easy: 4-5 objects, Normal: 5-7 objects, Hard: 7-9 objects (GameManager excluded from count). 
  
  PUZZLE DESIGN: Easy=direct clues+simple mechanics, Normal=moderate inference, 
  Hard=complex multi-source analysis. Create logical progression with satisfying solutions. 
  
  INTERACTION CONSTRAINTS: ONLY physical interactions - movement, rotation, opening/closing, 
  item combination. FORBIDDEN: visual effects, lighting changes, color changes, transparency, 
  glowing, particle systems, animations, audio. 
  
  TECHNICAL REQUIREMENTS: Unity6 components only (BoxCollider, SphereCollider, CapsuleCollider, 
  MeshCollider, Rigidbody, UI elements). 
  
  LANGUAGE: Korean for failure_feedback and hint_messages (mysterious escape room atmosphere), 
  English for all other values. 
  
  NAMING: C# PascalCase for all object names (avoid C# reserved keywords like 'object', 
  'string', 'class', 'public', 'private', 'static', 'void', 'int', 'bool', 'float', 
  'return', 'if', 'else', 'for', 'while'). 
  
  JSON STRUCTURE: {
    "scenario_data": {
      "theme": "string",
      "difficulty": "string",
      "description": "string",
      "escape_condition": "string",
      "puzzle_flow": "string"
    },
    "object_instructions": [
      {
        "name": "GameManager",
        "type": "game_manager",
        "functional_description": "Singleton GameManager with: Dictionary<string,GameObject> registeredObjects, 
        Dictionary<string,bool> puzzleStates, inventory system (Dictionary<string,int> quantities + 
        Dictionary<string,bool> flags), dependency validation, state monitoring, victory condition checking"
      },
      {
        "name": "ObjectName",
        "type": "interactive_object",
        "visual_description": "Physical appearance for 3D modeling (no state changes)",
        "interaction_method": "left_click, right_click, e_key, f_key, arrow_keys, number_keys, 
        wasd_keys, or combinations",
        "functional_description": "State management, interaction sequences, validation, inventory logic, 
        dependencies, GameManager integration, error handling, H-key hints",
        "placement_suggestion": "Room location context",
        "puzzle_role": "Progression role",
        "dependencies": "Required states/items (comma-separated)",
        "success_outcome": "States to set, items to add",
        "failure_feedback": "Korean atmospheric messages",
        "hint_messages": "Array of 5-10 mysterious Korean phrases"
      }
    ]
  }. 
  
  MANDATORY: First object must be GameManager with type 'game_manager'. Output valid JSON only.
  ```
</div>

### 프롬프트 구조 분석

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🔍 각 구성 요소의 역할</h4>
  
  | 구성 요소 | 목적 | 유도하는 결과 |
  |-----------|------|---------------|
  | **Unity6 specific** | 최신 엔진 기능 활용 | 현대적인 게임 메커니즘 |
  | **INPUT 정의** | 명확한 입력 형식 | 일관된 요청 처리 |
  | **KEYWORD EXPANSION** | 자동 키워드 확장 | 난이도별 충분한 콘텐츠 |
  | **OBJECT COUNT** | 난이도별 오브젝트 수 | 적절한 게임 복잡도 |
  | **PUZZLE DESIGN** | 퍼즐 난이도 가이드 | 균형잡힌 게임플레이 |
  | **INTERACTION CONSTRAINTS** | 물리적 상호작용만 | Unity 구현 가능성 보장 |
  | **TECHNICAL REQUIREMENTS** | Unity6 컴포넌트 제한 | 호환성 확보 |
  | **LANGUAGE** | 한국어/영어 구분 | 현지화된 게임 경험 |
  | **NAMING** | PascalCase + 예약어 회피 | 컴파일 오류 방지 |
  | **JSON STRUCTURE** | 정확한 출력 형식 | 파싱 가능한 구조화된 데이터 |
</div>

---

## 💻 스크립트 생성 프롬프트

### 전체 프롬프트 구조

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📜 Unified Scripts Generation Prompt</h4>
  
  ```
  Unity6 C# script generator for escape room puzzle objects using Unity6-specific APIs and components. 
  
  INPUT: scenario JSON with object_instructions array. 
  
  CRITICAL REQUIREMENT: The first object in object_instructions array MUST be GameManager 
  with type='game_manager' - generate its script FIRST and ALWAYS include it in output. 
  
  UNITY6 FEATURES: Use Unity6 InputSystem, GameObject.FindAnyObjectByType<T>() instead of 
  FindObjectOfType, Unity6 UI Toolkit when applicable. 
  
  COMPONENTS ALLOWED: BoxCollider, SphereCollider, CapsuleCollider, MeshCollider, Rigidbody, 
  UI elements (Text, Button, InputField). 
  
  FORBIDDEN: ParticleSystem, AudioSource, Animator, Light, Renderer material changes. 
  
  MANDATORY PROCESSING ORDER: 
  1. Generate GameManager script from object_instructions[0] (always type='game_manager') 
  2. Generate scripts for remaining objects with type='interactive_object' in sequence. 
  
  OUTPUT FORMAT: Start with GameManager script (no separator), then add '===ScriptName:::' 
  separator before each subsequent script. NEVER skip GameManager - it must always be 
  the first script in output. 
  
  GAMEMANAGER REQUIREMENTS: Must include public static GameManager Instance (singleton pattern), 
  public bool room_clear=false, Dictionary<string,bool> puzzleStates=new(), 
  Dictionary<string,GameObject> registeredObjects=new(), Dictionary<string,int> inventoryQuantity=new(), 
  Dictionary<string,bool> inventoryBool=new(), public void ShowPlayerHint(string message), 
  public void ShowRandomHint(string[] hints), public void RegisterObject(string name, GameObject obj), 
  public bool GetPuzzleState(string key), public void SetPuzzleState(string key, bool value), 
  public void CheckVictoryCondition(), public bool HasInventoryItem(string item), 
  public void AddInventoryItem(string item, int amount=1), 
  public bool ConsumeInventoryItem(string item, int amount=1), 
  public bool ValidateDependencies(string[] deps). 
  
  OBJECT SCRIPT REQUIREMENTS: public bool isSelected=false for selection system, 
  Register with GameManager in Start() using RegisterObject, Unity6 InputSystem integration, 
  Korean Debug.Log messages, H-key hint system with public string[] randomHints from hint_messages, 
  public string[] dependencies, left_click for selection toggle + interaction_method for 
  primary actions, proper state management and GameManager integration. 
  
  REQUIRED IMPORTS: using UnityEngine; using UnityEngine.InputSystem; using System.Collections; 
  using System.Collections.Generic; 
  
  CODE STYLE: Clean, efficient, no redundant methods, use 'var' for local variables, 
  PascalCase for classes/methods, Unity6 best practices, proper error handling.
  ```
</div>

### 스크립트 생성 전략 분석

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">⚡ 최적화 포인트</h4>
  
  | 지시 사항 | 목적 | 결과 |
  |-----------|------|------|
  | **CRITICAL REQUIREMENT** | GameManager 우선 생성 강제 | 의존성 문제 해결 |
  | **Unity6 FEATURES** | 최신 API 사용 유도 | 현대적 코드 품질 |
  | **COMPONENTS ALLOWED** | 허용 컴포넌트 명시 | 구현 가능성 보장 |
  | **FORBIDDEN** | 금지 항목 명시 | 복잡도 제한 |
  | **OUTPUT FORMAT** | 구분자 형식 지정 | 정확한 파싱 가능 |
  | **GAMEMANAGER REQUIREMENTS** | 필수 메서드 정의 | 일관된 게임 아키텍처 |
  | **OBJECT SCRIPT REQUIREMENTS** | 공통 기능 정의 | 통일된 상호작용 패턴 |
  | **CODE STYLE** | 코딩 스타일 가이드 | 읽기 쉬운 유지보수 가능 코드 |
</div>

---

## 🎯 프롬프트 엔지니어링 기법

### 1. 구조적 명확성

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📐 명확한 구조 설계</h4>
  
  **적용된 기법:**
  - **섹션 분리**: 대문자로 각 영역 구분 (INPUT, REQUIREMENTS, OUTPUT 등)
  - **순서 명시**: MANDATORY PROCESSING ORDER로 처리 순서 강제
  - **형식 정의**: JSON STRUCTURE로 정확한 출력 형식 제공
  
  **효과:**
  - AI가 지시사항을 정확히 이해
  - 일관된 출력 형식 보장
  - 파싱 오류 최소화
</div>

### 2. 제약 조건 명시

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🚫 명확한 제한사항</h4>
  
  **금지 항목 명시의 이점:**
  - 불필요한 복잡도 제거
  - Unity 구현 가능성 보장
  - 일관된 게임 메커니즘
  
  ```
  FORBIDDEN: visual effects, lighting changes, color changes, 
  transparency, glowing, particle systems, animations, audio
  ```
  
  → 물리적 상호작용만으로 퍼즐 구성
</div>

### 3. 컨텍스트 제공

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎮 Unity6 특화 컨텍스트</h4>
  
  **Unity6 관련 지시:**
  - 최신 API 사용 (`GameObject.FindAnyObjectByType<T>()`)
  - Input System 통합
  - UI Toolkit 활용
  
  **결과:**
  - 최신 Unity 버전에 최적화된 코드
  - 더 나은 성능과 유지보수성
</div>

### 4. 다국어 처리

```
LANGUAGE: Korean for failure_feedback and hint_messages 
(mysterious escape room atmosphere), English for all other values
```

**전략적 언어 분리:**
- 게임 내 메시지: 한국어 (몰입감 증대)
- 기술적 요소: 영어 (개발 편의성)

---

## 📊 Temperature 설정 전략

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🌡️ 작업별 Temperature 최적화</h4>
  
  ```json
  {
    "scenarioTemperature": 0.9,  // 창의적 시나리오
    "scriptTemperature": 0.1      // 정확한 코드
  }
  ```
  
  | 작업 | Temperature | 이유 |
  |------|-------------|------|
  | **시나리오 생성** | 0.9 (높음) | 다양하고 창의적인 퍼즐과 스토리 |
  | **스크립트 생성** | 0.1 (낮음) | 문법적으로 정확하고 일관된 코드 |
</div>

---

## 🚀 프롬프트 효과성

### 측정 가능한 개선사항

<div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin: 20px 0;">
  <div style="background: #e3f2fd; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>파싱 성공률</h4>
    <div style="font-size: 2em; font-weight: bold; color: #1976d2;">98%+</div>
    <p>정확한 JSON 구조</p>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>컴파일 성공률</h4>
    <div style="font-size: 2em; font-weight: bold; color: #388e3c;">95%+</div>
    <p>오류 없는 C# 코드</p>
  </div>
  <div style="background: #f3e5f5; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>게임 완성도</h4>
    <div style="font-size: 2em; font-weight: bold; color: #7b1fa2;">90%+</div>
    <p>플레이 가능한 퍼즐</p>
  </div>
</div>

---

## 💡 핵심 성공 요인

<div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">✨ 프롬프트 엔지니어링 인사이트</h4>
  
  1. **명시적 > 암시적**: 모든 요구사항을 명확히 명시
  2. **구조화된 출력**: JSON 형식으로 파싱 가능한 결과
  3. **제약과 자유의 균형**: 필수 요소는 강제, 창의성은 허용
  4. **반복 가능성**: 동일한 입력에 대해 일관된 품질
  5. **에러 방지**: 예약어 회피, 컴포넌트 제한 등
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>이 프롬프트들은 수많은 테스트와 최적화를 거쳐 <strong>최고의 성능</strong>을 발휘합니다.</p>
</div>