# Continue After Merge

The previous PR has been merged. Resume the workflow:

1. **Switch to main and pull latest:**
   ```bash
   git checkout main && git pull
   ```

2. **Read the plan** — look for a plan file in `plans/` to understand what's next. If none exists, ask what to work on next.

3. **Update the plan** — mark completed items, adjust upcoming steps if anything changed.

4. **Create a new branch** for the next piece of work.

5. **Summarise** — brief statement of what was just completed and what's next.

## Constraints

- Do NOT start implementing anything yet — just set up the branch and update the plan
- If no `plans/` directory or plan file exists, ask the user what to work on next
