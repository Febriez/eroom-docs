@echo off
cls
echo.
echo GitBook 폴더 구조 생성 시작...
echo.

REM 메인 폴더들 생성
echo 메인 폴더 생성 중...
if not exist "project-overview" mkdir "project-overview"
if not exist "game-system" mkdir "game-system"
if not exist "architecture" mkdir "architecture"
if not exist "backend" mkdir "backend"
if not exist "unity" mkdir "unity"
if not exist "3d-modeling" mkdir "3d-modeling"
if not exist "integration" mkdir "integration"
if not exist "testing" mkdir "testing"
if not exist "troubleshooting" mkdir "troubleshooting"
if not exist "api-reference" mkdir "api-reference"
if not exist "results" mkdir "results"
if not exist "appendix" mkdir "appendix"

REM 1. 프로젝트 개요 파일들 생성
echo 1. 프로젝트 개요 파일 생성 중...

echo # 1.1 프로젝트 소개 > "project-overview\project-introduction.md"
echo. >> "project-overview\project-introduction.md"
echo ## 개요 >> "project-overview\project-introduction.md"
echo 자동화 방탈출 맵 생성 게임 프로젝트의 전체 소개입니다. >> "project-overview\project-introduction.md"
echo. >> "project-overview\project-introduction.md"
echo ## 프로젝트 목표 >> "project-overview\project-introduction.md"
echo - AI를 활용한 자동 방탈출 맵 생성 >> "project-overview\project-introduction.md"
echo - Unity6 3D 기반 몰입형 게임 경험 >> "project-overview\project-introduction.md"
echo - 서버-클라이언트 통합 시스템 구축 >> "project-overview\project-introduction.md"
echo. >> "project-overview\project-introduction.md"
echo ## 담당자 >> "project-overview\project-introduction.md"
echo 작성자: [팀 전체] >> "project-overview\project-introduction.md"
echo 최종 수정일: 2024-XX-XX >> "project-overview\project-introduction.md"

echo # 1.2 전체 시스템 아키텍처 > "project-overview\system-architecture.md"
echo. >> "project-overview\system-architecture.md"
echo ## 시스템 개요 >> "project-overview\system-architecture.md"
echo 전체 시스템의 아키텍처 설계를 설명합니다. >> "project-overview\system-architecture.md"
echo. >> "project-overview\system-architecture.md"
echo ## 컴포넌트 구성 >> "project-overview\system-architecture.md"
echo - Frontend: Unity6 3D Client >> "project-overview\system-architecture.md"
echo - Backend: Java + Undertow Server >> "project-overview\system-architecture.md"
echo - AI: Claude 4 Sonnet + MeshyAI >> "project-overview\system-architecture.md"
echo - Database: [DB 정보] >> "project-overview\system-architecture.md"

echo # 1.3 기술 스택 요약 > "project-overview\tech-stack.md"
echo. >> "project-overview\tech-stack.md"
echo ## 기술 스택 >> "project-overview\tech-stack.md"
echo ### Frontend >> "project-overview\tech-stack.md"
echo - Unity 6 >> "project-overview\tech-stack.md"
echo - C# >> "project-overview\tech-stack.md"
echo. >> "project-overview\tech-stack.md"
echo ### Backend >> "project-overview\tech-stack.md"
echo - Java >> "project-overview\tech-stack.md"
echo - Undertow Server >> "project-overview\tech-stack.md"
echo - SLF4J + Logback >> "project-overview\tech-stack.md"

echo # 1.4 팀 역할 분담 > "project-overview\team-roles.md"
echo # 1.5 개발 일정 및 마일스톤 > "project-overview\development-schedule.md"

REM 2. 게임 시스템 설계 파일들 생성
echo 2. 게임 시스템 설계 파일 생성 중...

echo # 2.1 자동화 맵 생성 프로세스 > "game-system\automated-map-generation.md"
echo. >> "game-system\automated-map-generation.md"
echo ## AI 기반 맵 생성 플로우 >> "game-system\automated-map-generation.md"
echo 맵 생성 프로세스의 상세한 워크플로우를 설명합니다. >> "game-system\automated-map-generation.md"

echo # 2.2 Unity6 3D 게임 플로우 > "game-system\unity-game-flow.md"
echo # 2.3 클라이언트-서버 통신 구조 > "game-system\client-server-communication.md"
echo # 2.4 데이터 흐름 다이어그램 > "game-system\data-flow-diagram.md"

REM 3. 전체 아키텍처 파일들 생성
echo 3. 전체 아키텍처 파일 생성 중...

