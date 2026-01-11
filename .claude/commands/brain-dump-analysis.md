---
description: Find patterns and content opportunities from your notes and ideas
---

# /brain-dump-analysis

Analyze accumulated notes, ideas, and brain dumps to identify patterns and content opportunities.

## Usage

```
/brain-dump-analysis [options]
```

## Parameters (Optional)

- `--timeframe`: Period to analyze (default: "month")
  - `week` - Last 7 days
  - `month` - Last 30 days
  - `quarter` - Last 90 days
  - `all` - All available notes

- `--focus`: Analysis focus (default: "all")
  - `patterns` - Theme extraction only
  - `pillars` - Content pillar alignment
  - `gaps` - Underexplored ideas
  - `all` - Complete analysis

- `--min-mentions`: Minimum times a theme must appear (default: 2)

## Orchestration Pattern

This command uses **Task tool delegation** to `pattern-agent` and `sync-agent`.

```
Orchestrator (this command)     →     Agents
─────────────────────────────────────────────────────────
1. Parse parameters
2. Load configs
3. Query Notion brain dumps      →    sync-agent (query)
4. Read local 1-capture/brain-dumps/
5. Deduplicate & combine
6. Construct pattern input
                                 →    7. pattern-agent (analysis)
                                 →    8. Return themes, queue
9. Receive JSON output           ←
10. Format markdown
11. Write files
12. Mark Notion processed        →    sync-agent (update)
```

## Execution Steps

### Step 1: Load Configuration (Orchestrator)

Read these config files:
- `config/topics.yaml` - Get content pillars array
- `config/notion-mapping.yaml` - Get brain_dumps database ID

### Step 2: Query Notion Brain Dumps (sync-agent)

```
Task tool call:
  - description: "Query unprocessed brain dumps from Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      [Include sync-agent.md content]

      ## Your Task

      ```json
      {
        "operation": "query",
        "database": "brain_dumps",
        "database_id": "{from notion-mapping}",
        "data": {
          "filters": { "Processed": false }
        }
      }
      ```
```

### Step 3: Read Local Brain Dumps (Orchestrator)

1. List files in `1-capture/brain-dumps/` matching timeframe
2. Parse each markdown file for title, date, content, tags
3. Build local notes array

### Step 4: Combine & Deduplicate (Orchestrator)

1. Merge Notion entries + local files
2. Match by title + date
3. If duplicate, prefer local version (may have edits)
4. Build combined notes array:

```json
[
  {
    "title": "string",
    "content": "string",
    "date": "YYYY-MM-DD",
    "source": "local" | "notion",
    "tags": ["string"]
  }
]
```

### Step 5: Invoke Pattern Agent (Task Tool)

```
Task tool call:
  - description: "Analyze brain dumps for patterns"
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - prompt: |
      You are the pattern-agent for PersonalOS.

      [Read and include content of .claude/agents/pattern-agent.md]

      ## Your Task

      Analyze these brain dumps for patterns:

      ```json
      {
        "notes": [/* combined notes array */],
        "focus": "{from parameter or 'all'}",
        "pillars": [
          "AI for Marketing",
          "Claude Code for Marketing",
          "AI Agents for Marketing",
          "Building Agents",
          "Digital Marketing Maturity"
        ],
        "min_mentions": {from parameter or 2}
      }
      ```

      Return valid JSON matching the output schema.
```

### Step 6: Process Agent Output (Orchestrator)

The pattern-agent returns:
- `themes[]` - Extracted themes with frequency and potential
- `evolution[]` - How thinking has evolved
- `underexplored[]` - Ideas worth developing
- `connections[]` - Theme relationships
- `content_queue[]` - Prioritized content recommendations

### Step 7: Format Markdown Output (Orchestrator)

```markdown
# Brain Dump Analysis

## Report Metadata
| Field | Value |
|-------|-------|
| **Generated** | {timestamp} |
| **Report Type** | brain-analysis |
| **Period** | {timeframe} |
| **Status** | success |
| **Notes Analyzed** | {notes_analyzed} |
| **Unique Themes** | {unique_themes_found} |

---

## Content Pillars Identified

{For each theme sorted by frequency:}
### {name}
- **Frequency**: {frequency} mentions
- **Pillars**: {pillar_alignment joined}
- **Content Potential**: {content_potential}
- **Suggested Angles**:
{For each angle:}
  - {angle}

---

## Theme Evolution

{For each evolution item:}
### {theme} ({trajectory})
**Maturity**: {maturity}
**First mentioned**: {earliest_mention}
**Latest**: {latest_mention}

{insight}

## Underexplored Ideas

{For each underexplored:}
| Idea | Potential | Related Themes |
|------|-----------|----------------|
| {idea} | {potential} | {related_themes} |

**Why develop**: {reason}

## Connection Map

{For each connection:}
- **{theme_a}** ↔ **{theme_b}** ({connection_type})
  - Insight: {insight}
  - Opportunity: {content_opportunity}

## Content Queue Recommendations

| Priority | Topic | Pillar | Format |
|----------|-------|--------|--------|
{For each in content_queue sorted by priority:}
| {priority} | {topic} | {pillar} | {suggested_format} |

**Top Recommendation**: {content_queue[0].topic}
*Reason*: {content_queue[0].reason}

---

## Source Notes

All notes analyzed in this report (internal references, not web URLs):

| Note | Date | Source | Tags |
|------|------|--------|------|
{For each note in notes analyzed:}
| {note.title} | {note.date} | {note.source} | {note.tags joined} |

---

*Generated by PersonalOS | pattern-agent | {date}*
```

