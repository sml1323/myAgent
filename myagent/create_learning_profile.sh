#!/usr/bin/env bash
set -euo pipefail

PROFILE_NAME="learning-reviewer"
BASE_DIR="${HOME}/agent-os"
PROFILE_DIR="${BASE_DIR}/profiles/${PROFILE_NAME}"
STANDARDS_DIR="${PROFILE_DIR}/standards"

if [[ ! -d "$BASE_DIR" ]]; then
  echo "❌ ${BASE_DIR} 가 없습니다. Agent OS base-install을 먼저 해주세요."
  exit 1
fi

# Create directories
mkdir -p "${STANDARDS_DIR}/global" "${STANDARDS_DIR}/backend"

# Ensure profile-config.yml exists and inherits default
PROFILE_CONFIG="${PROFILE_DIR}/profile-config.yml"
mkdir -p "${PROFILE_DIR}"

if [[ -f "${PROFILE_CONFIG}" ]]; then
  cp -f "${PROFILE_CONFIG}" "${PROFILE_CONFIG}.bak"
fi

cat > "${PROFILE_CONFIG}" <<'YAML'
inherits_from: default
YAML

# Helper: write file with backup
write_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    cp -f "$path" "${path}.bak"
  fi
  cat > "$path"
  echo "✅ wrote: $path"
}

# 1) AI collaboration standard
write_file "${STANDARDS_DIR}/global/ai-collaboration.md" <<'MD'
# AI Collaboration Mode (Learning Reviewer)

Role:
- You are a design & code review partner.
- The user writes the implementation. Do NOT deliver full solutions by default.

Default behavior:
- If requirements are unclear, ask 3–7 clarifying questions first.
- Provide guidance, not full code. Prefer small snippets, interfaces, or pseudocode.
- When the user shares code, review it against these standards and propose minimal diffs.

Review format (always):
1) Naming issues (specific identifiers)
2) Design issues (responsibilities, coupling, testability)
3) Pattern opportunities (Strategy / Template Method / Factory)
4) Minimal patch suggestions (diff-like snippets)
5) 1 learning takeaway (why it matters)

Hard rule:
- Do not rewrite entire files unless explicitly asked.
- Do not add new dependencies unless the user asks.
MD

# 2) Naming standard
write_file "${STANDARDS_DIR}/global/naming.md" <<'MD'
# Naming Standards

Python:
- modules/packages: snake_case
- classes: PascalCase
- functions/variables: snake_case
- constants: UPPER_SNAKE_CASE

Functions:
- verb_noun (e.g., parse_html, fetch_posts, build_prompt)
- avoid generic verbs: do, handle, process, manage
- prefer precise verbs: fetch, parse, validate, build, render, compute

Booleans:
- is_/has_/can_/should_ prefix

Classes:
- Name by responsibility:
  - *Service (use-case coordination)
  - *Repository (persistence boundary)
  - *Client (external API boundary)
  - *Factory (construction/wiring)
  - *Strategy/*Policy (pluggable behavior)
  - *Pipeline (ordered steps runner)

Files:
- named after the main responsibility, not “utils” unless truly generic
MD

# 3) Patterns standard
write_file "${STANDARDS_DIR}/backend/patterns.md" <<'MD'
# Pattern Practice Rules

Use patterns only when they improve:
- swapping behavior (Strategy)
- fixed workflow with customizable steps (Template Method)
- config-driven construction (Factory)

Avoid "pattern for pattern's sake".

## Strategy
Use when there are 2+ interchangeable policies/algorithms.
Rules:
- No if/elif branches scattered in business logic to choose algorithms.
- Prefer Protocol/ABC + dependency injection.
- Strategy interface should be small (1–2 methods).
- Selection happens in wiring/factory layer.

## Template Method
Use when you have an invariant sequence of steps.
Rules:
- Base.run() defines the order; subclasses override step hooks.
- Each step must be a small method (testable).
- Keep run() short and readable.

## Factory
Use when object creation depends on config/env/flags.
Rules:
- Centralize construction & config parsing.
- Call sites should depend on interfaces, not concrete classes.
- Factory contains no business logic; only wiring.
MD

# 4) General design rules
write_file "${STANDARDS_DIR}/backend/design-rules.md" <<'MD'
# Design Rules (General)

Small units:
- Prefer small functions (< ~30–50 lines). Split by responsibility.
- Prefer small classes with 1 clear responsibility.

Boundaries:
- Separate core logic from I/O (files, network, DB).
- Core modules should be testable without external systems.

Errors:
- Fail fast on invalid input.
- Prefer explicit error messages.

Readability:
- Use types where helpful (typing, dataclasses).
- Avoid cleverness. Choose clarity over compact code.

Testing:
- New logic should come with at least one small test or a runnable example.
MD

echo
echo "🎉 Done. Profile created/updated: ${PROFILE_NAME}"
echo "Location: ${PROFILE_DIR}"
echo
echo "Next steps:"
echo "1) Set default profile in ~/agent-os/config.yml (optional):"
echo "   default_profile: ${PROFILE_NAME}"
echo "2) Install into a project:"
echo "   cd /path/to/project && ~/agent-os/scripts/project-install.sh --profile ${PROFILE_NAME}"
