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

## Execution Steps

1. **Load Configuration**
   - Read `config/topics.yaml` for priority topics
   - Read `config/sources.yaml` for high-priority sources
   - Read `config/notion-mapping.yaml` for database IDs
   - Read `config/goals.yaml` for current metrics targets

2. **Gather Market Intelligence**
   Run lightweight version of /market-intelligence:
   - Scan only high-priority sources
   - Focus on last 24 hours
   - Extract top 5-7 insights

3. **Check Notion (Optional)**
   If --include-todos:
   - Query tasks database for pending items
   - Filter for high-priority tasks

4. **Generate Content Opportunity**
   Based on trends and your content pillars:
   - Identify 1 high-potential topic for today
   - Provide angle suggestion
   - Note why it's timely

5. **Compile Brief**
   Create structured morning briefing with:
   - Greeting with date
   - Must-Know Today (3-5 critical updates)
   - Metrics Snapshot (if available)
   - Priority Tasks (if enabled)
   - Content Opportunity of the Day
   - Recommended Reading (2-3 articles)
   - Focus Suggestion

6. **Save Output**
   - Write to `outputs/daily/{date}-brief.md`

7. **Sync to Notion**
   - Create entry in "POS: Daily Briefs" database
   - Set status to "Generated"

## Output Format

```markdown
# Daily Brief: {date}
**Generated**: {timestamp}

## Good Morning, Enrique

### Must-Know Today
{3-5 critical updates from overnight}

### Metrics Snapshot
- LinkedIn followers: {count} ({change})
- Newsletter subscribers: {count} ({change})
- Content published this week: {count}

### Priority Tasks
{Pulled from Notion Tasks if enabled}

### Content Opportunity of the Day
**Topic**: {topic}
**Why now**: {relevance}
**Suggested angle**: {angle}

### Recommended Reading
1. [{title}]({url}) - {why it matters}
2. [{title}]({url}) - {why it matters}

### Focus Suggestion
{AI recommendation for today's priority}
```

## Sub-Agent

This command uses the `intelligence-researcher` sub-agent in lightweight mode.
See `sub-agents/intelligence-researcher.md` for detailed behavior.

## Automation

This command is designed to run automatically via cron:

```bash
# Daily brief at 6:00 AM
0 6 * * * cd /path/to/PersonalOS && claude "/daily-brief"
```

See `scripts/cron/daily-brief.sh` for the automation script.

## Example Output Location

`outputs/daily/2026-01-06-brief.md`

## Notion Database

Database: "POS: Daily Briefs"
ID: Found in `config/notion-mapping.yaml` under `databases.daily_briefs`

Properties to populate:
- Date: Current date (title)
- Generated: Timestamp
- Priority Updates: Top insights
- Content Opportunity: Today's topic suggestion
- Full Brief: Complete markdown content
- Status: "Generated"

## Personalization

The brief includes personalization based on:
- User context from CLAUDE.md
- Current goals from config/goals.yaml
- Content pillars from topics.yaml
- Recent content performance (future)

## Performance Target

- < 2 minutes for standard brief
- < 1 minute for quick brief

## Best Practices

1. Run first thing in the morning
2. Review and mark as "Reviewed" in Notion
3. Flag any items that need deeper analysis
4. Use Content Opportunity to guide daily content focus

## Post-Execution: Update STATUS.md

After completing this command, update `STATUS.md`:
1. Set **Last Command** to `/daily-brief`
2. Set **Last Output** to the output file path
3. Add entry to **Activity Log** table:
   - Date: Current date
   - Command: /daily-brief
   - Output: outputs/daily/{date}-brief.md
   - Notes: Brief summary (e.g., "5 insights, 1 content opportunity")
4. Rotate out activity log entries older than 30 days
