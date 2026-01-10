---
description: Get the latest AI marketing trends and insights from your curated sources
---

# /market-intelligence

Scan configured sources for AI marketing insights, trends, and developments.

## Usage

```
/market-intelligence [options]
```

## Parameters (Optional)

- `--timeframe`: How far back to scan (default: "24h")
  - `24h` - Last 24 hours
  - `48h` - Last 48 hours
  - `week` - Last 7 days

- `--depth`: Scan depth (default: "standard")
  - `quick` - Top 5 high-priority sources only
  - `standard` - All high and medium priority sources
  - `deep` - All sources including low priority

- `--topics`: Override default topics (comma-separated)

- `--no-real-time`: Skip Perplexity queries, use only configured sources
  - Use when you want faster execution without real-time discovery
  - Budget is not consumed when this flag is set

- `--force-fresh`: Ignore Perplexity cache and fetch fresh data
  - Use sparingly as it consumes more budget
  - Only affects Perplexity queries, not Firecrawl

## Orchestration Pattern

This command uses **Task tool delegation** to the `intelligence-agent`.

```
Orchestrator (this command)     →     intelligence-agent
─────────────────────────────────────────────────────────
1. Parse parameters (incl. --no-real-time)
2. Load configs (topics, sources, research)
3. Filter sources by depth
4. Construct agent input
                                 →    5. Phase 0: Config check
                                 →    6. Phase 1: Real-time discovery (Perplexity)
                                 →    7. Phase 2: Scan sources (Firecrawl)
                                 →    8. Phase 3: Synthesis
                                 →    9. Return JSON
10. Receive JSON output          ←
11. Format markdown (incl. Real-Time Intelligence)
12. Write files
13. Auto-add discovered sources
14. Sync to Notion (sync-agent)
15. Update STATUS.md
```

## Tool Enforcement

When invoking the intelligence-agent via Task tool:
- **Perplexity MCP** for real-time discovery (if configured and enabled)
- **Firecrawl MCP is REQUIRED** for web scraping (`mcp__firecrawl__firecrawl_scrape`)
- **WebSearch is NOT acceptable** as the primary scanning tool
- The agent MUST track tool usage in `scan_metadata` output field
- If `degraded_mode: true` in output, surface this warning to user
- If `real_time_intelligence.status` is not "success", surface the reason to user

Include this reminder in the agent prompt:
> "CRITICAL: Use Firecrawl MCP for all web scraping. Use Perplexity for discovery if configured. See Tool Selection Rules in agent definition."

## Execution Steps

### Step 1: Load Configuration (Orchestrator)

Read these config files:
- `config/topics.yaml` - Extract topics array with name, priority, keywords
- `config/sources.yaml` - Extract sources array with url, type, priority, focus
- `config/notion-mapping.yaml` - Get `databases.market_intelligence` ID
- `config/research.yaml` - Get Perplexity settings (if exists)
  - If file doesn't exist, set `perplexity_enabled: false`
  - Extract: `enabled`, `budget.monthly_limit_usd`, `cache.ttl_hours`, `queries.max_queries_per_market_intel`

### Step 2: Prepare Agent Input (Orchestrator)

Filter sources by depth parameter:
- `quick`: Only sources where priority == "high" (max 5)
- `standard`: Sources where priority in ["high", "medium"]
- `deep`: All sources

Construct input JSON:
```json
{
  "mode": "full",
  "timeframe": "{from parameter or '48h'}",
  "depth": "{from parameter or 'standard'}",
  "no_real_time": "{true if --no-real-time flag set, else false}",
  "force_fresh": "{true if --force-fresh flag set, else false}",
  "topics": [/* from topics.yaml */],
  "sources": [/* filtered from sources.yaml */],
  "research_config": {
    "perplexity_enabled": "{from research.yaml or false}",
    "budget_limit_usd": "{from research.yaml or 25.00}",
    "cache_ttl_hours": "{from research.yaml or 24}",
    "max_queries": "{from research.yaml or 5}"
  }
}
```

### Step 3: Invoke Intelligence Agent (Task Tool)

```
Task tool call:
  - description: "Scan market intelligence sources"
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - prompt: |
      You are the intelligence-agent for PersonalOS.

      [Read and include full content of .claude/agents/intelligence-agent.md]

      ## Your Task

      Execute a market intelligence scan with this input:

      ```json
      {input JSON from Step 2}
      ```

      Return your response as valid JSON matching the output schema in the agent definition.
```

### Step 4: Process Agent Output (Orchestrator)

The agent returns JSON with:
- `real_time_intelligence` - Perplexity results (if enabled)
  - `status` - "success", "skipped", "not_configured", "budget_exceeded", or "error"
  - `breaking_news[]` - Real-time news items
  - `trend_signals[]` - Emerging trends
  - `sources_discovered[]` - New sources found
  - `budget_remaining_pct` - Remaining budget percentage