echo # 3.1 시스템 구성도 > "architecture\system-diagram.md"
echo # 3.2 컴포넌트별 역할 > "architecture\component-roles.md"
echo # 3.3 API 설계 명세 > "architecture\api-design.md"
echo # 3.4 데이터 모델링 > "architecture\data-modeling.md"

REM 4. 서버 개발 파일들 생성 (상세)
echo 4. 서버 개발 파일 생성 중...

echo # 4.1 서버 개발 개요 > "backend\overview.md"
echo. >> "backend\overview.md"
echo ## 서버 개발 목표 >> "backend\overview.md"
echo - 담당 기능 및 책임 >> "backend\overview.md"
echo - 기술 선택 이유 >> "backend\overview.md"
echo - 개발 환경 설정 >> "backend\overview.md"
echo. >> "backend\overview.md"
echo ## 주요 기술 스택 >> "backend\overview.md"
echo - Java + Undertow >> "backend\overview.md"
echo - SLF4J + Logback >> "backend\overview.md"
echo - 비동기 처리 >> "backend\overview.md"

echo # 4.2 Java + Undertow 서버 구현 > "backend\java-undertow-implementation.md"
echo. >> "backend\java-undertow-implementation.md"
echo ## 서버 아키텍처 설계 >> "backend\java-undertow-implementation.md"
echo Undertow 서버의 상세 구현 내용 >> "backend\java-undertow-implementation.md"
echo. >> "backend\java-undertow-implementation.md"
echo ## REST API 구현 >> "backend\java-undertow-implementation.md"
echo /create/room 엔드포인트 구현 상세 >> "backend\java-undertow-implementation.md"

echo # 4.3 AI 프롬프트 엔지니어링 > "backend\ai-prompt-engineering.md"
echo. >> "backend\ai-prompt-engineering.md"
echo ## Claude 4 Sonnet 활용 전략 >> "backend\ai-prompt-engineering.md"
echo ### 시나리오 생성 프롬프트 설계 >> "backend\ai-prompt-engineering.md"
echo AI 프롬프트 설계 방법론 >> "backend\ai-prompt-engineering.md"
echo. >> "backend\ai-prompt-engineering.md"
echo ### 키워드 고도화 로직 >> "backend\ai-prompt-engineering.md"
echo 키워드 최적화 과정 >> "backend\ai-prompt-engineering.md"
echo. >> "backend\ai-prompt-engineering.md"
echo ## 프롬프트 최적화 과정 >> "backend\ai-prompt-engineering.md"
echo ### 출력 토큰 제한 우회 기법 >> "backend\ai-prompt-engineering.md"
echo 토큰 제한 해결 방법 >> "backend\ai-prompt-engineering.md"

echo # 4.4 외부 API 연동 > "backend\external-api-integration.md"
echo # 4.5 성능 최적화 및 테스트 > "backend\performance-optimization.md"

REM 5. Unity 클라이언트 파일들 생성
echo 5. Unity 클라이언트 파일 생성 중...

echo # 5.1 Unity6 3D 게임 구현 > "unity\game-implementation.md"
echo # 5.2 UI/UX 설계 > "unity\ui-ux-design.md"
echo # 5.3 게임 로직 구현 > "unity\game-logic.md"

REM 6. 3D 모델링 파일들 생성
echo 6. 3D 모델링 파일 생성 중...

echo # 6.1 3D 모델 파이프라인 > "3d-modeling\model-pipeline.md"
echo # 6.2 텍스처 및 머티리얼 > "3d-modeling\texture-material.md"
echo # 6.3 애니메이션 시스템 > "3d-modeling\animation-system.md"

REM 7. 통합 및 배포
echo 7. 통합 및 배포 파일 생성 중...

echo # 7.1 시스템 통합 테스트 > "integration\system-testing.md"
echo # 7.2 배포 환경 구성 > "integration\deployment-setup.md"
echo # 7.3 CI/CD 파이프라인 > "integration\ci-cd-pipeline.md"
echo # 7.4 모니터링 및 운영 > "integration\monitoring-operations.md"

REM 8. 테스트 및 검증
echo 8. 테스트 및 검증 파일 생성 중...

echo # 8.1 단위 테스트 결과 > "testing\unit-tests.md"
echo # 8.2 통합 테스트 시나리오 > "testing\integration-tests.md"
echo # 8.3 성능 벤치마크 > "testing\performance-benchmark.md"
echo # 8.4 사용자 테스트 피드백 > "testing\user-feedback.md"

