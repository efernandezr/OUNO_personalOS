---
description: Get your personalized morning brief with market intel and priorities
---

# /daily-brief

Generate a personalized daily briefing combining market intelligence with priorities.

## Usage

```
/daily-brief [options]
```

## Parameters (Optional)

- `--length`: Brief length (default: "standard")
  - `quick` - Must-know items only (5 min read)
  - `standard` - Full brief (10 min read)
  - `comprehensive` - Deep dive with all details

- `--include-todos`: Include pending tasks from Notion (default: false)

## Orchestration Pattern

This command uses **Task tool delegation** to the `intelligence-agent` in quick mode.

```
Orchestrator (this command)     →     intelligence-agent
─────────────────────────────────────────────────────────
1. Parse parameters
2. Load configs
3. Construct quick-mode input
                                 →    4. Quick scan (high-priority sources)
                                 →    5. Return top insights
6. Receive JSON output           ←
7. Query Notion todos (optional)
8. Generate content opportunity
9. Format brief markdown
10. Write file
11. Sync to Notion (sync-agent)
12. Update STATUS.md
```

## Execution Steps

### Step 1: Load Configuration (Orchestrator)

Read these config files:
- `config/topics.yaml` - Get priority topics and content pillars
- `config/sources.yaml` - Filter for high-priority sources only
- `config/notion-mapping.yaml` - Get database IDs
- `config/goals.yaml` - Get current metrics targets

### Step 2: Invoke Intelligence Agent - Quick Mode (Task Tool)

```
Task tool call:
  - description: "Quick market intelligence scan for daily brief"
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - prompt: |
      You are the intelligence-agent for PersonalOS.

      [Read and include content of .claude/agents/intelligence-agent.md]

      ## Your Task

      Execute a QUICK market intelligence scan (for daily brief):

      ```json
      {
        "mode": "quick",
        "timeframe": "24h",
        "depth": "quick",
        "topics": [/* from topics.yaml - primary only */],
        "sources": [/* from sources.yaml - high priority only, max 5 */]
      }
      ```

      Return valid JSON matching output schema. Target 5-7 insights max.
```

### Step 3: Query Notion Tasks (Optional - Orchestrator)

If `--include-todos` flag:

```
Task tool call:
  - description: "Fetch pending tasks from Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      [Include sync-agent.md content]

      ## Your Task

      ```json
      {
        "operation": "query",
        "database": "tasks",
        "database_id": "{from notion-mapping}",
        "data": {
          "filters": { "Status": "In Progress" }
        }
      }
      ```
```

### Step 4: Generate Content Opportunity (Orchestrator)

Based on intelligence-agent output:
1. Review `content_opportunities` from agent response
2. Select top opportunity by urgency and pillar fit
3. Enrich with "why now" context

### Step 5: Format Brief Markdown (Orchestrator)

Transform agent JSON into brief format:

```markdown
# Daily Brief: {date}
**Generated**: {timestamp}

## Good Morning, Enrique

### Must-Know Today

{For each insight from agent where priority in ["High", "Medium"][:5]:}
- **{title}**: {summary truncated to 150 chars} [→]({source_url})

### Metrics Snapshot
{From goals.yaml - display current vs target}
- LinkedIn followers: {current} / {target}
- Newsletter subscribers: {current} / {target}
- Content published this week: {current}

{If --include-todos and tasks returned:}
### Priority Tasks
{For each task:}
- [ ] {task title}

### Content Opportunity of the Day
**Topic**: {content_opportunities[0].topic}
**Why now**: {content_opportunities[0].reason}
**Suggested angle**: {content_opportunities[0].angle}
**Pillar**: {content_opportunities[0].pillar}

### Recommended Reading
{For each insight[:3]:}
1. [{title}]({source_url}) - {suggested_angle}

### Focus Suggestion
Based on today's intelligence: {generate 1-2 sentence recommendation}
```

### Step 6: Write Output File (Orchestrator)

1. Create directory if needed: `outputs/daily/`
2. Write to: `outputs/daily/{YYYY-MM-DD}-brief.md`
3. Write agent log to: `outputs/logs/{YYYY-MM-DD}-daily-brief-agent.json`

### Step 7: Sync to Notion (Orchestrator → sync-agent)

```
Task tool call:
  - description: "Sync daily brief to Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      [Include sync-agent.md content]

      ## Your Task

      ```json
      {
        "operation": "write",
        "database": "daily_briefs",
        "database_id": "{from notion-mapping}",
        "data": {
          "properties": {
            "Title": "Daily Brief - {date}",
            "Date": "{today}",
            "Status": "Generated"
          },
          "content": "{full markdown brief}"
        }
      }
      ```
```

### Step 8: Update STATUS.md (Orchestrator)

1. Set **Last Command** to `/daily-brief`
2. Set **Last Output** to `outputs/daily/{date}-brief.md`
3. Add entry to **Activity Log**

## Agent Reference

- **Intelligence Agent**: `.claude/agents/intelligence-agent.md` (quick mode)
- **Sync Agent**: `.claude/agents/sync-agent.md`

## Length Variations

| Length | Insights | Details |
|--------|----------|---------|
| quick | Top 3 | No metrics, no tasks, minimal |
| standard | Top 5-7 | Full format |
| comprehensive | All | Include medium-priority insights |

## Example Output Location

`outputs/daily/2026-01-08-brief.md`

## Performance Target

- Quick: < 1 minute
- Standard: < 2 minutes
- Comprehensive: < 3 minutes

## Automation

Designed to run via cron at 6:00 AM:
```bash
0 6 * * * cd /path/to/PersonalOS && claude "/daily-brief"
```
