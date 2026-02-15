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

- `--timeframe`: How far back to scan (default: "24h") — `24h`, `48h`, `week`
- `--depth`: Scan depth (default: "standard") — `quick` (top 5 high-priority), `standard` (high + medium), `deep` (all sources)
- `--topics`: Override default topics (comma-separated)
- `--no-real-time`: Skip Perplexity queries, use only configured sources
- `--force-fresh`: Ignore Perplexity cache and fetch fresh data
- `--deep [topic]`: Enable deep research mode using sonar-deep-research
  - Without value: Smart-pick hottest topic from scan results, ask for confirmation
  - With value: Use specified topic directly
  - Uses separate budget cap ($20/month default)

## Orchestration Flow

**IMPORTANT**: Perplexity calls run at orchestrator level (sub-agents don't have MCP access).

```
Orchestrator                     →     intelligence-agent
─────────────────────────────────────────────────────────
1. Parse parameters (incl. --no-real-time, --deep)
2. Load configs (topics, sources, research, notion-mapping)
3. Filter sources by depth
4-6. Perplexity: cache check → MCP calls → write cache + usage
7. Construct agent input (incl. perplexity_results)
                                 →    8-11. Scan sources, synthesize, return JSON
12. Receive + validate JSON      ←
13. [IF --deep] Deep research (see Step 5.5)
14. Format markdown
15. Write files + agent log
16. Auto-add discovered sources
17. Sync to Notion (sync-agent)
```

## Execution Steps

### Step 1: Load Configuration

Read: `config/topics.yaml`, `config/sources.yaml`, `config/notion-mapping.yaml`, `config/research.yaml` (if exists, else `perplexity_enabled: false`).

### Step 2: Filter Sources

- `quick`: priority == "high" (max 5)
- `standard`: priority in ["high", "medium"]
- `deep`: all sources

### Step 2.5: Real-Time Discovery (Perplexity)

Skip if: `--no-real-time`, research.yaml missing/disabled, or budget exceeded.

Follow **Cache Check** in `perplexity-procedures.md` with `cache_key = {YYYY-MM-DD}-{depth}-market-intel`.

**Build Dynamic Queries from Topics**:
1. Extract primary topic names from topics.yaml, join with commas
2. Load query templates from research.yaml (`breaking_news`, `trend_discovery`)
3. Call `mcp__perplexity__perplexity_search` for breaking news
4. Call `mcp__perplexity__perplexity_reason` for trend discovery (standard/deep only)

Follow **Cache Write** and **Usage Update (Regular)** in `perplexity-procedures.md`.

Prepare `perplexity_results` using **Results Format** from `perplexity-procedures.md`.

### Step 3: Construct Agent Input

```json
{
  "mode": "full",
  "timeframe": "{parameter or '48h'}",
  "depth": "{parameter or 'standard'}",
  "today_date": "{YYYY-MM-DD}",
  "topics": [/* from topics.yaml */],
  "sources": [/* filtered */],
  "perplexity_results": {/* from Step 2.5, or null */}
}
```

### Step 4: Invoke Intelligence Agent

Follow **Agent Invocation** in `agent-execution-guide.md` with:
- Agent: `intelligence-agent`, Model: `sonnet`
- Include in prompt: "CRITICAL: Use Firecrawl MCP for all web scraping. Perplexity results are pre-fetched - use them directly, do NOT call Perplexity MCP."

Validate output per `agent-execution-guide.md` → **JSON Validation** against `schemas.json → agents.intelligence-agent`.

Required fields: `insights` (array), `trends` (array), `content_opportunities` (array), `sources_scanned` (int), `scan_timestamp`, `scan_metadata` (with `degraded_mode`).

### Step 5.5: Deep Research (IF --deep flag)

#### Determine Topic
- If `--deep "Topic"`: use directly
- If `--deep` without value: Analyze agent output — count topic mentions across insights, weight by priority (High=3, Med=2, Low=1), present top pick via AskUserQuestion with options: Use suggested / Enter different / Skip

#### Budget & Execution
Follow **Budget Check (Deep Research)** in `perplexity-procedures.md`.

Execute: Call `mcp__perplexity__perplexity_research` with query template from research.yaml, `strip_thinking: true`.

Parse response into: executive_summary, market_landscape, key_players, emerging_patterns, strategic_implications, sources.

Follow **Usage Update (Deep Research)** in `perplexity-procedures.md`.

### Step 6: Format Markdown Output

```markdown
# Market Intelligence Brief

## Report Metadata
| Field | Value |
|-------|-------|
| **Generated** | {timestamp} |
| **Report Type** | market-intelligence |
| **Timeframe** | {timeframe} |
| **Depth** | {depth} |
| **Status** | {degraded_mode ? "degraded" : "success"} |
| **Sources Scanned** | {sources_scanned} |
| **Real-Time** | {real_time_intelligence.status} |
| **Deep Research** | {deep_research.enabled ? topic : "none"} |
| **Perplexity Budget** | Regular: ${used}/${limit} | Deep: ${used}/${limit} |

---

{If deep_research.enabled:}
## Deep Research: {topic}
> **Cost**: ~${cost} | **Budget**: ${used}/${limit} ({pct}% used)
### Executive Summary
{executive_summary}
### Market Landscape
{market_landscape}
### Key Players & Developments
{key_players}
### Emerging Patterns
{emerging_patterns}
### Strategic Implications
{strategic_implications}
### Deep Research Sources
| Source | URL |
|--------|-----|
{sources table}

---

{Status banners per perplexity-procedures.md}

## Real-Time Intelligence
{If status == "success":}
**Budget Remaining**: {pct}% | **Queries Used**: {n} | **Cache Hits**: {n}

### Breaking News (Last 48h)
{For each: title, summary, sources as inline links}

### Trend Signals
| Trend | Evidence | Trajectory |
{trend_signals table}

### Sources Discovered
| Source | Category | Action | Reason |
{sources_discovered with action emoji: ✅ added, ⏭️ skipped_limit, 🔄 skipped_duplicate}

---

## Priority Updates
{For each High priority insight: title, source link, topics, summary, content angle}

## Trend Analysis
{For each trend: name, trajectory, evidence bullets, opportunity}

## Content Opportunities
| Priority | Topic | Angle | Pillar |
{sorted by urgency}

## All Insights
{Medium/Low insights as bullet list}

---

## Sources
| Source | URL | Type |
{all unique sources}

{If sources_failed:}
### Failed Sources
| Source | Error |

---
*Generated by PersonalOS | intelligence-agent | {date}*
```

### Step 7: Write Output Files

- Markdown: `2-research/market-briefs/{YYYY-MM-DD}-{HHMM}-market-brief{-deep-{slug}}.md`
- Agent log: `system/logs/{YYYY-MM-DD}-{HHMM}-intelligence-agent.json`

### Step 7.5: Process Discovered Sources

If `sources_discovered` has entries with `action: "added"`:
- Read `config/sources.yaml`, append new entries with `added_by: "perplexity"`, `added_date`, `priority: "medium"`
- Write updated sources.yaml

### Step 8: Sync to Notion

Follow **Sync-Agent: Write** in `agent-execution-guide.md` for each High-priority insight:
- Database: `market_intelligence`
- Properties: Title, Date, Priority, Topics, Source, Summary, Content Potential, Status: "New", Deep Research: "__YES__" or "__NO__"

## Error Handling

- Intelligence-agent fails: report error to user
- Sync-agent fails: save locally, note "Notion sync failed"
- \>50% sources failed: add `> ⚠️ **LIMITED INTELLIGENCE**` banner with failed source list
- Always produce output with partial data

## Agent Reference

- **Intelligence Agent**: `.claude/agents/intelligence-agent.md`
- **Sync Agent**: `.claude/agents/sync-agent.md`