REM 9. 문제 해결 가이드
echo 9. 문제 해결 가이드 파일 생성 중...

echo # 9.1 서버 관련 이슈 > "troubleshooting\server-issues.md"
echo # 9.2 Unity 클라이언트 이슈 > "troubleshooting\unity-issues.md"
echo # 9.3 AI 모델 관련 문제 > "troubleshooting\ai-model-issues.md"
echo # 9.4 통합 시스템 디버깅 > "troubleshooting\system-debugging.md"

REM 10. API 참조
echo 10. API 참조 파일 생성 중...

echo # 10.1 REST API 명세서 > "api-reference\rest-api-spec.md"
echo # 10.2 요청/응답 스키마 > "api-reference\request-response-schema.md"
echo # 10.3 에러 코드 정의 > "api-reference\error-codes.md"
echo # 10.4 샘플 코드 > "api-reference\sample-code.md"

REM 11. 프로젝트 결과 및 인사이트
echo 11. 프로젝트 결과 파일 생성 중...

echo # 11.1 개발 성과 요약 > "results\development-achievements.md"
echo # 11.2 각 파트별 기여도 > "results\team-contributions.md"
echo # 11.3 기술적 도전과 해결 > "results\technical-challenges.md"
echo # 11.4 향후 개선 방향 > "results\future-improvements.md"

REM 12. 부록
echo 12. 부록 파일 생성 중...

echo # 12.1 개발 환경 설정 가이드 > "appendix\development-setup.md"
echo # 12.2 프롬프트 템플릿 모음 > "appendix\prompt-templates.md"
echo # 12.3 참고 자료 및 레퍼런스 > "appendix\references.md"
echo # 12.4 팀 회고록 > "appendix\team-retrospective.md"

REM README.md 파일 업데이트
echo README.md 업데이트 중...

echo # 자동화 방탈출 맵 생성 게임 프로젝트 > "README.md"
echo. >> "README.md"
echo AI와 Unity6를 활용한 혁신적인 방탈출 게임 개발 프로젝트 >> "README.md"
echo. >> "README.md"
echo ## 프로젝트 개요 >> "README.md"
echo 이 프로젝트는 AI를 활용하여 자동으로 방탈출 맵을 생성하고, >> "README.md"
echo Unity6 3D 엔진으로 몰입감 있는 게임 경험을 제공하는 통합 시스템입니다. >> "README.md"
echo. >> "README.md"
echo ## 기술 스택 >> "README.md"
echo - Frontend: Unity6 3D, C# >> "README.md"
echo - Backend: Java, Undertow Server >> "README.md"
echo - AI: Claude 4 Sonnet, MeshyAI >> "README.md"
echo - Tools: GitBook, GitHub >> "README.md"

REM .gitignore 파일 생성
echo .gitignore 파일 생성 중...

echo # GitBook > ".gitignore"
echo _book/ >> ".gitignore"
echo node_modules/ >> ".gitignore"
echo. >> ".gitignore"
echo # 임시 파일 >> ".gitignore"
echo *.tmp >> ".gitignore"
echo *.temp >> ".gitignore"
echo .DS_Store >> ".gitignore"
echo Thumbs.db >> ".gitignore"
echo. >> ".gitignore"
echo # IDE >> ".gitignore"
echo .vscode/ >> ".gitignore"
echo .idea/ >> ".gitignore"
echo *.swp >> ".gitignore"
echo *.swo >> ".gitignore"
echo. >> ".gitignore"
echo # 로그 파일 >> ".gitignore"
echo *.log >> ".gitignore"

echo.
echo 폴더 구조 생성 완료!
echo.
echo 생성된 구조:
echo project-overview/ (5개 파일)
echo game-system/ (4개 파일)
echo architecture/ (4개 파일)
echo backend/ (5개 파일)
echo unity/ (3개 파일)
echo 3d-modeling/ (3개 파일)
echo integration/ (4개 파일)
echo testing/ (4개 파일)
echo troubleshooting/ (4개 파일)
echo api-reference/ (4개 파일)
echo results/ (4개 파일)
echo appendix/ (4개 파일)
echo README.md
echo SUMMARY.md
echo .gitignore
echo.
echo 다음 단계:
echo 1. git add .
echo 2. git commit -m "초기 폴더 구조 및 템플릿 파일 생성"
echo 3. git push origin main
echo 4. GitBook에서 GitHub 동기화 확인
echo.
echo 이제 각 팀원이 담당 섹션을 작성할 수 있습니다!
echo.
pause