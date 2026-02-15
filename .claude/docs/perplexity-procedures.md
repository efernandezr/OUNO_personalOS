# Perplexity Procedures

Shared procedures for Perplexity integration. Commands reference these with their specific parameters.

## Cache Check

Parameters: `{cache_key}`, `{ttl_hours}` (from research.yaml), `{force_fresh}` flag

1. Check for file: `system/cache/perplexity/queries/{cache_key}.json`
2. If file exists AND timestamp < `{ttl_hours}` old AND NOT `{force_fresh}`:
   - Read cached results, set `from_cache: true`, skip to Results Format
3. Otherwise: proceed to Perplexity MCP calls

## Budget Check (Regular)

1. Read `system/cache/perplexity/usage.yaml`
2. Read limits from `config/research.yaml` → `budget.monthly_limit_usd`
3. Calculate: `pct_used = (regular.estimated_cost_usd / monthly_limit_usd) * 100`
4. If `pct_used >= 100`: skip Perplexity, set status `budget_exceeded`
5. If `pct_used >= alert_threshold_pct`: log warning but proceed

## Budget Check (Deep Research)

1. Read `system/cache/perplexity/usage.yaml` → `deep_research.estimated_cost_usd`
2. Read limits from `config/research.yaml` → `budget.deep_research.monthly_limit_usd`
3. Calculate: `pct_used = (estimated_cost_usd / monthly_limit_usd) * 100`
4. **If pct_used >= 100%**: Show error, exit deep research
5. **If pct_used >= alert_threshold (default 50%)**: Require user confirmation via AskUserQuestion
6. **If pct_used < threshold**: Show info message, proceed automatically

## Usage Update (Regular)

After Perplexity calls, update `system/cache/perplexity/usage.yaml`:
```yaml
current_month: "{YYYY-MM}"
regular:
  queries_count: {increment by queries used}
  estimated_cost_usd: {add ~$0.005 per search, ~$0.02 per reason}
  last_updated: "{ISO timestamp}"
total_cost_usd: {regular + deep_research costs}
budget_exceeded: {true if regular cost >= limit}
```

## Usage Update (Deep Research)

```yaml
deep_research:
  queries_count: {increment by 1}
  estimated_cost_usd: {add ~$3-5 based on response length}
  last_updated: "{ISO timestamp}"
  history:
    - date: "{today}"
      topic: "{topic}"
      cost: {estimated cost}
total_cost_usd: {regular + deep_research costs}
deep_research_budget_exceeded: {true if deep cost >= limit}
```

## Cache Write

Write results to `system/cache/perplexity/queries/{cache_key}.json`:
```json
{
  "timestamp": "{ISO timestamp}",
  "ttl_hours": {ttl_hours},
  "query_type": "{command name}",
  "depth": "{depth}",
  "results": { "breaking_news": [], "trend_signals": [] }
}
```

## Perplexity Results Format

Standard JSON structure passed to agents:
```json
{
  "perplexity_results": {
    "status": "success | from_cache | skipped | budget_exceeded | not_configured",
    "breaking_news": [],
    "trend_signals": [],
    "queries_used": 0,
    "from_cache": true | false,
    "budget_remaining_pct": 85
  }
}
```

## Status Banners

Use in markdown output based on `real_time_intelligence.status`:

- **not_configured**: `> ℹ️ **REAL-TIME INTELLIGENCE NOT CONFIGURED** → Run: ./scripts/enable-perplexity.sh`
- **budget_exceeded**: `> ⚠️ **PERPLEXITY BUDGET EXCEEDED** → Monthly budget reached, resets next month.`
- **error**: `> ⚠️ **REAL-TIME INTELLIGENCE UNAVAILABLE** → {status_reason}. Proceeding with configured sources.`

## Cost Reference

| Tool | MCP Function | Est. Cost |
|------|-------------|-----------|
| Search | `mcp__perplexity__perplexity_search` | ~$0.005/query |
| Reason | `mcp__perplexity__perplexity_reason` | ~$0.02/query |
| Deep Research | `mcp__perplexity__perplexity_research` | ~$3-5/query |
