---
description: Create a feature spec from planning conversation
---

# /create-spec

Create a structured feature specification from the current planning conversation. Generates three files capturing requirements, implementation tasks, and manual action items.

## Usage

```bash
/create-spec {feature-name}
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `$ARGUMENTS` | Yes | Feature name in kebab-case (e.g., `add-auth`, `improve-voice`) |

## Execution Steps

### 1. Validate Feature Name

If no name provided: ask user, suggest kebab-case. Convert if needed (spaces → hyphens, lowercase).

### 2. Create Spec Folder

```
Create directory: system/specs/{feature-name}/
```

### 3. Extract from Conversation

Analyze the current conversation to extract:

**For requirements.md:** Functional description, motivation, acceptance criteria, dependencies
**For implementation-plan.md:** Phases, tasks with checkboxes, technical details, file paths, dependencies
**For action-required.md:** Manual human steps (accounts, API keys, env vars, service config)

### 4. Create requirements.md

```markdown
# Requirements: {Feature Name}
## Overview
{1-2 sentence summary}
## Motivation
{Why needed, what problem it solves}
## Functional Requirements
- {Requirements list}
## Acceptance Criteria
- [ ] {Testable criteria}
## Dependencies
- {Dependencies if any}
## Out of Scope
- {Explicit exclusions}
```

### 5. Create implementation-plan.md

```markdown
# Implementation Plan: {Feature Name}
## Overview
{Approach summary}
## Phase 1: {Phase Name}
{Phase goal}
### Tasks
- [ ] Task description
  - [ ] Sub-tasks if needed
### Technical Details
{CLI commands, code snippets, schemas, file paths}
## Phase 2: {Phase Name}
...
---
## Files to Create/Modify
| File | Action | Purpose |
```

### 6. Create action-required.md

If manual steps exist: list under Before/During/After Implementation sections.
If none: "No manual steps required."

### 7. Confirm Creation

```
Feature specification created at `system/specs/{feature-name}/`

Files created:
- requirements.md - What and why
- implementation-plan.md - Phased tasks with technical details
- action-required.md - Manual steps (if any)

**Next steps:** Review, refine, implement
```

## Task Guidelines

- Keep tasks atomic (single session)
- Be specific ("Add validation to form" not "Handle forms")
- Note dependencies between tasks
- Capture technical details (CLI commands, file paths, schemas)

## Notes

- Specs are gitignored (personal to each user)
- No Notion sync (local workflow only)
- Phase-based organization helps track progress
