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

## Execution Steps

1. **Load Configuration**
   - Read `config/topics.yaml` for topics to monitor
   - Read `config/sources.yaml` for sources to scan
   - Read `config/notion-mapping.yaml` for database ID

2. **Prepare Source List**
   - Filter sources by depth parameter
   - Order by priority (high first)

3. **Scan Sources**
   For each source:
   - Use Firecrawl MCP to scrape content (preferred)
   - Fallback to WebFetch if Firecrawl unavailable
   - Extract recent articles/posts within timeframe
   - Note: Some sources may fail - continue with available data

4. **Analyze Content**
   For each piece of content:
   - Score relevance against configured topics
   - Assign priority (High/Medium/Low)
   - Extract key insights
   - Identify content opportunities

5. **Synthesize Brief**
   Generate structured markdown output with:
   - Priority Updates (critical items)
   - Trend Analysis (patterns across sources)
   - Content Opportunities (topics for your content)
   - Actionable Insights (specific recommendations)
   - Source Log (all referenced links)

6. **Save Output**
   - Write to `outputs/intelligence/{date}-market-brief.md`
   - Log execution to `logs/{date}-market-intelligence.log`

7. **Sync to Notion**
   - Create entries in "POS: Market Intelligence" database
   - One entry per high-priority insight
   - Include: Title, Date, Priority, Topics, Source, Summary

## Output Format

```markdown
# Market Intelligence Brief
**Generated**: {timestamp}
**Timeframe**: {timeframe}
**Sources Scanned**: {count}

## Priority Updates
{High-impact news requiring immediate attention}

## Trend Analysis
{Emerging patterns across sources}

## Content Opportunities
{Topics with high engagement potential for your audience}

## Actionable Insights
{Specific recommendations for content or positioning}

## Source Log
{Links to all referenced materials}
```

## Sub-Agent

This command uses the `intelligence-researcher` sub-agent.
See `sub-agents/intelligence-researcher.md` for detailed behavior.

## Error Handling

- If a source fails to scrape, log the error and continue
- If Firecrawl is unavailable, fall back to WebFetch/WebSearch
- If Notion sync fails, save locally and note the failure
- Always produce output even with partial data

## Example Output Location

`outputs/intelligence/2026-01-06-market-brief.md`

## Notion Database

Database: "POS: Market Intelligence"
ID: Found in `config/notion-mapping.yaml` under `databases.market_intelligence`

Properties to populate:
- Title: Insight headline
- Date: Current date
- Priority: High/Medium/Low
- Topics: Relevant topics
- Source: URL
- Summary: Brief description
- Content Potential: High/Medium/Low
- Status: "New"

## Performance Target

- Standard depth: < 3 minutes
- Quick depth: < 1 minute
- Deep depth: < 5 minutes

## Post-Execution: Update STATUS.md

After completing this command, update `STATUS.md`:
1. Set **Last Command** to `/market-intelligence`
2. Set **Last Output** to the output file path
3. Add entry to **Activity Log** table:
   - Date: Current date
   - Command: /market-intelligence
   - Output: outputs/intelligence/{date}-market-brief.md
   - Notes: Summary (e.g., "Standard scan, 12 sources, 8 insights")
4. Update **What's Pending** checklist: mark "Intelligence archive" as working if first scan
5. Rotate out activity log entries older than 30 days
