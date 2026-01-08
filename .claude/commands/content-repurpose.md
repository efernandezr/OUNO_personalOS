---
description: Transform content into LinkedIn posts, threads, and newsletter snippets
---

# /content-repurpose

Transform existing content into platform-optimized formats while preserving authentic voice.

## Usage

```
/content-repurpose <source> [options]
```

## Parameters

### Required
- `<source>`: Path to source content OR Notion page URL
  - Local file: `outputs/intelligence/2026-01-06-market-brief.md`
  - Notion page: `https://notion.so/...`

### Optional
- `--platforms`: Target platforms (default: all)
  - `linkedin` - LinkedIn post format
  - `twitter` - Twitter/X thread format
  - `newsletter` - Newsletter snippet
  - `all` - All platforms

- `--variations`: Number of variations per platform (default: 2)

- `--tone`: Content tone (default: auto-detect)
  - `educational` - Teaching/informing
  - `provocative` - Challenging/thought-provoking
  - `storytelling` - Narrative/personal

## Orchestration Pattern

This command uses **Task tool delegation** to the `content-agent`.

```
Orchestrator (this command)     →     Agents
─────────────────────────────────────────────────────────
1. Parse parameters
2. Load voice-profile.yaml
3. Load personal-context.yaml
4. Load source content
5. Identify relevant themes
6. Construct content input
                                 →    7. content-agent (generation)
                                 →    8. Return platform content
9. Receive JSON output           ←
10. Write individual files
11. Sync to content_calendar     →    sync-agent (write)
12. Update STATUS.md
```

## Execution Steps

### Step 1: Load Configuration (Orchestrator)

Read these config files:
- `config/voice-profile.yaml` - Get tone, vocabulary, patterns
- `config/personal-context.yaml` - Get stories, influences
- `config/notion-mapping.yaml` - Get content_calendar database ID

### Step 2: Load Source Content (Orchestrator)

If local path:
```
Read the markdown file directly
```

If Notion URL:
```
Use mcp__notion__notion-fetch with page ID extracted from URL
```

### Step 3: Identify Relevant Themes (Orchestrator)

Analyze source content to extract:
- Main thesis
- Key topics/keywords
- Match against story themes in personal-context.yaml
- Select 1-2 relevant stories that could be woven in

### Step 4: Invoke Content Agent (Task Tool)

```
Task tool call:
  - description: "Generate platform content from source"
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - prompt: |
      You are the content-agent for PersonalOS.

      [Read and include content of .claude/agents/content-agent.md]

      ## Your Task

      Transform this source content for multiple platforms:

      ```json
      {
        "source_content": "{full source text}",
        "platforms": {from parameter or ["linkedin", "twitter", "newsletter"]},
        "variations": {from parameter or 2},
        "tone": "{from parameter or 'auto'}",
        "voice_profile": {
          "tone": {from voice-profile.yaml},
          "vocabulary": {from voice-profile.yaml},
          "patterns": {from voice-profile.yaml}
        },
        "personal_context": {
          "stories": [{relevant stories from personal-context.yaml}],
          "influences": [{from personal-context.yaml}]
        },
        "relevant_themes": ["{extracted themes from source}"]
      }
      ```

      Return valid JSON matching the output schema.
```

### Step 5: Process Agent Output (Orchestrator)

The content-agent returns:
- `linkedin[]` - LinkedIn post variations with hook, body, cta, hashtags
- `twitter[]` - Twitter thread with individual tweets
- `newsletter[]` - Newsletter snippet with intro, content, takeaways
- `source_analysis` - Main thesis, key points, matched stories

### Step 6: Write Output Files (Orchestrator)

Create output folder: `outputs/content/{YYYY-MM-DD}-{slug}/`

Generate slug from source title (lowercase, hyphens, max 50 chars)

Write files:

```
outputs/content/{date}-{slug}/
├── summary.md          # Overview of all generated content
├── linkedin-v1.md      # First LinkedIn variation
├── linkedin-v2.md      # Second LinkedIn variation (if variations > 1)
├── twitter-thread.md   # Twitter thread
└── newsletter-snippet.md  # Newsletter version
```

