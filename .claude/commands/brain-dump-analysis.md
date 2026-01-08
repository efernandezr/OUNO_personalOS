---
description: Find patterns and content opportunities from your notes and ideas
---

# /brain-dump-analysis

Analyze accumulated notes, ideas, and brain dumps to identify patterns and content opportunities.

## Usage

```
/brain-dump-analysis [options]
```

## Parameters (Optional)

- `--timeframe`: Period to analyze (default: "month")
  - `week` - Last 7 days
  - `month` - Last 30 days
  - `quarter` - Last 90 days
  - `all` - All available notes

- `--focus`: Analysis focus (default: "all")
  - `patterns` - Theme extraction only
  - `pillars` - Content pillar alignment
  - `gaps` - Underexplored ideas
  - `all` - Complete analysis

- `--min-mentions`: Minimum times a theme must appear (default: 2)

## Execution Steps

1. **Load Configuration**
   - Read `config/topics.yaml` for content pillars
   - Read `config/notion-mapping.yaml` for database IDs

2. **Gather Brain Dumps**
   - Scan `brain-dumps/` folder for markdown files
   - Query Notion "POS: Brain Dumps" database (primary mobile capture)
   - Deduplicate entries that exist in both sources
   - Filter combined results by timeframe parameter

3. **Extract Themes**
   For each note:
   - Identify explicit topic mentions
   - Detect implicit themes
   - Note emotional emphasis (questions, exclamations)
   - Track keyword frequency

4. **Analyze Patterns**
   - Count theme frequency
   - Map connections between ideas
   - Track theme evolution over time
   - Score content potential

5. **Align with Pillars**
   Check each theme against content pillars:
   1. AI for Marketing
   2. Claude Code for Marketing
   3. AI Agents for Marketing
   4. Building Agents
   5. Digital Marketing Maturity

6. **Generate Analysis**
   Create structured output with:
   - Content Pillars Identified
   - Theme Evolution
   - Underexplored Ideas
   - Connection Map
   - Content Queue Recommendations

7. **Save Output**
   - Write to `outputs/analysis/{date}-brain-analysis.md`

8. **Sync to Notion**
   - Mark processed brain dumps as "Processed"
   - Create content ideas in "POS: Content Calendar" (optional)

## Output Format

```markdown
# Brain Dump Analysis
**Period**: {timeframe}
**Notes Analyzed**: {count}
**Unique Themes**: {count}

## Content Pillars Identified

### Pillar 1: {theme}
- **Frequency**: {count} mentions
- **Related ideas**: {list}
- **Content potential**: {High/Medium/Low}
- **Suggested angles**: {list}

## Theme Evolution
{How your thinking has evolved over time}

## Underexplored Ideas
{Interesting ideas mentioned once but worth developing}

## Connection Map
{How different ideas connect to each other}

## Content Queue Recommendations
{Prioritized list of content to create}
```

## Sub-Agent

This command uses the `pattern-analyst` sub-agent.
See `sub-agents/pattern-analyst.md` for detailed behavior.

## Input Sources

Both sources are checked and combined for analysis:

### Local Files
- Location: `brain-dumps/YYYY-MM/` folders
- Secondary: `notes/` folder (if exists)
- File format: Markdown (.md)
- Best for: Longer, structured brain dumps from desktop

### Notion Database
- Database: "POS: Brain Dumps" (ID in notion-mapping.yaml)
- Best for: Quick captures from mobile
- All entries included in analysis
- After analysis: `Processed` checkbox marked true

### Deduplication Logic
When the same content exists in both sources:
- Match by title + date
- Use local version as canonical (may have edits)
- Still mark Notion entry as processed

### Tip
Run `/sync-brain-dumps` first to ensure Notion content is backed up locally.

## Brain Dump Format

Expected format for brain dumps:
```markdown
# Brain Dump - {date}

## Ideas
- Idea 1
- Idea 2

## Questions
- What if...?
- How can...?

## Observations
- Noticed that...
- Interesting pattern...

## Tags
#ai #marketing #content-idea
```

## Example Output Location

`outputs/analysis/2026-01-06-brain-analysis.md`

## Content Potential Scoring

**High Potential**:
- Mentioned 5+ times across notes
- Aligns with 2+ content pillars
- Timely (relates to current trends)
- Unique angle (competitors not covering)

**Medium Potential**:
- Mentioned 2-4 times
- Aligns with 1 content pillar
- Evergreen topic

**Low Potential**:
- Mentioned once
- Tangential to pillars
- Requires significant research

## Performance Target

- < 3 minutes for 100 notes
- < 1 minute for 20 notes

## Post-Execution: Update STATUS.md

After completing this command, update `STATUS.md`:
1. Set **Last Command** to `/brain-dump-analysis`
2. Set **Last Output** to the output file path
3. Add entry to **Activity Log** table:
   - Date: Current date
   - Command: /brain-dump-analysis
   - Output: outputs/analysis/{date}-brain-analysis.md
   - Notes: Summary (e.g., "15 notes, 4 themes, 3 content opportunities")
4. Update **What's Pending** checklist if brain dumps are now populated
5. Rotate out activity log entries older than 30 days
