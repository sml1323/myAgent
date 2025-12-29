# agent os workflow
Agent OS 기본 사이클은:
(1회) plan-product
(반복) shape-spec → write-spec → create-tasks → implement-tasks 또는 orchestrate-tasks


## 1. Plan Product(프로젝트당 1회)
- 원래 목적: 제품의 mission/roadmap/tech stack을 정해, 이후 모든 스펙/구현이 그 목표를 따라가게 함
- output: agent-os/product/mission.md, roadmap.md, tech-stack.md

- 내 목적을 위한 사용 방식
    - mission.md: “내가 무엇을 훈련 중인지” (네이밍/테스트/패턴/리팩토링 습관)
    - roadmap.md: “연습할 기능의 난이도 상승 로드맵” (작은 기능→조금 복잡→리팩토링)
    - tech-stack.md: 파이썬 버전/테스트툴/포매터/기본 라이브러리 등

```text
@agent-os/commands/plan-product/1-plan-product.md run this
@agent-os/commands/plan-product/2-create-mission.md run this
@agent-os/commands/plan-product/3-create-roadmap.md run this
@agent-os/commands/plan-product/4-create-tech-stack.md run this
```


## 2. Shape Spec (기능마다 반복, “질문으로 요구사항 다듬기”)
- 목적: 거친 아이디어를 질문/리서치로 요구사항으로 다듬고, 스펙 폴더를 초기화함
- output: agent-os/specs/YYYY-MM-DD-.../planning/requirements.md + visuals 폴더

- 내 목적을 위한 사용 방식
    - (1) 기능 요구사항 질문 3~7개

    - (2) 네이밍/모듈 경계 제안

    - (3) 패턴 적용 후보 0~1개만 추천(Strategy/Template/Factory 중)

    - (4) “이 기능의 최소 테스트/검증 방법” 1개


```text
@agent-os/commands/shape-spec/1-shape-spec.md run this
@agent-os/commands/shape-spec/2-research-spec.md run this
```

## 3. Write Spec (요구사항 → 명세서 spec.md로 고정)
- 목적: requirements를 **정식 스펙(spec.md)**으로 변환 
- output:: agent-os/specs/[this-spec]/spec.md

- 내 목적을 위한 사용 방식
    - Implementation ownership: “사용자가 구현한다. AI는 설계/리뷰만.”
    - Naming rules: “프로젝트 네이밍 규칙(네 standards 요약)”
    - Pattern callout: “이번 기능에서 연습할 패턴 1개 + 적용 위치(예: Summarizer는 Strategy)”

```text
@agent-os/commands/write-spec/write-spec.md run this
```
마찬가지로 번호 파일을 순차적으로 실행

## 4. Create Tasks (스펙 → tasks.md로 쪼개기)
- 목적: spec을 전략적으로 정렬된 작업 목록으로 분해 
- output: tasks.md (specialty별 그룹, 보통 TDD 흐름)

- 내 목적을 위한 사용 방식
    - AI에게 tasks를 만들게 할 때 다음과 같이 지시
        - 각 task에 라벨 붙이기: [N] 네이밍, [S] Strategy, [T] Template, [F] Factory, [TEST]
        - 한 번에 패턴 3개 다 넣지 말고 1개만 강제 적용(나머지는 “선택 리팩토링” task로)

```text
@agent-os/commands/create-tasks/create-tasks.md run this
```
마찬가지로 번호 파일을 순차적으로 실행

## 5. Implement Tasks Orchestrate Tasks

### 1) Implement Tasks를 “체크리스트 + 리뷰 루프”로 사용 (작은 기능)
Implement-tasks는 “tasks.md를 따라 작업을 진행하고 체크한다”는 단계.

실행(하지만 프롬프트를 이렇게 고정)
```text
@agent-os/commands/implement-tasks/implement-tasks.md run this
```

추가 지시:
- 코드는 내가 작성한다.
- 너는 각 task마다 (1) 설계 체크 (2) 네이밍 체크 (3) 패턴 적용 체크 (4) 최소 테스트 제안만 해라.
- 수정 제안은 diff/짧은 스니펫만. 파일 전체 재작성 금지.

### 2) Orchestrate Tasks를 “작업그룹별 프롬프트 생성기”로 사용 (큰 기능 / 더 통제)
Orchestrate:
orchestration.yml을 만들고 
(subagent 없으면) task group별 “targeted prompt” 파일을 만들어 주고
그 프롬프트들을 순차 실행

실행
@agent-os/commands/orchestrate-tasks/orchestrate-tasks.md run this
(번호 방식도 가능) 


- 내 목적을 위한 사용 방식 
orchestrate가 만든 implementation/prompts/*.md를 열어서 맨 위에 한 줄 추가:
“코드 구현은 사용자가 한다. 너는 설계/리뷰/테스트 제안만 한다.”


## 실제 루틴
`~/agent-os/scripts/project-install.sh --profile learning-reviewer --agent-os-commands true`

1. shape-spec (질문/경계/패턴 후보) 
2. write-spec (spec.md에 패턴 1개 강제 명시) 
3. create-tasks (라벨링 + 테스트 포함) 
4. 직접 구현
5. (작으면) implement-tasks로 task별 리뷰 루프 
   (크면) orchestrate-tasks로 그룹별 리뷰 프롬프트 생성 
6. 마지막에 standards/workflows 개선 포인트 기록(문서가 “패턴을 보고 standards 최적화”를 권장) 


#### 기타 참고 사항
1. shape-spec 은 요구사항 명확할 시 건너뛰기 가능
2. 한 스펙(spec)에서는 implement-tasks 또는 orchestrate-tasks 중 하나만 사용(둘 다 쓰지 않기).
3. 각 단계 후 “완료 조건(생성물 파일 확인)”을 습관화: 예) plan-product 끝나면 agent-os/product/* 3개 파일이 실제로 생겼는지 확인.


(a) 각 단계 완료 체크 문장

plan-product: mission/roadmap/tech-stack 3개 파일 생성 확인

shape-spec: requirements.md 생성 확인

write-spec: spec.md 생성 확인

create-tasks: tasks.md 생성 확인

(b) spec.md에 학습 모드 고정 문장(매 스펙마다 1회)

write-spec 결과 spec.md 상단/하단에 이 한 줄 추가:

“Implementation is written by the user; AI provides design/review and minimal diffs only.”