### File Format: LinkedIn

```markdown
# LinkedIn Post - Version {n} ({tone})

**Hook**: {hook}

---

{body}

---

**CTA**: {cta}

**Hashtags**: {hashtags joined}

---

**Character Count**: {character_count}
**Stories Used**: {stories_used joined}
**Key Message**: {key_message}
```

### File Format: Twitter Thread

```markdown
# Twitter Thread

**Thread Preview**: {hook_tweet}

---

1/ {tweets[0]}

2/ {tweets[1]}

...

{thread_count}/ {cta_tweet}

---

**Tweet Count**: {thread_count}
**Tone**: {tone}
```

### File Format: Newsletter

```markdown
# Newsletter Snippet

## Personal Introduction

{intro}

## Main Content

{main_content}

## Key Takeaways

{For each takeaway:}
- {takeaway}

---

**Word Count**: {word_count}
**Tone**: {tone}
**Stories Used**: {stories_used}
```

### File Format: Summary

```markdown
# Content Package: {source title}

**Generated**: {timestamp}
**Source**: {source path or URL}

## Source Analysis

**Main Thesis**: {source_analysis.main_thesis}

**Key Points**:
{For each point:}
- {point}

**Matched Stories**: {matched_stories}

## Generated Content

| Platform | File | Tone | Length |
|----------|------|------|--------|
| LinkedIn V1 | linkedin-v1.md | {tone} | {char_count} chars |
| LinkedIn V2 | linkedin-v2.md | {tone} | {char_count} chars |
| Twitter | twitter-thread.md | {tone} | {tweet_count} tweets |
| Newsletter | newsletter-snippet.md | {tone} | {word_count} words |

## Ready to Publish

Review each file and publish when ready.
```

### Step 7: Write Agent Log (Orchestrator)

Write to: `outputs/logs/{YYYY-MM-DD}-content-agent.json`
Include: input, output, timestamp

### Step 8: Sync to Notion Content Calendar (sync-agent)

For each generated piece:

```
Task tool call:
  - description: "Add content draft to calendar"
  - subagent_type: "general-purpose"
  - model: "haiku"
  - prompt: |
      You are the sync-agent for PersonalOS.

      [Include sync-agent.md content]

      ## Your Task

      ```json
      {
        "operation": "write",
        "database": "content_calendar",
        "database_id": "{from notion-mapping}",
        "data": {
          "properties": {
            "Title": "{content title}",
            "Platform": "{platform}",
            "Status": "Draft",
            "Hook": "{first line/hook}",
            "Content": "{full text}"
          }
        }
      }
      ```
```

### Step 9: Update STATUS.md (Orchestrator)

1. Set **Last Command** to `/content-repurpose`
2. Set **Last Output** to the output folder path
3. Add entry to **Activity Log** with counts

## Agent Reference

- **Content Agent**: `.claude/agents/content-agent.md`
- **Sync Agent**: `.claude/agents/sync-agent.md`

## Voice Matching

The content-agent enforces voice profile by:
- Using preferred vocabulary
- Avoiding banned words
- Applying structural patterns
- Maintaining tone consistency

## Personal Story Integration

Stories from `personal-context.yaml` are:
1. Matched to source themes
2. Woven naturally into content
3. Used sparingly (1 per LinkedIn post max)
4. Provide authenticity and credibility

## Quality Checklist

Before output, the agent verifies:
- [ ] Voice matches profile
- [ ] Hook is attention-grabbing
- [ ] Content is actionable
- [ ] Platform constraints met (char/word limits)
- [ ] No generic AI phrases
- [ ] Personal stories integrated naturally

## Example Output Location

```
outputs/content/2026-01-08-ai-agents-marketing/
├── summary.md
├── linkedin-v1.md
├── linkedin-v2.md
├── twitter-thread.md
└── newsletter-snippet.md
```

## Performance Target

- All platforms: < 2 minutes
- Single platform: < 1 minute
