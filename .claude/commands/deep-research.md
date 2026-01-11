---
description: On-demand comprehensive research on a specific topic using Perplexity deep research
---

# /deep-research

Perform comprehensive deep research on a specific topic using Perplexity's sonar-deep-research model. Generates detailed analysis reports with market landscape, key players, emerging patterns, and strategic implications.

## Usage

```
/deep-research [topic]
/deep-research                     # Interactive topic picker
/deep-research "AI Agents"         # Direct topic
/deep-research --topics primary    # Show only primary topics
/deep-research --topics secondary  # Show only secondary topics
```

## Parameters

- `topic` (optional): The topic to research
  - If provided: Use specified topic directly
  - If omitted: Show interactive topic picker from topics.yaml

- `--topics [filter]`: Filter topics shown in picker (default: all)
  - `primary` - Show only primary topics
  - `secondary` - Show only secondary topics
  - `all` - Show primary and secondary topics

- `--effort [level]`: Control research depth (default: from research.yaml)
  - `low` - Faster, fewer searches, lower cost
  - `medium` - Balanced (default)
  - `high` - Most thorough, highest cost

## Prerequisites

- Perplexity API configured (`./scripts/enable-perplexity.sh`)
- `config/research.yaml` exists with deep research budget settings
- Deep research budget not exceeded

## Execution Steps

### Step 1: Load Configuration (Orchestrator)

Read these config files:
- `config/topics.yaml` - Get primary and secondary topics
- `config/research.yaml` - Get deep research settings:
  - `budget.deep_research.monthly_limit_usd`
  - `budget.deep_research.alert_threshold_pct`
  - `budget.deep_research.default_reasoning_effort`
  - `query_templates.deep_research`
- `system/cache/perplexity/usage.yaml` - Get current budget usage

### Step 2: Determine Topic

#### 2.1: If topic argument provided

Use the specified topic directly. Skip to Step 3.

```
/deep-research "AI Agents in Marketing"
→ topic = "AI Agents in Marketing"
```

#### 2.2: If no topic argument (Interactive Picker)

1. Load topics from `config/topics.yaml`
2. Filter by `--topics` flag if provided
3. Present interactive picker using AskUserQuestion:

```
Select topic for deep research:

Primary Topics:
  1. AI for Marketing
  2. AI Agents
  3. Claude/Anthropic
  4. Marketing Automation

Secondary Topics:
  5. Digital Transformation
  6. Enterprise AI
  7. Marketing Analytics
  8. Customer Data Platforms

Options:
- Enter a number (1-8)
- Enter a custom topic
- Cancel
```

4. Parse user selection:
   - Number → Map to topic name
   - Custom text → Use as topic
   - Cancel → Exit command

### Step 3: Check Budget and Show Warning

1. Read current usage from `system/cache/perplexity/usage.yaml`:
   ```yaml
   deep_research:
     estimated_cost_usd: {current_used}
   ```

2. Read limits from `config/research.yaml`:
   ```yaml
   budget:
     deep_research:
       monthly_limit_usd: 20.00
       alert_threshold_pct: 50
   ```

3. Calculate usage percentage:
   ```
   pct_used = (current_used / monthly_limit) * 100
   ```

4. **Budget Logic:**

   **If pct_used >= 100%:**
   ```
   Error: "Deep research budget exceeded for this month (${current_used}/${monthly_limit}).
   Budget resets on the 1st of next month."
   → Exit command
   ```

   **If pct_used >= alert_threshold (default 50%):**
   ```
   AskUserQuestion:
   "Deep research budget: {pct_used}% used (${current_used}/${monthly_limit}).
   Estimated cost for this research: ~$3-5.

   Options:
   - Proceed with deep research
   - Cancel"

   → Only proceed if user confirms
   ```

   **If pct_used < alert_threshold:**
   ```
   Info: "Deep research: ~$3-5 estimated. Budget: ${current_used}/${monthly_limit} ({pct_used}% used)"
   → Proceed automatically
   ```

### Step 4: Execute Deep Research

1. Load query template from `config/research.yaml`:
   ```yaml
   query_templates:
     deep_research: "Comprehensive analysis of {topic}: current market landscape, key players and recent developments, emerging patterns and signals, strategic implications"
   ```

2. Replace `{topic}` placeholder with selected topic

3. Determine reasoning effort:
   - Use `--effort` flag if provided
   - Otherwise use `research.yaml → budget.deep_research.default_reasoning_effort`

4. Call Perplexity deep research MCP:
   ```
   mcp__perplexity__perplexity_research

   messages: [
     {
       role: "user",
       content: "Comprehensive analysis of {topic}: current market landscape, key players and recent developments, emerging patterns and signals, strategic implications"
     }
   ]
   strip_thinking: true
   ```

5. Parse response into structured sections:
   - Executive Summary (first 2-3 sentences)
   - Market Landscape
   - Key Players & Developments
   - Emerging Patterns & Signals
   - Competitive Dynamics
   - Strategic Implications
   - Recommended Actions
   - Sources (from citations)

### Step 5: Update Usage Tracking

