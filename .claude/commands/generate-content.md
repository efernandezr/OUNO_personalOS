---
description: Transform content into LinkedIn posts, threads, and newsletter snippets
---

# /generate-content

Transform existing content into platform-optimized formats while preserving authentic voice.

## Usage

```
/generate-content [source] [options]
```

## Parameters

### Optional
- `<source>`: Path to source content OR Notion page URL
  - If omitted, suggests most recent file from `2-research/`
- `--platforms`: Target platforms (default: all) — `linkedin`, `twitter`, `newsletter`, `all`
- `--variations`: Number of variations per platform (default: 2)
- `--tone`: Content tone (default: auto-detect) — `educational`, `provocative`, `storytelling`

## Orchestration Flow

This command uses **two-pass Task tool delegation**: analysis (Sonnet) then writing (Opus).

```
Orchestrator                     →     Agents
─────────────────────────────────────────────────────────
1. Parse parameters
1.5. Smart source selection (if no source)
2. Load configs (voice-profile, personal-context, notion-mapping)
3. Load source content (local file or Notion)
4. Extract source metadata + original_sources
5. Identify relevant themes
5.5. Scan story history (last 5 content packages)
                                 →    6a. content-analysis-agent (Sonnet)
                                 ←    Returns analysis JSON
                                 →    6b. content-agent (Opus) + pre_analysis
                                 ←    Returns platform content
7. Validate JSON output
8. Write individual files per platform
9. Write agent logs
10. Sync to content_calendar     →    sync-agent (write)
```

## Execution Steps

### Step 1.5: Smart Source Selection (if no source provided)

1. Scan `2-research/` recursively for `.md` files, sort by modification time (newest first)
2. Confirm via AskUserQuestion: "Use this source? {filename} (modified {time})" with option to provide different path

### Step 2: Load Configuration

Read: `config/voice-profile.yaml`, `config/personal-context.yaml`, `config/notion-mapping.yaml`.

### Step 3: Load Source Content

- Local path: Read markdown file directly
- Notion URL: Use `mcp__notion__notion-fetch` with page ID from URL

### Step 4: Extract Source Metadata

If source contains "Sources" section: parse URL table/links into `original_sources[{url, name}]` array.
Otherwise: set `original_sources: []`.

### Step 5: Identify Relevant Themes

Extract main thesis, key topics/keywords, match against story themes in personal-context.yaml.

### Step 5.5: Scan Story History

1. Scan `3-content/linkedin/` for 5 most recent `summary.md` files
2. Extract story titles from "Stories Used" and "Matched Stories" lines
3. Build `recent_stories_used` array (duplicates preserved to indicate overuse)

### Step 6a: Invoke Content Analysis Agent (Sonnet)

Follow **Agent Invocation** in `agent-execution-guide.md` with:
- Agent: `content-analysis-agent`, Model: `sonnet`
- Input: source_content, source_metadata, platforms, tone, personal_context (stories + influences), relevant_themes, recent_stories_used

Validate per `agent-execution-guide.md` → **JSON Validation** against `schemas.json → agents.content-analysis-agent`.

Required fields: `source_analysis.main_thesis`, `source_analysis.key_points`, `recommended_stories` (min 1), `platform_differentiation` (all 3 angles), `tone_recommendation` (all 3 platforms), `analysis_timestamp`.

### Step 6b: Invoke Content Agent (Opus)

Follow **Agent Invocation** in `agent-execution-guide.md` with:
- Agent: `content-agent`, Model: `opus`
- Input: source_content, source_metadata, pre_analysis (from 6a), platforms, variations, voice_profile, personal_context, relevant_themes

Validate per `agent-execution-guide.md` → **JSON Validation** against `schemas.json → agents.content-agent`.

Required fields: `generation_timestamp`, at least one platform array populated.

Platform validation: LinkedIn (hook 10+ chars, body 100+ chars, 500-2000 char count, 3-5 hashtags, sources_referenced), Twitter (4-12 tweets each ≤280 chars), Newsletter (400-1000 words, 3-5 takeaways).

### Step 7: Validate JSON Output

Validation is part of Step 6a/6b above (per agent-execution-guide.md). If validation fails after retries, proceed with partial content and warning banners.

### Step 8: Write Output Files

Create `3-content/{platform}/{YYYY-MM-DD}-{slug}/` for each platform.

Slug: source title → lowercase, hyphens, max 50 chars.

**LinkedIn**: `linkedin-v1.md`, `linkedin-v2.md`, `summary.md`
```markdown
# LinkedIn Post - Version {n} ({tone})
**Hook**: {hook}
---
{body}
---
**CTA**: {cta}
**Hashtags**: {hashtags}
## Sources Referenced
{source links}
---
**Generation Info**: Character Count, Stories Used, Key Message, Original Source
```

**Twitter**: `twitter-thread.md`
```markdown
# Twitter Thread
**Thread Preview**: {hook_tweet}
---
1/ {tweet} ... {n}/ {cta_tweet}
---
**Tweet Count**: {n} | **Tone**: {tone}
```

**Newsletter**: `newsletter-snippet.md`
```markdown
# Newsletter Snippet
## Personal Introduction
{intro}
## Main Content
{main_content}
## Key Takeaways
{takeaways}
## Further Reading
{source links}
---
**Generation Info**: Word Count, Tone, Stories Used, Original Source
```

**Summary**: `summary.md` (in linkedin folder)
```markdown
# Content Package: {title}
**Generated**: {timestamp} | **Source**: {path}
## Source Analysis
Main Thesis, Key Points, Matched Stories (from Step 6a output)
## Generated Content
| Platform | File | Tone | Length |
{files table}
```

### Step 9: Write Agent Logs

- Analysis log: `system/logs/{YYYY-MM-DD}-content-analysis-agent.json`
- Content log: `system/logs/{YYYY-MM-DD}-content-agent.json`

### Step 10: Sync to Notion

Follow **Sync-Agent: Write** in `agent-execution-guide.md` for each generated piece:
- Database: `content_calendar`
- Properties: Title, Platform, Status: "Draft", Hook, Content

## Error Handling

- **Source not found**: Show path, ask user to verify
- **Voice profile missing**: Proceed with defaults, suggest `/voice-calibrate`
- **Personal context empty**: Generate without stories, suggest `/add-story`
- **One platform fails**: Generate others, note partial generation
- **Notion sync fails**: Save locally, note in output
- Follow **Partial Results Handling** in `agent-execution-guide.md`

## Agent Reference

- **Content Analysis Agent**: `.claude/agents/content-analysis-agent.md` (Sonnet)
- **Content Agent**: `.claude/agents/content-agent.md` (Opus)
- **Sync Agent**: `.claude/agents/sync-agent.md` (Haiku)