- `insights[]` - Scored and prioritized findings
- `trends[]` - Cross-source patterns
- `content_opportunities[]` - Actionable content ideas
- `sources_scanned` - Count
- `sources_failed[]` - URLs that failed
- `scan_metadata` - Tool usage tracking (verify `primary_tool: "firecrawl"`)

### Step 5: Format Markdown Output (Orchestrator)

Transform JSON into markdown format:

```markdown
# Market Intelligence Brief

## Report Metadata
| Field | Value |
|-------|-------|
| **Generated** | {timestamp} |
| **Report Type** | market-intelligence |
| **Timeframe** | {timeframe} |
| **Status** | {scan_metadata.degraded_mode ? "degraded" : "success"} |
| **Sources Scanned** | {sources_scanned} |
| **Real-Time** | {real_time_intelligence.status} |

---

{If real_time_intelligence.status == "not_configured":}
> ℹ️ **REAL-TIME INTELLIGENCE NOT CONFIGURED**
> To enable breaking news and trend discovery, run: `./scripts/enable-perplexity.sh`

{If real_time_intelligence.status == "budget_exceeded":}
> ⚠️ **PERPLEXITY BUDGET EXCEEDED**
> Monthly budget of ${budget_limit_usd} reached. Real-time intelligence disabled.
> Budget resets at the start of next month.

{If real_time_intelligence.status == "error":}
> ⚠️ **REAL-TIME INTELLIGENCE UNAVAILABLE**
> {real_time_intelligence.status_reason}
> Proceeding with configured sources only.

## Real-Time Intelligence

{If real_time_intelligence.status == "success":}
**Budget Remaining**: {budget_remaining_pct}% | **Queries Used**: {queries_used} | **Cache Hits**: {cache_hits}

### Breaking News (Last 48h)

{For each breaking_news item:}
#### {title}
{summary}

**Sources**: {For each source in sources: [{source.name}]({source.url}), }

---

### Trend Signals

| Trend | Evidence | Trajectory |
|-------|----------|------------|
{For each trend_signal:}
| {trend} | {evidence_count} sources | {trajectory} |

### Sources Discovered

| Source | Category | Action | Reason |
|--------|----------|--------|--------|
{For each sources_discovered:}
| [{name}]({url}) | {category} | {action emoji} | {reason} |

{action emoji: added = ✅, skipped_limit = ⏭️, skipped_duplicate = 🔄}

---

## Priority Updates

{For each insight where priority == "High":}
### {title}
**Source**: [{source.name}]({source.url})
**Topics**: {topics joined}

{summary}

**Content Angle**: {suggested_angle}

---

## Trend Analysis

{For each trend:}
### {name} ({trajectory})
{evidence as bullet points}

**Opportunity**: {content_opportunity}

## Content Opportunities

| Priority | Topic | Angle | Pillar |
|----------|-------|-------|--------|
{For each content_opportunity, sorted by urgency}

## All Insights

{For each insight where priority in ["Medium", "Low"]:}
- **[{priority}]** [{title}]({source.url}) - {summary truncated to 100 chars}

---

## Sources

All sources referenced in this report:

| Source | URL | Type |
|--------|-----|------|
{For each unique source in all insights + breaking_news:}
| {source.name} | [{source.url}]({source.url}) | {source.type or "firecrawl"} |

{If sources_failed not empty:}
### Failed Sources

| Source | Error |
|--------|-------|
{For each failed in sources_failed:}
| {failed.url} | {failed.reason} |

---

*Generated by PersonalOS | intelligence-agent | {date}*
```

### Step 6: Write Output Files (Orchestrator)

1. Create output directory if needed: `2-research/market-briefs/`
2. Write markdown to: `2-research/market-briefs/{YYYY-MM-DD}-{HHMM}-market-brief.md`
   - Include timestamp (24h format) to preserve multiple scans per day
   - Example: `2026-01-10-1430-market-brief.md`
3. Write agent log to: `system/logs/{YYYY-MM-DD}-{HHMM}-intelligence-agent.json`
   - Include: input, output, timestamp, duration

### Step 6.5: Process Discovered Sources (Orchestrator)

If `real_time_intelligence.sources_discovered` contains entries with `action: "added"`:

1. Read current `config/sources.yaml`
2. For each source with `action: "added"`:
   - Add entry to sources.yaml:
     ```yaml
     - name: "{name}"
       url: "{url}"
       type: "{category}"
       priority: "medium"
       focus: []
       added_by: "perplexity"
       added_date: "{today}"
       discovery_context: "{reason}"
     ```
3. Write updated sources.yaml
4. Log additions to output

### Step 7: Sync to Notion (Orchestrator → sync-agent)

For each insight where priority == "High":

```
Task tool call:
  - description: "Sync insight to Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      [Read and include content of .claude/agents/sync-agent.md]

      ## Your Task

      Write this entry to Notion:

      ```json
      {
        "operation": "write",
        "database": "market_intelligence",
        "database_id": "{from notion-mapping.yaml}",
        "data": {
          "properties": {
            "Title": "{insight.title}",
            "Date": "{today}",
            "Priority": "{insight.priority}",
            "Topics": {insight.topics},
            "Source": "{insight.source_url}",
            "Summary": "{insight.summary}",
            "Content Potential": "{insight.content_potential}",
            "Status": "New"
          }
        }
      }
      ```
```

