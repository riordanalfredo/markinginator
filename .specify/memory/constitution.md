<!--
  ============================================================================
  SYNC IMPACT REPORT - Constitution Amendment
  ============================================================================
  Version Change: INITIAL → 1.0.0
  Amendment Date: 2025-11-04

  Changes Made:
  - INITIAL CREATION: Established 7 core principles for Markinginator
  - Added: I. Code Quality & Clarity
  - Added: II. Testing Standards (NON-NEGOTIABLE)
  - Added: III. Functional Programming Paradigm
  - Added: IV. User Experience Consistency
  - Added: V. Performance Requirements
  - Added: VI. Documentation Standards
  - Added: VII. Human-Readable Code
  - Added: Performance Standards section
  - Added: Development Practices section
  - Added: Governance rules

  Template Alignment Status:
  ✅ plan-template.md - Constitution Check section ready for validation
  ✅ spec-template.md - Requirements align with new principles
  ✅ tasks-template.md - Task categories support all principle areas

  Follow-up Actions:
  - None - all placeholders resolved

  Rationale for Version 1.0.0:
  - Initial constitution establishment for Markinginator project
  - Defines foundational governance for Elixir/Phoenix web application
  - Establishes all core development principles from inception
  ============================================================================
-->

# Markinginator Constitution

## Core Principles

### I. Code Quality & Clarity

**MUST**:

- Favor explicitness over magic; avoid implicit behaviors that obscure control flow
- Use pattern matching and guard clauses to make logic paths clear and self-documenting
- Keep functions small (≤20 lines preferred); single responsibility per function
- Module cohesion: group related functions, maintain clear boundaries between contexts
- Use descriptive names: `generate_feedback_for_submission/2` over `gen_fb/2`

**Rationale**: Elixir's functional nature and pattern matching enable highly readable code when used intentionally. Magic and implicit behavior undermine maintainability in codebases where multiple educators and developers collaborate.

---

### II. Testing Standards (NON-NEGOTIABLE)

**MUST**:

- Test-first development: Write tests → Verify failure → Implement → Verify pass
- Every public function MUST have corresponding ExUnit test coverage
- Integration tests required for: LiveView interactions, database queries, external API calls, email/notification delivery
- Minimum 80% code coverage measured via `mix test --cover`
- Tests MUST be independent, repeatable, and fast (no sleeps except where timing is essential)

**Rationale**: Marking workflows are critical to educators' daily work. Bugs in grading logic, feedback generation, or data persistence erode trust. Comprehensive testing is the only acceptable foundation for reliability.

---

### III. Functional Programming Paradigm

**MUST**:

- Favor pure functions: same input → same output, no side effects
- Isolate side effects (DB, HTTP, file I/O) to edges; use `with` for chaining fallible operations
- Immutability by default: never mutate data structures; transform and return new values
- Use pipe operator (`|>`) for transformation chains; avoid deep nesting
- Leverage Elixir idioms: pattern matching, recursion, higher-order functions (map, reduce, filter)

**AVOID**:

- Stateful objects or mutable class-like patterns
- Excessive process state; prefer functional transformation pipelines

**Rationale**: Functional programming reduces cognitive load, simplifies testing, and prevents entire classes of bugs (mutation races, unexpected state changes). Elixir's VM and language design reward functional discipline with reliability and concurrency benefits.

---

### IV. User Experience Consistency

**MUST**:

- LiveView components follow Phoenix standard patterns: `mount/3`, `handle_event/3`, `render/1`
- Consistent feedback mechanisms: success (green), error (red), info (blue), warning (yellow) using Tailwind utility classes
- All user-facing errors MUST provide actionable guidance ("File upload failed: ensure file is CSV and <10MB")
- Loading states MUST be shown for operations >300ms (use Phoenix LiveView loading indicators)
- Responsive design required: mobile-first, test on 320px, 768px, 1024px viewports
- Forms MUST validate client-side (LiveView) and server-side (Ecto changesets)

**Rationale**: Educators use this tool under time pressure during marking periods. Inconsistent UI patterns or unclear errors cause frustration and reduce adoption. Consistency builds user confidence.

---

### V. Performance Requirements

**MUST**:

- Phoenix page loads: <300ms p95 (measured via LiveDashboard telemetry)
- Database queries: N+1 queries forbidden; use preloads and joins
- Batch feedback generation: process 100 assignments <5 seconds (local AI model)
- LiveView updates: <100ms for interactive elements (criterion selection, rubric updates)
- Static assets: images optimized (<200KB), CSS/JS minified in production

