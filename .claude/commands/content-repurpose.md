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

### Step 3: Extract Source Metadata (Orchestrator)

If source is an intelligence report (contains "Source Log" or "Sources" section):
1. Parse the "Sources" table or "Source Log" section for URLs
2. Extract source links from insight sections (`[Name](url)` format)
3. Build `original_sources` array with `{url, name}` objects

```json
{
  "source_metadata": {
    "origin": "{source path or Notion URL}",
    "title": "{extracted title from source}",
    "date": "{date from source if available}",
    "original_sources": [
      {"url": "https://example.com/article", "name": "Article Title"},
      {"url": "https://another.com/post", "name": "Post Name"}
    ]
  }
}
```

If source is raw content without source tracking:
- Set `origin` to the source path
- Set `original_sources` to empty array `[]`

### Step 4: Identify Relevant Themes (Orchestrator)

Analyze source content to extract:
- Main thesis
- Key topics/keywords
- Match against story themes in personal-context.yaml
- Select 1-2 relevant stories that could be woven in

### Step 5: Invoke Content Agent (Task Tool)

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
        "source_metadata": {
          "origin": "{source path or Notion URL}",
          "title": "{extracted title}",
          "date": "{date if available}",
          "original_sources": [{url, name} objects from Step 3]
        },
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

      Return valid JSON matching the output schema. Ensure `sources_referenced` is populated on each platform output.
```

### Step 6: Process Agent Output (Orchestrator)

The content-agent returns:
- `linkedin[]` - LinkedIn post variations with hook, body, cta, hashtags, sources_referenced
- `twitter[]` - Twitter thread with individual tweets, sources_referenced
- `newsletter[]` - Newsletter snippet with intro, content, takeaways, sources_referenced
- `source_analysis` - Main thesis, key points, matched stories

### Step 7: Write Output Files (Orchestrator)

Create output folder: `3-content/{YYYY-MM-DD}-{slug}/`

Generate slug from source title (lowercase, hyphens, max 50 chars)

Write files:

```
3-content/{date}-{slug}/
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

## Sources Referenced

{For each source in sources_referenced:}
- [{source.name}]({source.url})

---

**Generation Info**
- Character Count: {character_count}
- Stories Used: {stories_used joined}
- Key Message: {key_message}
- Original Source: {source_metadata.origin}
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

## Further Reading

{For each source in sources_referenced:}
- [{source.name}]({source.url})

---

**Generation Info**
- Word Count: {word_count}
- Tone: {tone}
- Stories Used: {stories_used}
- Original Source: {source_metadata.origin}
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

### Step 8: Write Agent Log (Orchestrator)

Write to: `system/logs/{YYYY-MM-DD}-content-agent.json`
Include: input, output, timestamp

### Step 9: Sync to Notion Content Calendar (sync-agent)

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

### Step 10: Update STATUS.md (Orchestrator)

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
3-content/2026-01-08-ai-agents-marketing/
├── summary.md
├── linkedin-v1.md
├── linkedin-v2.md
├── twitter-thread.md
└── newsletter-snippet.md
```

## Retry Configuration

### Content Agent Operations
```yaml
max_retries: 2
backoff:
  initial: 2000  # 2 seconds (creative generation takes time)
  multiplier: 2
  max: 8000
retry_on:
  - task_tool_error
  - incomplete_response
  - timeout
dont_retry_on:
  - invalid_source (source file not found)
  - missing_config (voice profile not found)
```

### Notion Sync Operations
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
  - invalid_database_id
```

## JSON Validation

### Schema Reference
```
.claude/utils/schemas.json → agents.content-agent
```

### Required Fields
- `source_analysis.main_thesis` (string)
- `source_analysis.key_points` (array)
- `generation_timestamp` (ISO string)
- At least one platform array populated (linkedin, twitter, or newsletter)

### Platform-Specific Validation
**LinkedIn entries**:
- `hook` (string, min 10 chars)
- `body` (string, min 100 chars)
- `character_count` (integer, 500-2000)
- `hashtags` (array, 3-5 items)
- `sources_referenced` (array, can be empty if no source_metadata provided)

**Twitter entries**:
- `tweets` (array, 4-12 items)
- Each tweet ≤ 280 characters
- `sources_referenced` (array, can be empty)

**Newsletter entries**:
- `word_count` (integer, 400-1000)
- `takeaways` (array, 3-5 items)
- `sources_referenced` (array, can be empty)

### Validation on Failure
1. Retry content-agent with specific feedback
2. Max 2 validation retries
3. If still failing, output partial content with warnings

## Partial Results Handling

### Scenario: Source File Not Found
```markdown
> ❌ **SOURCE NOT FOUND**
> Could not read: {source_path}
>
> Please verify the path exists and try again.
```

### Scenario: Voice Profile Missing
Proceed with default voice (warn user):
```markdown
> ⚠️ **VOICE PROFILE UNAVAILABLE**
> Using default voice settings. Run `/voice-calibrate` to personalize.
```

### Scenario: Personal Context Empty
Generate without stories:
```markdown
> ℹ️ **NO STORIES AVAILABLE**
> Content generated without personal stories.
> Run `/add-story` to add authenticity through personal context.
```

### Scenario: One Platform Fails
Generate others successfully:
```markdown
> ⚠️ **PARTIAL GENERATION**
> Twitter thread generation failed.
> LinkedIn and Newsletter content generated successfully.
```

### Scenario: Notion Sync Fails
Save locally, continue:
```markdown
**Notion Sync**: ❌ Content saved locally only.
Manually add to content calendar or retry later.
```

## Performance Target

- All platforms: < 2 minutes
- Single platform: < 1 minute
