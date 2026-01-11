---
description: Backup your Notion brain dumps to local storage
---

# /sync-brain-dumps

Pull brain dumps and personal context from Notion and save them locally for analysis and backup.

## Usage

```
/sync-brain-dumps [options]
```

## Parameters (Optional)

- `--all`: Sync all brain dumps (default: only unprocessed)
- `--since`: Only sync entries from a specific date (format: YYYY-MM-DD)
- `--dry-run`: Show what would be synced without actually saving files

## Orchestration Pattern

This command uses **Task tool delegation** to `sync-brain-dumps-agent`.

```
Orchestrator (this command)     →     Agent
─────────────────────────────────────────────────────────
1. Parse parameters
2. Load notion-mapping.yaml
3. Construct agent input
                                 →    4. sync-brain-dumps-agent (fetch & save)
                                 →    5. Return sync report
6. Receive JSON output           ←
7. Display summary
8. Sync personal context (if available)
```

## Execution Steps

### Step 1: Load Configuration (Orchestrator)

Read config file:
- `config/notion-mapping.yaml` - Get brain_dumps and personal_context database IDs

### Step 2: Prepare Local Path (Orchestrator)

1. Get current year-month: `YYYY-MM`
2. Construct path: `1-capture/brain-dumps/YYYY-MM/`
3. Create directory if it doesn't exist

### Step 3: Invoke Sync Brain Dumps Agent (Task Tool)

```
Task tool call:
  - description: "Sync brain dumps from Notion to local"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-brain-dumps-agent for PersonalOS.

      [Read and include content of .claude/agents/sync-brain-dumps-agent.md]

      ## Your Task

      Sync brain dumps from Notion to local storage:

      ```json
      {
        "database_id": "{from notion-mapping.yaml - brain_dumps}",
        "local_path": "1-capture/brain-dumps/{YYYY-MM}/",
        "since_date": {from --since parameter or null}
      }
      ```

      {If --all flag: "Sync ALL entries, not just unprocessed"}
      {If --dry-run flag: "DRY RUN - report what would be synced without creating files"}

      Return valid JSON matching the output schema.
```

### Step 4: Process Agent Output (Orchestrator)

The agent returns:
- `synced[]` - List of synced files with paths
- `skipped[]` - List of skipped entries with reasons
- `errors[]` - Any errors encountered
- `total_synced` - Count
- `total_skipped` - Count

### Step 5: Display Summary (Orchestrator)

```markdown
## Sync Complete

**Brain Dumps**
- Synced: {total_synced} new entries
- Skipped: {total_skipped} (already exist or empty)

### New Files Created
{For each synced:}
- {local_path} ({title})

{If skipped not empty:}
### Skipped
{For each skipped:}
- {title}: {reason}

{If errors not empty:}
### Errors
{For each error:}
- {error}
```

### Step 6: Sync Personal Context (Optional - Orchestrator)

If personal_context database ID is configured (not "pending"):

```
Task tool call:
  - description: "Sync personal context from Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      [Include sync-agent.md content]

      ## Your Task

      Query personal context entries where Synced = false:

      ```json
      {
        "operation": "query",
        "database": "personal_context",
        "database_id": "{from notion-mapping}",
        "data": {
          "filters": { "Synced": false }
        }
      }
      ```
```

Then for each entry, append to `config/personal-context.yaml`:
- Stories → `stories` array
- Influences → `influences` array
- Career → `career` array

Finally, mark entries as synced in Notion.

### Step 7: Extended Summary (If Personal Context Synced)

```markdown
### Personal Context
- Stories synced: {count}
- Influences synced: {count}
- Career phases synced: {count}
```

## Agent Reference

- **Sync Brain Dumps Agent**: `.claude/agents/sync-brain-dumps-agent.md`
- **Sync Agent**: `.claude/agents/sync-agent.md` (for personal context)

## Output Locations

### Brain Dumps
Files saved to: `1-capture/brain-dumps/YYYY-MM/`

Format: `YYYY-MM-DD-{slug}.md`

### Personal Context
Appended to: `config/personal-context.yaml`

## Duplicate Handling

| Scenario | Action |
|----------|--------|
| Filename exists, content identical | Skip (no action) |
| Filename exists, content different | Create with `-v2` suffix, warn |
| New entry | Create file |

## Error Handling

| Error | Action |
|-------|--------|
| Notion API failure | Retry 3 times, abort with message |
| Permission error | Log, continue with other entries |
| Invalid date | Use created_time as fallback |
| Empty content | Create file with note, warn |

## Dry Run Mode

With `--dry-run`:
- Queries Notion normally
- Reports what WOULD be synced
- Does NOT create files
- Does NOT update Notion status

## Example

```
> /sync-brain-dumps

Querying Notion "POS: Brain Dumps" database...
Found 3 unprocessed brain dumps.

Syncing:
  [1/3] "AI Agent Ideas" → 1-capture/brain-dumps/2026-01/2026-01-08-ai-agent-ideas.md ✓
  [2/3] "Content Strategy" → 1-capture/brain-dumps/2026-01/2026-01-07-content-strategy.md ✓
  [3/3] "dMAX Notes" → Skipped (already exists)

## Summary
- Synced: 2 new brain dumps
- Skipped: 1 duplicate

Tip: Run /brain-dump-analysis to process new content
```

## Notes

- One-way sync: Notion → Local
- Local files are source of truth for content
- Notion is source of truth for "new" entries
- Safe to run multiple times (idempotent)
- Personal context syncs to `config/personal-context.yaml`