**MONITORING**:

- Phoenix telemetry events MUST be emitted for: DB queries, external API calls, LiveView mount/render times
- LiveDashboard MUST be accessible in dev/staging for performance profiling

**Rationale**: Slow marking tools disrupt educator workflow. Performance is a feature; telemetry enables continuous monitoring and regression detection.

---

### VI. Documentation Standards

**MUST**:

- Every module: `@moduledoc` with purpose, usage example, related modules
- Every public function: `@doc` with parameters, return type, example (use doctests where feasible)
- Complex logic: inline comments ONLY when "why" is non-obvious; code should explain "what"
- Keep comments short and sharp: "Preload rubric to avoid N+1" not "This line of code preloads the rubric association because otherwise we would trigger an N+1 query problem which is bad for performance"

**AVOID**:

- Verbose prose; redundant comments that restate code
- Stale comments (keep updated or delete)
- Over-documentation of obvious code

**Rationale**: Elixir's self-documenting nature (pattern matching, function names, type specs) reduces need for verbose comments. Documentation generators (ExDoc) require `@moduledoc` and `@doc` for useful output. Concise comments respect developer time.

---

### VII. Human-Readable Code

**MUST**:

- Variable names describe content: `submission_feedback` not `sf` or `data`
- Function names describe action + intent: `calculate_weighted_score/2`, `format_feedback_for_display/1`
- Use Elixir conventions: `?` suffix for boolean functions (`valid_email?/1`), `!` for raising functions (`fetch_submission!/1`)
- Structure modules semantically: `Markinginator.Grading.RubricCalculator`, not `Markinginator.Utils.Stuff`
- Avoid abbreviations unless universally understood (HTTP, URL, AI acceptable; `calc`, `proc`, `hdl` not acceptable)

**Rationale**: Code is read 10× more than written. Educators and developers from varied backgrounds contribute; clarity over cleverness ensures long-term maintainability.

---

## Performance Standards

### Response Time Requirements

| Operation Type                | Target     | Measurement             |
| ----------------------------- | ---------- | ----------------------- |
| Page Load (LiveView mount)    | <300ms p95 | Phoenix.Telemetry       |
| Interactive UI Update         | <100ms     | LiveView render time    |
| Database Query                | <50ms p95  | Ecto telemetry          |
| Batch AI Feedback (100 items) | <5s        | Custom telemetry event  |
| File Upload (CSV, 10MB)       | <2s        | Phoenix upload handling |

### Resource Constraints

- Database connections: pool size = 10 (configurable via `config/runtime.exs`)
- Memory: LiveView process heap <10MB per active connection
- Concurrent users: support 100 simultaneous educators (horizontal scaling via clustering if needed)

---

## Development Practices

### Code Review Requirements

- All PRs MUST pass: automated tests (CI), Credo linting, Dialyzer type checking
- Reviewer checklist: Constitution compliance, test coverage, performance impact, security (SQL injection, XSS via LiveView escaping)
- Breaking changes require: migration guide, deprecation warnings, version bump documentation

### Quality Gates

- Pre-commit: `mix format` (enforced via `.formatter.exs`)
- Pre-push: `mix test` (all tests pass)
- CI pipeline: `mix test --cover`, `mix credo --strict`, `mix dialyzer`
- Deployment: manual approval required for production

---

## Governance

This constitution supersedes all other coding practices and decisions. Amendments require:

1. Documented justification with rationale
2. Review and approval via PR process
3. Version increment per semantic versioning rules (see below)
4. Update to all dependent templates and documentation

**Semantic Versioning for Constitution**:

- **MAJOR** (X.0.0): Remove or fundamentally redefine a principle; incompatible governance changes
- **MINOR** (0.X.0): Add new principle or section; material expansion of existing guidance
- **PATCH** (0.0.X): Clarifications, typo fixes, wording improvements without semantic changes

**Compliance Enforcement**:

- All PRs and code reviews MUST verify compliance with these principles
- Complexity or principle violations MUST be documented in plan.md with justification
- Use `.specify/memory/constitution.md` (this file) as the authoritative governance reference

**Version**: 1.0.0 | **Ratified**: 2025-11-04 | **Last Amended**: 2025-11-04
