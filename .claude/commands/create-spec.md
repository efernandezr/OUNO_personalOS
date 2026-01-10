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

```
If no feature name provided:
  - Ask user for the feature name
  - Suggest kebab-case format

Convert to kebab-case if needed (spaces → hyphens, lowercase)
```

### 2. Create Spec Folder

```
Create directory: specs/{feature-name}/
```

### 3. Extract from Conversation

Analyze the current conversation to extract:

**For requirements.md:**
- What the feature does (functional description)
- Why it's needed (motivation/problem it solves)
- Acceptance criteria (how to know it's done)
- Dependencies on other features or systems

**For implementation-plan.md:**
- Logical phases of implementation
- Specific tasks with checkboxes
- Technical details discussed (CLI commands, schemas, code patterns)
- File paths to create or modify
- Dependencies between tasks

**For action-required.md:**
- Manual steps requiring human action
- Account creation, API keys, environment variables
- Third-party service configuration
- Any setup that cannot be automated

### 4. Create requirements.md

Write `specs/{feature-name}/requirements.md`:

```markdown
# Requirements: {Feature Name}

## Overview

{1-2 sentence summary of what this feature does}

## Motivation

{Why this feature is needed, what problem it solves}

## Functional Requirements

- {Requirement 1}
- {Requirement 2}
- {Requirement 3}

## Acceptance Criteria

- [ ] {Criterion 1 - specific, testable}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

## Dependencies

- {Dependency 1, if any}
- {Dependency 2, if any}

## Out of Scope

- {What this feature explicitly does NOT include}
```

### 5. Create implementation-plan.md

Write `specs/{feature-name}/implementation-plan.md`:

```markdown
# Implementation Plan: {Feature Name}

## Overview

{Brief summary of what will be built and the approach}

## Phase 1: {Phase Name}

{Brief description of this phase's goal}

### Tasks

- [ ] Task 1 description
- [ ] Task 2 description (depends on Task 1)
- [ ] Task 3 description
  - [ ] Sub-task 3a
  - [ ] Sub-task 3b

### Technical Details

{Include CLI commands, code snippets, schemas, file paths, and other implementation specifics discussed during planning that are relevant to this phase's tasks.}

## Phase 2: {Phase Name}

{Brief description}

### Tasks

- [ ] Task 4 description (depends on Phase 1)
- [ ] Task 5 description

### Technical Details

{Technical details for Phase 2 tasks.}

---

## Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `path/to/file.md` | Create | Description |
| `path/to/existing.md` | Modify | What changes |
```

### 6. Create action-required.md

Write `specs/{feature-name}/action-required.md`:

**If manual steps exist:**

```markdown
# Action Required: {Feature Name}

Manual steps that must be completed by a human. These cannot be automated.

## Before Implementation

- [ ] **{Action}** - {Brief reason why this is needed}

## During Implementation

- [ ] **{Action}** - {Brief reason}

## After Implementation

- [ ] **{Action}** - {Brief reason}

---

> **Note:** These tasks are also listed in context within `implementation-plan.md`
```

**If no manual steps exist:**

```markdown
# Action Required: {Feature Name}

No manual steps required for this feature.

All tasks can be implemented automatically.
```

### 7. Confirm Creation

Display summary to user:

```
Feature specification created at `specs/{feature-name}/`

Files created:
- requirements.md - What and why
- implementation-plan.md - Phased tasks with technical details
- action-required.md - Manual steps (if any)

**Next steps:**
1. Review the generated specs for accuracy
2. Refine any unclear requirements or tasks
3. Begin implementation following the task checklist
```

## Task Guidelines

When extracting tasks from the conversation:

- **Keep tasks atomic** - Each should be implementable in a single session
- **Be specific** - "Add validation to form" not "Handle forms"
- **Note dependencies** - Mark when tasks must be done in order
- **Capture technical details** - CLI commands, file paths, schemas
- **Don't lose context** - If specifics were discussed, include them

## Common Manual Tasks

Look for these in the conversation:

- Account creation (services, platforms)
- API key generation
- Environment variable setup
- OAuth app configuration
- DNS/domain setup
- Third-party service registration
- Billing or subscription setup
- Permission grants (Notion, GitHub, etc.)

## Notes

- Specs are gitignored (personal to each user)
- No Notion sync for specs (local workflow only)
- Exclude testing tasks unless explicitly requested
- Phase-based organization helps track progress
- Technical details section prevents losing implementation specifics
