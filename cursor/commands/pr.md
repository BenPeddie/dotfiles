# Create Pull Request

## Pre-PR Quality Gate

Before creating the PR, verify each of these has been completed:

1. **Refactoring assessment** — The `refactoring` skill has been run. Any valuable refactoring has been committed separately.
2. **Typecheck and lint pass** — Run the project's typecheck and lint commands; fix any errors.
3. **Tests pass** — All tests green locally.

Run any incomplete steps before proceeding.

## Gather Context

Run these to understand what's being shipped:

```bash
git log main..HEAD --oneline
git diff main...HEAD --stat
```

## PR Creation

Create a PR with `gh pr create` using:

### Title
Concise imperative sentence describing the change (e.g. "Add user export endpoint").

### Body

```
## Summary
- 1-3 bullet points describing WHAT changed and WHY
- Focus on the outcome, not the implementation

## Test plan
- [ ] Key scenarios covered by tests
- [ ] Manual verification steps if applicable
```

**Prefer small PRs** — if the change could be split into independently mergeable units, consider doing so.

Note: No test plan section needed if TDD was followed end-to-end and all paths are covered by tests.
