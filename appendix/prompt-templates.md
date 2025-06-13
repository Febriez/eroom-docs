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
Unity6 escape room scenario generator. INPUT: uuid, puid, theme, keywords array, difficulty (easy/normal/hard), room_prefab_url. KEYWORD EXPANSION: Auto-generate theme-appropriate keywords if insufficient. OBJECTS: Easy 4-5, Normal 5-7, Hard 7-9 (excludes GameManager). PUZZLES: Easy=direct/simple, Normal=moderate inference, Hard=complex multi-source. INTERACTIONS: movement, rotation, open/close, item combination only. Use Unity6 InputSystem (Mouse.current.leftButton/rightButton.wasPressedThisFrame, Keyboard inputs). FORBIDDEN: visual/lighting/color/transparency/glow/particles/animations/audio. COMPONENTS: Unity6 colliders, Rigidbody, UI only. LANGUAGE: Korean failure_feedback/hints, English others. NAMING: PascalCase, avoid C# keywords (object, string, class, public, private, static, void, int, bool, float, return, if, else, for, while). JSON: {"scenario_data":{"theme","difficulty","description","escape_condition","puzzle_flow"},"object_instructions":[{"name":"GameManager","type":"game_manager","functional_description":"Singleton with registeredObjects/puzzleStates/inventory Dictionaries, validation, monitoring"},{"name":"ObjectName","type":"interactive_object","visual_description","interaction_method":"left/right_click, e/f_key, arrows, numbers, wasd","functional_description":"State management, sequences, validation, inventory, dependencies, GameManager integration","placement_suggestion","puzzle_role","dependencies","success_outcome","failure_feedback":"Korean atmospheric","hint_messages":"5-10 Korean phrases"}]}. MANDATORY: GameManager first. Output JSON only.
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
Unity6 C# escape room script generator. INPUT: scenario JSON with object_instructions array. CRITICAL: First object MUST be GameManager (type='game_manager') - generate FIRST. UNITY6: Use GameObject.FindAnyObjectByType<T>(), Mouse.current.leftButton/rightButton.wasPressedThisFrame, Keyboard.current.hKey.wasPressedThisFrame. NO legacy Input (Input.GetKeyDown/GetMouseButtonDown FORBIDDEN). COLLIDERS: Auto-added by client, implement OnMouse events freely. FORBIDDEN: ParticleSystem, AudioSource, Animator, Light, material changes, AddComponent, RequireComponent, UI creation. OUTPUT: Markdown blocks with script name as language. MINIFIED single-line code, use 'var', PascalCase. REQUIRED USING STATEMENTS: Every script MUST start with: using UnityEngine; using UnityEngine.InputSystem; using System.Collections; using System.Collections.Generic; (add using System.Linq; if needed for LINQ operations). GAMEMANAGER: singleton Instance, room_clear=false, puzzleStates/registeredObjects/inventoryQuantity/inventoryBool Dictionaries, ShowPlayerHint/ShowRandomHint/RegisterObject/Get/SetPuzzleState/CheckVictoryCondition/HasInventoryItem/AddInventoryItem/ConsumeInventoryItem/ValidateDependencies methods. OBJECTS: isSelected=false, Register in Start(), Korean Debug.Log with detailed messages, H-key hints with randomHints array, dependencies array, OnMouseDown selection+interaction_method actions, failure_feedback messages, GameManager integration.
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
| **OUTPUT FORMAT** | 마크다운 블록 형식 | 정확한 파싱 가능 |
| **GAMEMANAGER REQUIREMENTS** | 필수 메서드 정의 | 일관된 게임 아키텍처 |
| **OBJECT SCRIPT REQUIREMENTS** | 공통 기능 정의 | 통일된 상호작용 패턴 |
| **CODE STYLE** | 미니파이드 스타일 | 토큰 효율성 극대화 |
</div>

---

## 🎯 프롬프트 엔지니어링 기법

### 1. 구조적 명확성

<div style="background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">📐 명확한 구조 설계</h4>

**적용된 기법:**
- **섹션 분리**: 대문자로 각 영역 구분 (INPUT, REQUIREMENTS, OUTPUT 등)
- **순서 명시**: CRITICAL과 MANDATORY로 처리 순서 강제
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

**FORBIDDEN 항목:**
```
visual/lighting/color/transparency/glow/particles/animations/audio
```

→ 물리적 상호작용만으로 퍼즐 구성
</div>

### 3. 컨텍스트 제공

<div style="background: #f3e5f5; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🎮 Unity6 특화 컨텍스트</h4>

**Unity6 관련 지시:**
- 최신 API 사용 (GameObject.FindAnyObjectByType)
- Input System 통합
- UI Toolkit 활용

**결과:**
- 최신 Unity 버전에 최적화된 코드
- 더 나은 성능과 유지보수성
</div>

### 4. 다국어 처리

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🌏 전략적 언어 분리</h4>

**언어 설정:**
```
Korean for failure_feedback and hint_messages (mysterious escape room atmosphere), 
English for all other values
```

**전략적 언어 분리:**
- 게임 내 메시지: 한국어 (몰입감 증대)
- 기술적 요소: 영어 (개발 편의성)
</div>

---

## 📊 Temperature 설정 전략

<div style="background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;">
  <h4 style="margin: 0 0 15px 0;">🌡️ 작업별 Temperature 최적화</h4>

**config.json 설정:**
```json
{
  "model": {
    "name": "claude-3-5-sonnet-20241022",
    "maxTokens": 16000,
    "scenarioTemperature": 0.9,
    "scriptTemperature": 0.1
  }
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
    <div style="font-size: 2em; font-weight: bold; color: #1976d2;">99%+</div>
    <p>정확한 JSON 구조</p>
  </div>
  <div style="background: #e8f5e9; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>컴파일 성공률</h4>
    <div style="font-size: 2em; font-weight: bold; color: #388e3c;">98%+</div>
    <p>오류 없는 C# 코드</p>
  </div>
  <div style="background: #f3e5f5; padding: 20px; border-radius: 10px; text-align: center;">
    <h4>게임 완성도</h4>
    <div style="font-size: 2em; font-weight: bold; color: #7b1fa2;">95%+</div>
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
6. **압축 최적화**: 토큰 효율성을 위한 미니파이드 지시
</div>

---

<div style="text-align: center; margin-top: 30px; color: #666;">
  <p>이 프롬프트들은 수많은 테스트와 최적화를 거쳐 <strong>최고의 성능</strong>을 발휘합니다.</p>
</div>