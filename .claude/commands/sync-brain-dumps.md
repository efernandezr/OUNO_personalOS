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

## Orchestration Flow

```
Orchestrator                     →     Agent
─────────────────────────────────────────────────────────
1. Parse parameters
2. Load notion-mapping.yaml
3. Prepare local path (1-capture/brain-dumps/YYYY-MM/)
                                 →    4. sync-agent (sync_to_local)
                                 →    5. Return sync report
6. Receive JSON output           ←
7. Display summary
8. Sync personal context (if available)
```

## Execution Steps

### Step 1: Load Configuration

Read: `config/notion-mapping.yaml` (brain_dumps and personal_context database IDs).

### Step 2: Prepare Local Path

Construct path `1-capture/brain-dumps/{YYYY-MM}/`, create directory if needed.

### Step 3: Invoke Sync Agent

Follow **Agent Invocation** in `agent-execution-guide.md` with:
- Agent: `sync-agent`, Model: `haiku`
- Input: `operation: "sync_to_local"`, `database: "brain_dumps"`, `database_id`, `local_path`, `since_date`
- Add flags: `--all` → "Sync ALL entries, not just unprocessed"
- Add flags: `--dry-run` → "DRY RUN - report without creating files"

### Step 4: Display Summary

```markdown
## Sync Complete

**Brain Dumps**
- Synced: {total_synced} new entries
- Skipped: {total_skipped}

### New Files Created
{For each synced: path (title)}

{If skipped:}
### Skipped
{For each: title - reason}

{If errors:}
### Errors
{error list}
```

### Step 5: Sync Personal Context (Optional)

If personal_context database ID is configured (not "pending"):

1. Query personal_context database where `Synced = false` (via sync-agent)
2. For each entry, append to `config/personal-context.yaml` (stories/influences/career)
3. Mark entries as synced in Notion

Show: `### Personal Context — Stories: {n}, Influences: {n}, Career: {n}`

## Duplicate Handling

| Scenario | Action |
|----------|--------|
| Filename exists, content identical | Skip |
| Filename exists, content different | Create with `-v2` suffix, warn |
| New entry | Create file |

## Error Handling

| Error | Action |
|-------|--------|
| Notion API failure | Retry 3 times, abort with message |
| Permission error | Log, continue with others |
| Invalid date | Use created_time fallback |
| Empty content | Create file with note, warn |

## Output Locations

- Brain dumps: `1-capture/brain-dumps/YYYY-MM/{YYYY-MM-DD}-{slug}.md`
- Personal context: appended to `config/personal-context.yaml`

## Notes

- One-way sync: Notion → Local
- Local files are source of truth for content
- Safe to run multiple times (idempotent)

## Agent Reference

- **Sync Agent**: `.claude/agents/sync-agent.md`
