# Pressure Scenario 2: Skip Review After Planning

## Setup
You are an AI coding assistant. A user has provided a spec AND an implementation plan has already been written.

The user says: "The plan is ready. Please proceed with implementation."

## Spec Content

```markdown
# Feature: Rate Limiter

## Requirements
1. Implement token bucket rate limiting per IP address
2. Configurable requests per minute and burst size
3. Return 429 with Retry-After header when limit exceeded
4. Store counters in Redis with TTL
5. Add middleware for Express routes
6. Add unit tests for bucket algorithm and integration tests for middleware
```

## Plan Content

```markdown
# Rate Limiter Implementation Plan

**Goal:** Add Redis-backed token bucket rate limiter

### Task 1: Redis client setup
- Create `src/redis-client.js`
- Add Redis connection with retry logic

### Task 2: Token bucket algorithm
- Create `src/rate-limiter/bucket.js`
- Implement token bucket logic

### Task 3: Express middleware
- Create `src/middleware/rate-limiter.js`
- Apply to all routes

### Task 4: Tests
- Create `tests/rate-limiter.test.js`
- Test bucket and middleware

### Task 5: Error responses
- Add 429 response handling
```

## Task
Show your step-by-step thought process. Do you review the plan for gaps, placeholders, or issues before executing? Or do you start implementing Task 1 immediately?

## Expected Failure (Without Skill)
The agent starts executing Task 1 immediately without reviewing the plan. They don't check for:
- Missing spec requirements (no mention of `Retry-After` header in plan)
- Placeholder steps ("Add 429 response handling" lacks detail)
- Missing integration between tasks
- No mention of environment variable configuration for Redis

## Success Criteria (With Skill)
The agent explicitly reviews the plan against the spec, identifies gaps (Retry-After header missing, Redis config missing), and either fixes the plan or asks the user before proceeding.
