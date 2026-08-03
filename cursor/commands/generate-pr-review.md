# Generate Project-Specific PR Review Automation

You are generating a customised PR review configuration for this project. This combines:
1. **Global standards** from personal skills (TDD, TypeScript strict, functional patterns)
2. **Project-specific rules** discovered from codebase analysis

## Step 1: Analyse the Project

### AI/LLM Configuration Files

Check for existing AI assistant configurations that define project rules:

```
.cursor/rules/*.md
.cursorrules
AGENTS.md
CLAUDE.md
.github/copilot-instructions.md
CONTRIBUTING.md
```

Extract rules, patterns, and conventions from these files — they represent explicit project decisions.

### Project Documentation

Check for documented conventions:

```
docs/adr/*.md
docs/decisions/*.md
docs/*.md
README.md
CONTRIBUTING.md
DEVELOPMENT.md
CODING_STANDARDS.md
```

Parse ADRs for architectural decisions that affect code review (e.g., "We use Zod for all validation").

### CI Pipeline

Check `.github/workflows/*.yml` and document: pipeline steps, execution order, runtime versions, environment variables.

### Tech Stack Detection

Check for:
- `package.json` — dependencies, scripts, project type
- `tsconfig.json` — note `strict`, `noUncheckedIndexedAccess`, and other strict flags
- `.eslintrc.*` or `eslint.config.*` — linting rules
- `jest.config.*` or `vitest.config.*` — testing setup
- `.prettierrc*` — formatting rules

### Existing Code Conventions

Search for patterns in `src/`:
- Test file organisation and naming
- Factory function patterns
- Import path conventions

## Step 2: Create Project Review Agent

Based on the analysis, create `.cursor/agents/pr-reviewer.md` in the project:

```markdown
---
name: pr-reviewer
description: >
  Project-specific PR review combining global standards with [PROJECT_NAME] conventions.
  Use proactively for review guidance or reactively to analyse PRs.
---

# [PROJECT_NAME] PR Review

This reviewer enforces:
1. **Global standards** — TDD, TypeScript strict, functional patterns
2. **Project conventions** — [Discovered patterns]

## Global Rules (Non-Negotiable)

### TDD Compliance
- Every production code change needs corresponding tests
- Tests come BEFORE implementation (test-first)
- Tests verify behaviour, not implementation

### Testing Quality
- Test through public API only
- No `let`/`beforeEach` — use factory functions
- Factory functions validate with real schemas
- No spying on internal methods

### TypeScript Strictness
- No `any` types — ever
- No type assertions without justification
- `type` for data structures, `interface` for behaviour contracts
- Schema-first at trust boundaries (Zod/Standard Schema)
- `readonly` on immutable data
[IF noUncheckedIndexedAccess IS ENABLED: All indexed access returns `T | undefined`]

### Functional Patterns
- No data mutation (no `.push()`, `.splice()`, property assignment)
- Pure functions (no side effects)
- Early returns (no nested if/else)
- Array methods over loops
- No comments (self-documenting code)

---

## Project-Specific Rules

[GENERATED BASED ON PROJECT ANALYSIS]

### Rules from Existing Configuration

[Extract from .cursor/rules/, AGENTS.md, CONTRIBUTING.md, etc.]

### Architecture Decisions (from ADRs)

- **ADR-001**: [Decision] — [How it affects review]

### Tech Stack: [DETECTED]

- Framework: [e.g., React 18]
- Testing: [e.g., Vitest + Testing Library]
- Schema: [e.g., Zod]

### Testing Conventions

- Test file location: [e.g., `__tests__/` or `.test.ts`]
- Factory pattern: [e.g., uses `getMock*` prefix]

---

## Review Checklist

### Must Pass (Blocking)
- [ ] All production code has tests (TDD)
- [ ] Tests are behaviour-focused
- [ ] No `any` types
- [ ] No data mutation
- [ ] No security issues
- [ ] CI passes

### Should Pass
- [ ] Factory functions for test data
- [ ] Pure functions where possible
- [ ] Early returns pattern
- [ ] Self-documenting code

---

## Commands for This Project

\`\`\`bash
# Run tests
[DETECTED_TEST_COMMAND]

# Type check
[DETECTED_TYPE_CHECK_COMMAND]

# Lint
[DETECTED_LINT_COMMAND]
\`\`\`
```

## Step 3: Summary

After generation, provide:

1. **What was created** — file location
2. **Key project-specific rules discovered**
3. **How to use** — how to invoke the reviewer
4. **Customisation guide** — how to add more rules
