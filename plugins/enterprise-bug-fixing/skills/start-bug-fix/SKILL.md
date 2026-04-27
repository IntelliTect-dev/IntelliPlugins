---
name: start-bug-fix
description: Kick off the full enterprise bug-fix workflow — retrieve a work item from Azure DevOps and begin the structured fix process
---

# Start Bug Fix Skill

Launch the structured enterprise bug-fix workflow for an Azure DevOps work item. This skill delegates to the BugFixerAgent to drive the full process from work item retrieval through to a code-review-ready branch.

## When to Use

Invoke this skill when you:
- Have an Azure DevOps bug or PBI number and want to begin fixing it
- Need to start a test-first bug-fix workflow
- Want the full structured process (branch creation, test writing, fix, validation)

## Usage

Provide the Azure DevOps work item number when invoking:

```
/skills invoke start-bug-fix
```

You will be prompted for the work item number if not already provided.

## What This Skill Does

This skill activates the **BugFixerAgent** and begins the following workflow:

```
1. Retrieve work item from Azure DevOps
2. Analyze and understand root cause
3. Create feature branch (format: {initials}/pbi{number})
4. Write tests that reproduce the bug (test-first)
5. Implement the minimal fix
6. Validate: run tests, build, check for regressions
7. Handle model/Coalesce changes if applicable
8. Pre-completion checklist
9. Mark as ready for code review
```

## Inputs Required

- **Work item number** — e.g., `12345` or `PBI 12345`
- **Project** (optional) — defaults to `CMA` if not specified

## Branch Naming Convention

Feature branches are named: `{user_initials}/pbi{work_item_number}`

Examples: `kb/pbi12345`, `jd/pbi67890`

## Notes

- Do not start this skill without a valid work item number — the agent will ask for one
- If you are already on a feature branch, the agent will ask whether to continue on it or create a new one
- Tests must fail before the fix and pass after — this is enforced by the workflow