Update `system/cache/perplexity/usage.yaml`:
```yaml
deep_research:
  queries_count: {increment by 1}
  estimated_cost_usd: {add estimated cost based on response tokens}
  last_updated: "{ISO timestamp}"
  history:
    - date: "{YYYY-MM-DD}"
      topic: "{topic}"
      cost: {estimated_cost}
```

Recalculate totals:
```yaml
total_cost_usd: {regular.estimated_cost_usd + deep_research.estimated_cost_usd}
deep_research_budget_exceeded: {true if deep_research.estimated_cost_usd >= deep_research_limit}
```

### Step 6: Format Output Report

Generate markdown report:

```markdown
# Deep Research Report: {topic}

## Report Metadata
| Field | Value |
|-------|-------|
| **Generated** | {timestamp} |
| **Report Type** | deep-research |
| **Topic** | {topic} |
| **Reasoning Effort** | {effort_level} |
| **Estimated Cost** | ~${cost} |
| **Budget Status** | ${used}/${limit} ({pct}% used) |

---

## Executive Summary

{executive_summary - 2-3 sentences capturing the key findings}

---

## Market Landscape

{Current state of the market/topic area}
- Market size and growth
- Key segments
- Geographic distribution
- Maturity level

---

## Key Players & Developments

{Major companies and recent moves}

| Player | Recent Development | Significance |
|--------|-------------------|--------------|
{For each key player identified}

---

## Emerging Patterns & Signals

{Trends and early indicators}

1. **{Pattern 1}**: {Description and evidence}
2. **{Pattern 2}**: {Description and evidence}
3. **{Pattern 3}**: {Description and evidence}

---

## Competitive Dynamics

{How players are positioning}
- Consolidation/fragmentation trends
- Partnership patterns
- Investment flows
- Technology bets

---

## Strategic Implications

{What this means for positioning}

### Opportunities
- {Opportunity 1}
- {Opportunity 2}

### Threats
- {Threat 1}
- {Threat 2}

### Key Questions to Monitor
- {Question 1}
- {Question 2}

---

## Recommended Actions

Based on this research:

1. **Immediate**: {Action within 1 week}
2. **Short-term**: {Action within 1 month}
3. **Medium-term**: {Action within 3 months}

---

## Sources

All sources cited in this research:

| Source | URL |
|--------|-----|
{For each citation in response}
| {title} | [{url}]({url}) |

---

*Generated by PersonalOS | deep-research | {date}*
```

### Step 7: Write Output File

1. Generate filename slug from topic:
   ```
   "AI Agents in Marketing" → "ai-agents-in-marketing"
   ```

2. Write to: `2-research/market-briefs/{YYYY-MM-DD}-{HHMM}-deep-research-{slug}.md`
   - Example: `2-research/market-briefs/2026-01-12-1430-deep-research-ai-agents.md`

3. Display completion message:
   ```
   Deep research complete!

   Topic: {topic}
   Cost: ~${cost}
   Budget remaining: ${remaining} ({pct}%)

   Output: 2-research/market-briefs/{filename}
   ```

### Step 8: Sync to Notion

Use sync-agent to write to Notion:

```
Task tool call:
  - description: "Sync deep research to Notion"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      [Include sync-agent.md content]

      ## Your Task

      Write this deep research entry to Notion:

      ```json
      {
        "operation": "write",
        "database": "market_intelligence",
        "database_id": "{from notion-mapping.yaml}",
        "data": {
          "properties": {
            "Title": "Deep Research: {topic}",
            "Date": "{today}",
            "Priority": "High",
            "Topics": "{topic}",
            "Source": "{output_file_path}",
            "Summary": "{executive_summary}",
            "Type": "Deep Research",
            "Status": "New"
          }
        }
      }
      ```
```

### Step 9: Update STATUS.md

1. Set **Last Command** to `/deep-research`
2. Set **Last Output** to output file path
3. Add entry to **Activity Log**:
   - Date: Current date
   - Command: /deep-research
   - Output: {output_file_path}
   - Notes: "Topic: {topic}, Cost: ~${cost}"

## Cost Estimation

Deep research costs vary based on:
- Topic complexity
- Response length
- Number of searches performed by the model

**Typical ranges:**
- Low effort: $2-3
- Medium effort: $3-5
- High effort: $5-8

Cost is estimated from response token count (~$0.003 per 1K output tokens for sonar-deep-research).

## Error Handling

### Perplexity API Error
```
If API call fails:
1. Log error to system/logs/
2. Show user-friendly message
3. Suggest retry or --effort low for lighter query
```

### Budget Exceeded
```
If budget >= 100%:
1. Show clear message with budget status
2. Suggest waiting until next month
3. Or adjusting budget in research.yaml
```

### Invalid Topic
```
If topic is empty or too short:
1. Fall back to interactive picker
2. Show guidance on topic format
```

## Example Output Location

`2-research/market-briefs/2026-01-12-1430-deep-research-ai-agents.md`

## Related Commands

- `/market-intelligence --deep` - Deep research integrated with market scan
- `/perplexity-budget` - View detailed budget status
- `/daily-brief` - Morning brief includes budget status
