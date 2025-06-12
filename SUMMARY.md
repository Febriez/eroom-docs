# Table of contents

* [🎮 ERoom](README.md)

## 🌟 1. 프로젝트 개요

* [1.1 프로젝트 소개](project-overview/project-introduction.md)
* [1.2 전체 시스템 아키텍처](project-overview/system-architecture.md)
* [1.3 기술 스택 요약](project-overview/tech-stack.md)

## 🎯 2. 서버 아키텍처

* [2.1 시스템 구성도 (Mermaid)](https://mermaid.live/view#example-diagram-id)
* [2.2 API 설계 명세](architecture/api-design.md)
* [2.3 데이터 모델링](architecture/data-modeling.md)
* [2.4 성능 아키텍처](architecture/performance-architecture.md)

## 🏗️ 3. 서버 구현

* [3.1 Undertow 서버 개요](backend/undertow-server.md)
* [3.2 API 핸들러 구조](backend/api-handler.md)
* [3.3 인증 시스템 (API Key)](backend/api-key-auth.md)
* [3.4 룸 기반 요청 처리 시스템](backend/room-service.md)
* [3.5 Anthropic AI 연동](backend/anthropic-service.md)
* [3.6 Meshy AI 연동](backend/meshy-service.md)

## 🎮 4. Unity 클라이언트

* [4.1 Unity6 게임 구현](unity/game-implementation.md)
* [4.2 클라이언트-서버 통신](unity/client-server-communication.md)
* [4.3 게임 로직 구현](unity/game-logic.md)

## 🔄 5. 통합 & 배포

* [5.1 시스템 통합](integration/system-integration.md)
* [5.2 배포 환경 구성](integration/deployment-setup.md)
* [5.3 모니터링 & 운영](integration/monitoring-operations.md)

## 🔗 6. API 참조

* [6.1 REST API 명세서](api-reference/rest-api-spec.md)
  * [서버 상태 확인](api-reference/endpoints/health-check.md)
  * [룸 생성 요청](api-reference/endpoints/room-create.md)
  * [결과 조회](api-reference/endpoints/room-result.md)
  * [큐 상태 확인](api-reference/endpoints/queue-status.md)
* [6.2 에러 코드 정의](api-reference/error-codes.md)
* [6.3 샘플 코드](api-reference/sample-code.md)

## 🐛 7. 문제 해결

* [7.1 서버 관련 이슈](troubleshooting/server-issues.md)
* [7.2 Unity 클라이언트 이슈](troubleshooting/unity-issues.md)
* [7.3 AI 연동 문제](troubleshooting/ai-integration-issues.md)

## 🐛 8. 부록

* [8.1 프롬프트 템플릿](appendix/prompt-templates.md)
