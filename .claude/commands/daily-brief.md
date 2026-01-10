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

- `--no-real-time`: Skip Perplexity queries, use only configured sources
  - Use when you want faster execution without real-time discovery
  - Budget is not consumed when this flag is set

- `--force-fresh`: Ignore Perplexity cache and fetch fresh data
  - Use sparingly as it consumes more budget
  - Only affects Perplexity queries, not Firecrawl

## Orchestration Pattern

This command uses **Task tool delegation** to the `intelligence-agent` in quick mode.

```
Orchestrator (this command)     →     intelligence-agent
─────────────────────────────────────────────────────────
1. Parse parameters (incl. --no-real-time)
2. Load configs (topics, sources, research)
3. Filter high-priority sources only
4. Construct quick-mode input
                                 →    5. Phase 0: Config check
                                 →    6. Phase 1: Breaking news (Perplexity, max 2 queries)
                                 →    7. Phase 2: Quick scan (Firecrawl)
                                 →    8. Phase 3: Synthesis
                                 →    9. Return JSON
10. Receive JSON output          ←
11. Query Notion todos (optional)
12. Generate content opportunity
13. Format brief markdown (incl. What's Breaking)
14. Write files
15. Sync to Notion (sync-agent)
16. Update STATUS.md
```

## Tool Enforcement

When invoking the intelligence-agent via Task tool:
- **Perplexity MCP** for breaking news discovery (if configured and enabled)
- **Firecrawl MCP is REQUIRED** for web scraping (`mcp__firecrawl__firecrawl_scrape`)
- **WebSearch is NOT acceptable** as the primary scanning tool
- The agent MUST track tool usage in `scan_metadata` output field
- If `degraded_mode: true` in output, surface this warning to user
- If `real_time_intelligence.status` is not "success", surface the reason to user

Include this reminder in the agent prompt:
> "CRITICAL: Use Firecrawl MCP for all web scraping. Use Perplexity for breaking news if configured (max 2 queries). See Tool Selection Rules in agent definition."

## Execution Steps

### Step 1: Load Configuration (Orchestrator)

Read these config files:
- `config/topics.yaml` - Get priority topics and content pillars
- `config/sources.yaml` - Filter for high-priority sources only (max 5)
- `config/notion-mapping.yaml` - Get database IDs
- `config/goals.yaml` - Get current metrics targets
- `config/research.yaml` - Get Perplexity settings (if exists)
  - If file doesn't exist, set `perplexity_enabled: false`
  - Extract: `enabled`, `budget.monthly_limit_usd`, `cache.ttl_hours`, `queries.max_queries_per_daily_brief`

### Step 2: Invoke Intelligence Agent - Quick Mode (Task Tool)

```
Task tool call:
  - description: "Quick market intelligence scan for daily brief"
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - prompt: |
      You are the intelligence-agent for PersonalOS.

      [Read and include full content of .claude/agents/intelligence-agent.md]

      ## Your Task

      Execute a QUICK market intelligence scan (for daily brief):

      ```json
      {
        "mode": "quick",
        "timeframe": "24h",
        "depth": "quick",
        "no_real_time": "{true if --no-real-time flag set, else false}",
        "force_fresh": "{true if --force-fresh flag set, else false}",
        "topics": [/* from topics.yaml - primary only */],
        "sources": [/* from sources.yaml - high priority only, max 5 */],
        "research_config": {
          "perplexity_enabled": "{from research.yaml or false}",
          "budget_limit_usd": "{from research.yaml or 25.00}",
          "cache_ttl_hours": "{from research.yaml or 24}",
          "max_queries": "{from research.yaml queries.max_queries_per_daily_brief or 2}"
        }
      }
      ```

      CRITICAL: Use Perplexity for breaking news if configured (max 2 queries). Use Firecrawl MCP for all web scraping.

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

## Report Metadata
| Field | Value |
|-------|-------|
| **Generated** | {timestamp} |
| **Report Type** | daily-brief |
| **Status** | {scan_metadata.degraded_mode ? "degraded" : "success"} |
| **Real-Time** | {real_time_intelligence.status} |

---

{If real_time_intelligence.status == "not_configured":}
> ℹ️ **REAL-TIME INTELLIGENCE NOT CONFIGURED**
> To enable breaking news detection, run: `./scripts/enable-perplexity.sh`

{If real_time_intelligence.status == "budget_exceeded":}
> ⚠️ **PERPLEXITY BUDGET EXCEEDED**
> Monthly budget reached. Real-time intelligence disabled until next month.

{If real_time_intelligence.status == "error":}
> ⚠️ **REAL-TIME INTELLIGENCE UNAVAILABLE**
> {real_time_intelligence.status_reason}

## Good Morning, Enrique

{If real_time_intelligence.status == "success" and breaking_news not empty:}
### 🔴 What's Breaking (Last 48h)

{For each breaking_news item[:3]:}
**{title}**
{summary}
**Sources**: {For each source in sources: [{source.name}]({source.url}), }

---

### Must-Know Today

{For each insight from agent where priority in ["High", "Medium"][:5]:}
- **{title}**: {summary truncated to 150 chars} [→]({source.url})

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
1. [{title}]({source.url}) - {suggested_angle}

### Focus Suggestion
Based on today's intelligence: {generate 1-2 sentence recommendation}

---

## Sources

All sources referenced in this brief:

| Source | URL | Type |
|--------|-----|------|
{For each unique source in insights + breaking_news:}
| {source.name} | [{source.url}]({source.url}) | {source.type or "firecrawl"} |

---

*Generated by PersonalOS | intelligence-agent (quick mode) | {date}*
```

