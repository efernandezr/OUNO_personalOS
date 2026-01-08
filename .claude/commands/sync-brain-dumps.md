---
description: Backup your Notion brain dumps to local storage (project)
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

## Execution Steps

### 1. Load Configuration

```
1. Read `config/notion-mapping.yaml`
2. Get brain_dumps database ID: d2a0f13e42b54efdab188fb51fcf181d
```

### 2. Query Notion Database

Use Notion MCP to fetch brain dumps:

```
mcp__notion__notion-fetch with database ID
```

Filter options:
- Default: `Processed` = false (unsynced entries only)
- With `--all`: No filter, get everything
- With `--since`: Filter by Date >= value

### 3. Process Each Entry

For each brain dump from Notion:

1. **Extract metadata**:
   - Title
   - Date (from Date property or created_time)
   - Tags (from Tags multi-select)
   - Content (from Content rich_text or page body)

2. **Generate filename**:
   ```
   brain-dumps/YYYY-MM/YYYY-MM-DD-{slug}.md
   ```
   Where `{slug}` is the title converted to kebab-case

3. **Check for duplicates**:
   - Compare filename to existing files
   - If exists, compare content hash
   - Skip if identical, warn if different

### 4. Save Local Files

Create markdown file with format:

```markdown
# {Title}

**Date**: {YYYY-MM-DD}
**Tags**: {comma-separated tags}
**Source**: Notion (synced {current-date})

---

{Content body}
```

### 5. Update Notion Status

After successful local save:
- Mark the Notion entry's `Processed` field as checked
- This prevents re-syncing the same entry

### 6. Generate Sync Report

Output summary:

```markdown
## Sync Complete

**Synced**: {count} brain dumps
**Skipped**: {count} (already exist)
**Errors**: {count}

### New Files Created
- brain-dumps/2026-01/2026-01-06-ai-agent-ideas.md
- brain-dumps/2026-01/2026-01-05-content-strategy.md

### Skipped (Already Exist)
- brain-dumps/2026-01/2026-01-04-dmax-thoughts.md
```

## Output Location

Files saved to: `brain-dumps/YYYY-MM/`

## Duplicate Handling

| Scenario | Action |
|----------|--------|
| Filename exists, content identical | Skip (no action) |
| Filename exists, content different | Create with `-v2` suffix, warn user |
| New entry | Create file |

## Error Handling

| Error | Action |
|-------|--------|
| Notion API failure | Retry 3 times, then abort with message |
| Permission error | Log error, continue with other entries |
| Invalid date format | Use created_time as fallback |
| Empty content | Create file with note, warn user |

## Post-Execution

1. Display sync summary
2. Update STATUS.md activity log
3. Suggest running `/brain-dump-analysis` if new content was synced

## Example

```
> /sync-brain-dumps

Querying Notion "POS: Brain Dumps" database...
Found 3 unprocessed brain dumps.

Syncing:
  [1/3] "AI Agent Architecture Ideas" → brain-dumps/2026-01/2026-01-06-ai-agent-architecture-ideas.md ✓
  [2/3] "Content Pillar Thoughts" → brain-dumps/2026-01/2026-01-05-content-pillar-thoughts.md ✓
  [3/3] "dMAX Platform Notes" → Skipped (already exists)

## Summary
- Synced: 2 new brain dumps
- Skipped: 1 duplicate
- Run /brain-dump-analysis to process new content
```

---

## Part 2: Sync Personal Context

After syncing brain dumps, also sync personal stories and experiences from Notion.

### 1. Load Personal Context Database

```
1. Read `config/notion-mapping.yaml`
2. Get personal_context database ID
3. Skip if database ID is "pending" (not yet created)
```

### 2. Query Personal Context

Use Notion MCP to fetch entries where `Synced` = false

### 3. Process Each Entry

For each personal context entry from Notion:

1. **Extract data**:
   - Title (story identifier)
   - Type (story, book, experience, career)
   - Short Version
   - Themes (multi-select)
   - Use When

2. **Append to config/personal-context.yaml**:
   - Add to appropriate section based on Type
   - Stories → `stories` array
   - Books → `influences` array
   - Career → `career` array

### 4. Update Notion Status

After successful local save:
- Mark the Notion entry's `Synced` field as checked

### 5. Extended Sync Report

```markdown
## Sync Complete

### Brain Dumps
- Synced: {count}
- Skipped: {count}

### Personal Context
- Stories synced: {count}
- Influences synced: {count}
```

---

## Notes

- This is a one-way sync: Notion → Local
- Local files are considered source of truth for content
- Notion is the source of truth for "new" entries
- Safe to run multiple times (idempotent)
- Personal context syncs to `config/personal-context.yaml`
