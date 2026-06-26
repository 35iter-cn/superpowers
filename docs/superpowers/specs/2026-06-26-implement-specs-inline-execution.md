# implement-specs: Inline Execution with Subagent Review

## Goal

Modify the `superpowers:implement-specs` skill so that Stage 3 (plan execution) runs **in the current session** instead of dispatching an implementer subagent per task, while preserving **task-level review via reviewer subagents**.

## Background

The current `implement-specs` skill enforces a hard pipeline:

1. **Stage 0:** isolated worktree (`superpowers:using-git-worktrees`)
2. **Stage 1:** write plan (`superpowers:writing-plans`)
3. **Stage 2:** review plan (10-point checklist)
4. **Stage 3:** execute plan (`superpowers:subagent-driven-development`)

Stage 3 dispatches a fresh implementer subagent for every task, plus a reviewer subagent after each task, and a final whole-branch reviewer. The user wants to move the **implementation work** into the current session to reduce context fragmentation and subagent overhead, but keep the **review work** delegated to independent reviewer subagents for quality control.

## Constraints

The following constraints, confirmed with the user, must be preserved:

- **Worktree isolation (Stage 0)** remains mandatory.
- **Plan writing (Stage 1)** continues to use `superpowers:writing-plans`.
- **Plan review (Stage 2)** keeps the existing 10-point checklist as a hard gate.
- **Task-level review** remains after each task, performed by a subagent.
- **Final whole-branch review** remains after all tasks.
- The change is limited to `skills/implement-specs/SKILL.md` and any directly supporting artifacts.

## Design

### Stage 3: Execute Plan (revised)

**Core principle:** Current-session implementation + subagent review gates.

```
Load reviewed plan
Create todos for all tasks
For each task:
  1. Mark task in_progress
  2. Execute the task in the current session, following the plan steps exactly
     - Write/modify code
     - Run the task's specified verification command
     - Commit the change(s)
  3. Review complexity gate
     - Passes (all true): ≤3 files, ≤30 net lines, no API/interface changes,
       no state/concurrency/permissions/error-handling changes, one clear
       verification command
     - Fails or uncertain → subagent review path
  4. Self-review path (simple tasks)
     - Run the 5-point self-review checklist against the diff and task brief
     - All pass → mark complete
     - Any doubt → escalate to subagent review
  5. Subagent review path (complex tasks or escalation)
     - Generate a review package for this task's commits
     - Dispatch a reviewer subagent with the task brief + review package
     - Fix Critical/Important findings and re-dispatch reviewer until approved
  6. Mark task complete in todos and progress ledger
After all tasks:
  7. Generate whole-branch review package
  8. Dispatch final reviewer subagent
  9. Address any findings
 10. Use superpowers:finishing-a-development-branch to complete the branch
```

### Review complexity gate

A task qualifies for self-review only when **all** of the following are true:

- Touches **≤ 3 files**.
- Net diff is **≤ 30 lines**.
- No API / interface / signature changes.
- No state management, concurrency, permissions, or error-handling changes.
- One clear verification command covers the change.

If any condition is false, or if the agent is unsure, the task must go through a reviewer subagent.

### Self-review checklist

For simple tasks, the current-session agent must explicitly answer all of the following before marking the task complete:

1. Does this diff fully cover the task brief's requirements?
2. Are there any changes not requested by the plan?
3. Are there TBD/TODO comments, hard-coded values, or magic numbers?
4. Does the verification actually test behavior, not just existence?
5. Are obvious edge cases handled?

If any answer is negative or uncertain, escalate to a reviewer subagent.

### Tooling reuse

- **Task brief extraction:** reuse `subagent-driven-development/scripts/task-brief` to avoid pasting task text into context.
- **Review package generation:** reuse `subagent-driven-development/scripts/review-package` to produce a file containing commits, stat summary, and diff for the reviewer subagent.
- **Reviewer prompt:** reuse `requesting-code-review/code-reviewer.md` as the subagent prompt template.
- **Progress ledger:** continue writing to `.superpowers/sdd/progress.md` (or the equivalent per-worktree location) for crash/recovery safety.

### Reviewer inputs

The reviewer subagent receives:

1. The task brief file path (what should have been implemented).
2. The review package file path (what was actually implemented).
3. The plan's Global Constraints.
4. Any interfaces or decisions from earlier tasks that this task depends on.

### Handling reviewer findings

- **Critical / Important:** must be resolved before marking the task complete. The current-session agent applies the fix and re-runs verification, then re-dispatches the reviewer.
- **Minor:** record in the progress ledger; the final whole-branch reviewer triages whether they must be fixed before merge.

### Pre-flight plan review

Before starting Task 1, run the existing pre-flight scan from `subagent-driven-development` to detect plan contradictions and anything that conflicts with the review rubric. Present findings in one batched question if any exist.

### Anti-rationalization updates

The following anti-rationalization entries in `SKILL.md` need wording updates to reflect that implementation now happens in the current session:

- "If subagent fails task" → replace with guidance for when the current-session agent hits a blocker.
- "Dispatch fix subagent for Critical/Important findings" → keep, but add "or fix directly in the current session if straightforward."
- Remove or soften references that assume an implementer subagent is the only execution path.

## Files to modify

- `skills/implement-specs/SKILL.md`
  - Update `<objective>` to announce inline execution + subagent review.
  - Update `<execution_context>` to replace `superpowers:subagent-driven-development` with `superpowers:executing-plans`.
  - Update Stage 3 process and success criteria.
  - Update anti-rationalization table entries that refer to implementer subagents.
  - Update the Pipeline diagram to show current-session execution + subagent review.

## Success criteria

- The skill no longer requires `superpowers:subagent-driven-development`.
- Stage 3 executes tasks in the current session.
- Each task passes a review gate before being marked complete.
- Simple tasks (≤3 files, ≤30 net lines, no API/state/concurrency/permissions/error-handling changes, single clear verification) use the self-review checklist.
- Complex tasks or any uncertain case use a reviewer subagent dispatch with the reused review package script and reviewer prompt template.
- Critical/Important findings block task completion until resolved.
- Final whole-branch review still happens via subagent.
- Worktree isolation, plan writing, and plan review stages remain unchanged.

## Risks

- **Context pollution:** implementing in the current session means the agent carries all prior task context. This is the user's intent, but the skill must still enforce "surgical changes" per `karpathy-guidelines`.
- **Reviewer cost:** reviewer subagents remain, so token savings come mainly from eliminating implementer subagents, not reviewers.
- **Tooling dependency:** the skill assumes `subagent-driven-development/scripts/task-brief` and `scripts/review-package` remain available. These scripts live under a different skill, but they are general-purpose bash helpers and can be invoked directly by path.