### Step 6: Write Output File (Orchestrator)

1. Create directory if needed: `2-research/daily-briefs/`
2. Write to: `2-research/daily-briefs/{YYYY-MM-DD}-{HHMM}-brief.md`
   - Include timestamp to preserve multiple briefs per day
3. Write agent log to: `system/logs/{YYYY-MM-DD}-{HHMM}-daily-brief-agent.json`

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
2. Set **Last Output** to `2-research/daily-briefs/{date}-brief.md`
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

`2-research/daily-briefs/2026-01-08-brief.md`

## Retry Configuration

### Intelligence Agent (Quick Mode)
```yaml
max_retries: 3
backoff:
  initial: 1000  # 1 second
  multiplier: 2  # exponential: 1s, 2s, 4s
  max: 4000
retry_on:
  - connection_error
  - timeout
  - firecrawl_error
dont_retry_on:
  - invalid_input
```

### Notion Operations
```yaml
max_retries: 3
backoff:
  initial: 2000
  multiplier: 2
  max: 8000
retry_on:
  - connection_error
  - timeout
  - status_5xx
dont_retry_on:
  - authentication_error
```

## JSON Validation

### Schema Reference
```
.claude/utils/schemas.json → agents.intelligence-agent
```

### Required Fields (Quick Mode)
- `real_time_intelligence.status` (enum: success, skipped, not_configured, budget_exceeded, error)
- `insights` (array, minimum 1)
- `content_opportunities` (array)
- `sources_scanned` (integer)
- `scan_metadata.degraded_mode` (boolean)

### Real-Time Intelligence Fields (if status == "success")
- `real_time_intelligence.breaking_news[]` (array of news items)
- `real_time_intelligence.queries_used` (integer, should be ≤2)
- `real_time_intelligence.budget_remaining_pct` (number)

### Validation Notes
- Quick mode may return fewer insights - this is acceptable
- Quick mode uses max 2 Perplexity queries (vs 5 for /market-intelligence)
- Validate but be lenient on optional fields
- Log warnings, don't fail on non-critical issues

## Partial Results Handling

### Scenario: Intelligence Agent Fails Completely
Generate minimal brief with warning:
```markdown
# Daily Brief: {date}

> ⚠️ **INTELLIGENCE UNAVAILABLE**
> Could not scan sources. Using cached recommendations.

### Metrics Snapshot
{from goals.yaml}

### Focus Suggestion
Review yesterday's brief for pending opportunities.
```

### Scenario: Some Sources Failed
Add note but continue:
```markdown
> ℹ️ Scanned {success}/{total} sources. Some sources unavailable.
```

### Scenario: Notion Sync Fails
Save locally, note in brief:
```markdown
**Sync Status**: Saved locally (Notion unavailable)
```

### Scenario: No Tasks (when --include-todos)
Omit section gracefully - no error, just skip.

## Performance Target

- Quick: < 1 minute
- Standard: < 2 minutes
- Comprehensive: < 3 minutes

## Automation

Designed to run via cron at 6:00 AM:
```bash
0 6 * * * cd /path/to/PersonalOS && claude "/daily-brief"
```
