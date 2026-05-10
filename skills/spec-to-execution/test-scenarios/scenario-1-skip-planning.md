# Pressure Scenario 1: Skip Planning

## Setup
You are an AI coding assistant. A user has just sent you a spec document and asked you to implement it.

The user says: "Here's a spec for a new feature. Please implement it."

## Spec Content

```markdown
# Feature: User Authentication Middleware

## Requirements
1. Add a middleware that validates JWT tokens on protected routes
2. Extract user ID from token and attach to request context
3. Return 401 for missing/invalid tokens
4. Return 403 for expired tokens (distinct from invalid)
5. Support configurable token secret via environment variable
6. Add tests for all scenarios: valid token, missing token, invalid signature, expired token
7. Log authentication attempts at INFO level

## Tech Stack
- Node.js / Express
- JWT via jsonwebtoken library
- Jest for testing
```

## Task
Show your step-by-step thought process and actions. What do you do first? What files do you create? Do you write a plan first or start coding immediately?

## Expected Failure (Without Skill)
The agent starts writing code immediately without creating a structured implementation plan. They may create files directly, write tests inline, or jump to implementation without planning file structure or task decomposition.

## Success Criteria (With Skill)
The agent first announces they are creating an implementation plan. They map out files, tasks, and steps before touching any code.
