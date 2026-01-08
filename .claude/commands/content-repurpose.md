---
description: Transform content into LinkedIn posts, threads, and newsletter snippets (project)
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

- `--tone`: Content tone (default: auto-detect from voice profile)
  - `educational` - Teaching/informing
  - `provocative` - Challenging/thought-provoking
  - `storytelling` - Narrative/personal

## Execution Steps

1. **Load Voice Profile**
   - Read `config/voice-profile.yaml`
   - Note tone, vocabulary, structure preferences
   - Check platform-specific guidelines

2. **Load Personal Context**
   - Read `config/personal-context.yaml`
   - Note available stories and their themes
   - Identify stories that match content topic
   - Use relevant stories to add authenticity and personal anecdotes

3. **Load Source Content**
   - If local path: Read the markdown file
   - If Notion URL: Fetch page content via Notion MCP
   - Extract key messages, data points, insights

4. **Analyze Source**
   - Identify main thesis/argument
   - Extract supporting points
   - Note quotable data or statistics
   - Determine best tone based on content
   - Match content themes to personal stories

5. **Generate LinkedIn Variations**
   For each variation:
   - Create attention-grabbing hook
   - Structure body (3-5 paragraphs)
   - Weave in relevant personal stories when appropriate
   - Add clear CTA
   - Include relevant hashtags (3-5)
   - Target length: 1200-1500 characters

6. **Generate Twitter Thread**
   - Create hook tweet
   - Build narrative across 6-10 tweets
   - End with CTA
   - Keep each tweet punchy and standalone

7. **Generate Newsletter Snippet**
   - Write personal intro (use stories from personal context)
   - Create deeper analysis section
   - Include actionable takeaways
   - Target length: 2-3 paragraphs

8. **Apply Voice Matching**
   Review all content for:
   - Tone consistency
   - Vocabulary alignment
   - Structural patterns
   - Authentic voice markers
   - Natural integration of personal stories

9. **Save Output**
   - Create folder: `outputs/content/{date}-{slug}/`
   - Save: `linkedin-v1.md`, `linkedin-v2.md`
   - Save: `twitter-thread.md`
   - Save: `newsletter-snippet.md`
   - Save: `summary.md` (overview of all versions)

10. **Sync to Notion**
   Create draft entries in "POS: Content Calendar":
   - One entry per variation
   - Status: "Draft"
   - Platform: Appropriate platform
   - Content: Full text
   - Hook: First line

## Output Format

### LinkedIn Output
```markdown
# LinkedIn Post - Version 1 (Educational)

**Hook**: {attention-grabbing first line}

**Body**:
{3-5 short paragraphs}

**CTA**: {call to action}

**Hashtags**: #tag1 #tag2 #tag3

---

**Character Count**: {count}
**Tone**: Educational
**Source**: {original source}
```

### Twitter Thread Output
```markdown
# Twitter Thread

**Thread Preview**: {brief summary}

---

1/ {hook tweet}

2/ {context/setup}

3/ {main point 1}

...

8/ {CTA with link}

---

**Tweet Count**: 8
**Tone**: Provocative
```

### Newsletter Snippet Output
```markdown
# Newsletter Snippet

**Intro**:
{personal observation/anecdote}

**Main Content**:
{deeper analysis}

**Takeaways**:
- Key point 1
- Key point 2
- Key point 3

---

**Word Count**: {count}
**Tone**: Personal/analytical
```

## Sub-Agent

This command uses the `content-creator` sub-agent.
See `sub-agents/content-creator.md` for detailed behavior.

## Voice Profile Elements

From `config/voice-profile.yaml`:

### Tone
- Professional but approachable
- Data-informed but not dry
- Practical over theoretical

### Vocabulary
- Use: "transformation", "practical", "AI agents"
- Avoid: "game-changer", "revolutionary", "synergy"

### Patterns
- Start with contrarian take or surprising data
- Include enterprise context examples
- End with forward-looking question

## Personal Context

From `config/personal-context.yaml`:

### Stories
- Reusable anecdotes matched by themes
- Short versions for quick reference
- Full versions for deeper narratives

### Influences
- Books and mentors that shaped thinking
- Can be referenced for credibility

### Career Timeline
- Entrepreneurial background
- Enterprise transformation experience
- Use to establish credibility and bridge contexts

## Example Output Location

```
outputs/content/2026-01-06-ai-agents-marketing/
├── summary.md
├── linkedin-v1.md
├── linkedin-v2.md
├── twitter-thread.md
└── newsletter-snippet.md
```

## Notion Database

Database: "POS: Content Calendar"
ID: Found in `config/notion-mapping.yaml` under `databases.content_calendar`

Properties to populate:
- Title: Content title
- Platform: LinkedIn/Twitter/Newsletter
- Status: "Draft"
- Content: Full post text
- Hook: First line/attention grabber
- Publish Date: (leave empty for user to set)

## Quality Checklist

Before finalizing output, verify:
- [ ] Voice matches profile
- [ ] Hook is attention-grabbing
- [ ] Content is actionable
- [ ] Platform constraints are met
- [ ] No generic AI phrases
- [ ] Personal/enterprise context included

## Performance Target

- < 2 minutes for all platforms
- < 1 minute for single platform

## Post-Execution: Update STATUS.md

After completing this command, update `STATUS.md`:
1. Set **Last Command** to `/content-repurpose`
2. Set **Last Output** to the output folder path
3. Add entry to **Activity Log** table:
   - Date: Current date
   - Command: /content-repurpose
   - Output: outputs/content/{date}-{slug}/
   - Notes: Summary (e.g., "LinkedIn x2, Twitter thread, newsletter")
4. Update **What's Pending** checklist: mark "Content outputs" as working if first content
5. Rotate out activity log entries older than 30 days
