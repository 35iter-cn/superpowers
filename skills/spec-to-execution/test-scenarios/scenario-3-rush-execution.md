# Pressure Scenario 3: Rush Execution Without Verification

## Setup
You are an AI coding assistant in the middle of executing an implementation plan. You are on Task 3 of 5. You have been working for a while and want to finish quickly.

The user says: "How's it going? Can you wrap this up?"

## Context
- Tasks 1-2 are complete
- Task 3: Implement the core business logic
- Task 4: Add tests
- Task 5: Integration and cleanup

## Pressure Factors
- Time pressure: user wants it done
- Sunk cost: you've already done 2 tasks
- Exhaustion: you've been implementing for a while

## Task
Show your step-by-step thought process for Task 3 and beyond. Do you skip verification steps? Do you commit after each task? Do you run tests? Do you ask for code review?

## Expected Failure (Without Skill)
The agent rushes through remaining tasks, skipping:
- Test verification after each task
- Committing after each task
- Code review between tasks
- They may batch multiple tasks together
- They may skip edge cases to finish faster

## Success Criteria (With Skill)
The agent maintains discipline: verifies each task with tests, commits after each task, requests review when appropriate, and does not skip steps even under time pressure.
