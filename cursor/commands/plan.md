# Create a Plan

## Setup

1. If on main, create a new feature branch first
2. Check for existing plans: `ls plans/ 2>/dev/null`
3. Explore the relevant codebase areas before writing

## Plan File

Write the plan to `plans/<feature-name>.md` (create the directory if needed).

```markdown
# Plan: [Feature Name]

**Branch**: feat/feature-name
**Status**: Active

## Goal

[One sentence describing the outcome]

## Acceptance Criteria

[Behaviour-driven criteria — describe observable business outcomes, not implementation details.]

- [ ] Criterion 1
- [ ] Criterion 2

## Steps

### Step 1: [One sentence description]

**What**: What needs to happen?
**Done when**: How do we know it's complete?

### Step 2: ...

## Pre-PR Quality Gate

Before each PR:
1. Refactoring assessment — run `refactoring` skill
2. Typecheck and lint pass
3. Tests pass

---
*Delete this file when the plan is complete. If `plans/` is empty, delete the directory.*
```

## Constraints

- **Do NOT write any production code, test code, or implementation files**
- **Plan document only** — the only file to create/modify is in `plans/`
- Write the plan to a file; do not present the full plan inline in chat
- **Prefer multiple small PRs** — break work into the smallest independently mergeable units
- Each step should be small enough for a single commit