**Note**: Unlike market intelligence reports which reference web URLs, brain dump analysis references internal notes. The `source_note_ids` in themes can be used to trace back to specific notes for context.

### Step 8: Write Output Files (Orchestrator)

1. Create directory: `2-research/analysis/`
2. Write to: `2-research/analysis/{YYYY-MM-DD}-brain-analysis.md`
3. Write agent log: `system/logs/{YYYY-MM-DD}-pattern-agent.json`

### Step 9: Mark Notion Entries Processed (sync-agent)

For each Notion entry that was analyzed:

```
Task tool call:
  - description: "Mark brain dump as processed"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      ## Your Task

      ```json
      {
        "operation": "update",
        "database": "brain_dumps",
        "database_id": "{from notion-mapping}",
        "data": {
          "page_id": "{notion entry id}",
          "properties": { "Processed": true }
        }
      }
      ```
```

## Agent Reference

- **Pattern Agent**: `.claude/agents/pattern-agent.md`
- **Sync Agent**: `.claude/agents/sync-agent.md`

## Input Sources

### Local Files
- Location: `1-capture/brain-dumps/YYYY-MM/`
- Format: Markdown files
- Best for: Longer, structured notes from desktop

### Notion Database
- Database: "POS: Brain Dumps"
- Best for: Quick captures from mobile
- After analysis: `Processed` checkbox marked true

## Content Potential Scoring

| Level | Criteria |
|-------|----------|
| **High** | 5+ mentions, 2+ pillars, unique angle |
| **Medium** | 2-4 mentions, 1 pillar, evergreen |
| **Low** | 1 mention, tangential to pillars |

## Example Output Location

`2-research/analysis/2026-01-08-brain-analysis.md`

## Retry Configuration

### Notion Operations (via sync-agent)
```yaml
max_retries: 3
backoff:
  initial: 2000  # 2 seconds
  multiplier: 2  # exponential: 2s, 4s, 8s
  max: 8000      # 8 seconds max
retry_on:
  - connection_error
  - timeout
  - status_5xx
  - rate_limit
dont_retry_on:
  - authentication_error
  - invalid_database_id
  - permission_denied
```

### Pattern Agent Operations
```yaml
max_retries: 2
backoff:
  initial: 1000
  multiplier: 2
retry_on:
  - task_tool_error
  - incomplete_response
dont_retry_on:
  - invalid_input (fix input instead)
```

## JSON Validation

After receiving pattern-agent output, validate against schema.

### Schema Reference
```
.claude/utils/schemas.json → agents.pattern-agent
```

### Required Fields
- `themes` (array)
- `evolution` (array)
- `content_queue` (array)
- `notes_analyzed` (integer)
- `unique_themes_found` (integer)
- `analysis_timestamp` (ISO string)

### Validation on Failure
If validation fails:
1. Retry pattern-agent with feedback about missing fields
2. Max 2 validation retries
3. If still failing, proceed with partial data and warning banner

## Partial Results Handling

### Scenario: No Notion Brain Dumps Found
```markdown
> ℹ️ **LOCAL FILES ONLY**
> No unprocessed Notion brain dumps found.
> Analysis based on {n} local files only.
```

### Scenario: No Notes Found Anywhere
```markdown
> ⚠️ **NO NOTES TO ANALYZE**
> No brain dumps found in Notion or local storage.
>
> **To capture ideas**:
> - Add notes to `1-capture/brain-dumps/YYYY-MM/` folder
> - Or create entries in Notion "POS: Brain Dumps" database
> - Run `/sync-brain-dumps` to pull Notion content locally
```

### Scenario: Pattern Agent Partial Failure
```markdown
> ⚠️ **PARTIAL ANALYSIS**
> Some analysis sections incomplete.
> {Specific issues listed}
```

### Scenario: Notion Update Fails
Continue without blocking - mark in output:
```markdown
**Notion Status**: ❌ Could not mark entries as processed
Local analysis complete. Re-run to retry Notion sync.
```

## Performance Target

- < 3 minutes for 100 notes
- < 1 minute for 20 notes

## Tip

Run `/sync-brain-dumps` first to ensure all Notion content is captured locally.