### Step 8: Update STATUS.md (Orchestrator)

1. Set **Last Command** to `/market-intelligence`
2. Set **Last Output** to `2-research/market-briefs/{date}-market-brief.md`
3. Add entry to **Activity Log** table:
   - Date: Current date
   - Command: /market-intelligence
   - Output: 2-research/market-briefs/{date}-market-brief.md
   - Notes: Summary (e.g., "Standard scan, {sources_scanned} sources, {insights.length} insights")

## Agent Reference

- **Intelligence Agent**: `.claude/agents/intelligence-agent.md`
- **Sync Agent**: `.claude/agents/sync-agent.md`

## Error Handling

- If intelligence-agent fails completely, report error to user
- If sync-agent fails, save locally and note "Notion sync failed" in output
- If >50% sources failed, add warning banner to output
- Always produce output even with partial data

## Retry Configuration

### Firecrawl Operations (via intelligence-agent)
```yaml
max_retries: 3
backoff:
  initial: 1000  # 1 second
  multiplier: 2  # exponential: 1s, 2s, 4s
  max: 4000      # 4 seconds max
retry_on:
  - connection_error
  - timeout
  - status_5xx
  - rate_limit (429)
dont_retry_on:
  - status_4xx (except 429)
  - invalid_url
  - access_denied
```

### Notion Sync Operations (via sync-agent)
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

### Retry Pattern for Agent Invocation

If intelligence-agent Task tool call fails:
1. Log the error
2. Wait `backoff.initial * (backoff.multiplier ^ attempt)` milliseconds
3. Retry the Task tool call (up to max_retries)
4. If all retries fail, proceed to partial results handling

## JSON Validation

After receiving agent output, validate against schema before processing.

### Schema Reference
```
.claude/utils/schemas.json → agents.intelligence-agent
```

### Validation Steps

1. **Parse JSON**: If agent returns malformed JSON:
   - Log parsing error
   - Retry agent invocation with note: "Previous response was not valid JSON. Return valid JSON only."
   - Max 2 parse retries before failing

2. **Validate required fields**: Check these exist:
   - `insights` (array)
   - `trends` (array)
   - `content_opportunities` (array)
   - `sources_scanned` (integer)
   - `scan_timestamp` (ISO string)
   - `scan_metadata` (object with `degraded_mode`)

3. **Validate field types**: Use schema to verify:
   - `insights[].priority` is one of ["High", "Medium", "Low"]
   - `insights[].source_url` is valid URI format
   - `trends[].trajectory` is one of ["rising", "stable", "declining"]

4. **Handle validation failures**:
   - If critical field missing: retry agent invocation with specific feedback
   - If non-critical field wrong type: log warning, continue with default
   - Max 2 validation retries before proceeding with partial data

### Validation Error Response

If validation fails after retries, create partial output:
```markdown
> ⚠️ **DATA QUALITY WARNING**
> Agent output had validation issues: {list specific issues}
> Some sections may be incomplete or missing.
```

## Partial Results Handling

If any operation fails during execution, follow this partial results pattern:

### Scenario: Intelligence Agent Returns Partial Data

If agent returns some valid data but has issues:
1. Extract and use valid portions
2. Add banner to output indicating partial results
3. Log what failed in agent log file

Example banner:
```markdown
> ⚠️ **PARTIAL RESULTS**
> - Sources scanned: 8/12 (4 failed)
> - Trend analysis: Incomplete (insufficient source coverage)
> - See Source Log for failed sources
```

### Scenario: Notion Sync Fails

If sync-agent fails after retries:
1. Continue with local file save (already completed)
2. Add note to output:
```markdown
**Notion Sync**: ❌ Failed after 3 retries. Saved locally only.
Run `/sync-status` later to retry sync.
```
3. Log sync failure to `system/logs/{date}-sync-errors.json`

### Scenario: More than 50% Sources Failed

Add prominent warning:
```markdown
> ⚠️ **LIMITED INTELLIGENCE**
> {failed_count}/{total_count} sources failed to respond.
> Results may be incomplete. Consider running again later.
>
> **Failed Sources**:
> - {source_name}: {error_reason}
```

### Error Log Format

Write errors to `system/logs/{YYYY-MM-DD}-market-intelligence-errors.json`:
```json
{
  "command": "/market-intelligence",
  "timestamp": "ISO date",
  "errors": [
    {
      "phase": "agent_invocation" | "validation" | "notion_sync",
      "attempt": 1,
      "error": "error message",
      "resolved": true | false
    }
  ],
  "partial_results": true | false,
  "recovery_actions": ["description of what was recovered"]
}
```

## Example Output Location

`2-research/market-briefs/2026-01-08-1430-market-brief.md`

## Performance Target

- Standard depth: < 3 minutes
- Quick depth: < 1 minute
- Deep depth: < 5 minutes
