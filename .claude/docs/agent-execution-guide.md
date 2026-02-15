# Agent Execution Guide

Shared patterns for agent invocation, validation, and error handling. Commands reference these instead of duplicating.

## Agent Invocation Pattern

Standard Task tool call template:
```
Task tool call:
  - description: "{short description}"
  - subagent_type: "general-purpose"
  - model: "{from agent frontmatter: sonnet | opus | haiku}"
  - prompt: |
      You are the {agent-name} for PersonalOS.

      [Read and include full content of .claude/agents/{agent-name}.md]

      ## Your Task
      {task-specific instructions with input JSON}

      Return valid JSON matching the output schema.
```

## Sync-Agent: Write to Notion

```
Task tool call:
  - description: "Sync {item} to Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.
      [Include .claude/agents/sync-agent.md content]

      ## Your Task
      ```json
      {
        "operation": "write",
        "database": "{database_name}",
        "database_id": "{from notion-mapping.yaml}",
        "data": { "properties": { ... } }
      }
      ```
```

## Sync-Agent: Query Notion

```
Task tool call:
  - description: "Query {database} from Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.
      [Include .claude/agents/sync-agent.md content]

      ## Your Task
      ```json
      {
        "operation": "query",
        "database": "{database_name}",
        "database_id": "{from notion-mapping.yaml}",
        "data": { "filters": { ... } }
      }
      ```
```

## JSON Validation

After receiving agent output:

1. **Parse JSON**: If malformed, retry agent with: "Previous response was not valid JSON. Return valid JSON only."
2. **Validate required fields**: Check against schema in `.claude/utils/schemas.json` → `agents.{agent-name}`
3. **Validate field types**: Enums, arrays, min/max constraints per schema
4. **On failure**: Retry agent with specific feedback about missing/invalid fields
5. **Max 2 retries** before proceeding with partial data + warning banner

Warning banner for validation failures:
```markdown
> ⚠️ **DATA QUALITY WARNING**
> Agent output had validation issues: {list specific issues}
> Some sections may be incomplete.
```

## Retry Configuration

### Agent Invocations
- Max retries: 2-3
- Backoff: exponential (1s, 2s, 4s; max 4-8s)
- Retry on: task_tool_error, incomplete_response, timeout
- Don't retry on: invalid_input, missing_config

### Notion Sync Operations (via sync-agent)
- Max retries: 3
- Backoff: exponential (2s, 4s, 8s)
- Retry on: connection_error, timeout, status_5xx, rate_limit
- Don't retry on: authentication_error, invalid_database_id, permission_denied

## Partial Results Handling

### Agent Fails Completely
1. Log the error
2. Report to user with actionable message
3. Produce partial output where possible

### Agent Returns Partial Data
1. Extract valid portions, add warning banner
2. Log what failed in agent log file
```markdown
> ⚠️ **PARTIAL RESULTS**
> {description of what's incomplete}
```

### Notion Sync Fails (after retries)
1. Local file save always completes first
2. Add note to output: `**Notion Sync**: ❌ Failed. Saved locally only.`
3. Log sync failure to `system/logs/{date}-sync-errors.json`

## Agent Log Format

Write to: `system/logs/{YYYY-MM-DD}-{HHMM}-{agent-name}.json`

Include: input summary, output, timestamp, duration, errors (if any)
