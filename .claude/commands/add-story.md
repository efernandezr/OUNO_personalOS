---
description: Add personal stories and experiences to your context (project)
---

# /add-story

Add a personal story, experience, or influence to your context for authentic content generation.

## Usage

```
/add-story [description]
```

## Parameters (Optional)

- `description`: Brief description of what you want to add (will prompt for details if not provided)
- `--type`: Skip type question — `story`, `book`, `experience`, `career`
- `--template`: Skip template question — `transformation`, `failure`, `milestone`
- `--full`: Collect extended narrative
- `--skip-quality`: Skip quality checklist (not recommended)

## Execution Steps

### 1. Determine Type

Ask user or infer from description:

| Type | Description |
|------|-------------|
| `story` | A reusable anecdote or personal experience |
| `book` | A formative book or influence |
| `experience` | A career experience or lesson learned |
| `career` | A career milestone or phase |

### 2. Collect Details

**For Stories**: id, short (one-liner), full (optional extended), themes, use_when
**For Books/Influences**: title, author, discovered, insight, current_application
**For Career**: period, phase, note

### 3. Offer Template (for stories)

Ask: "Is this a transformation, failure/learning, or milestone story?" Then guide with template:

**Transformation**: Context → Catalyst → Journey → Outcome → Lesson
- One-liner: "I went from [context] to [outcome] after [catalyst] taught me [lesson]"

**Failure/Learning**: Situation → Mistake → Impact → Learning → Application
- One-liner: "When I tried [situation], I learned [learning] the hard way—[mistake] cost us [impact]"

**Milestone**: Achievement → Context → Challenge → Approach → Broader Lesson
- One-liner: "Achieving [achievement] despite [challenge] taught me [broader lesson]"

### 4. Quality Checklist

Before saving, verify:
- Clear, actionable takeaway
- Illustrates a principle (can support content)
- Personal and unique (YOUR story)
- Maps to at least one content pillar

Content pillar mapping:
| Pillar | Themes |
|--------|--------|
| AI for Marketing | enterprise, transformation, ROI, adoption |
| Claude Code for Marketing | automation, workflows, productivity |
| AI Agents for Marketing | agents, orchestration, delegation |
| Building Agents | technical, development, architecture |
| Digital Marketing Maturity | maturity, assessment, capability |

If checks fail: offer to refine, save anyway, or cancel.

### 5. Save to Local Config

Append to `config/personal-context.yaml` → stories/influences/career array. Update `last_updated`.

### 6. Sync to Notion

If personal_context database exists: create entry in "POS: Personal Context", set `Synced = true`.

### 7. Confirm

```
## Story Added
**Type**: {type} | **ID**: {id}
**Short**: "{one-liner}"
**Themes**: {themes}
Saved to: config/personal-context.yaml
Synced to: Notion (POS: Personal Context)
```

## Extended Collection (--full flag)

For extended narratives, collect structured sections:
- **Transformation**: The Before, The Catalyst, The Journey, The After, The Lesson
- **Failure/Learning**: The Goal, The Mistake, The Fallout, The Realization, The Application
- **Milestone**: The Achievement, The Context, The Obstacles, The Approach, The Takeaway

## Notes

- Stories are automatically available to `/generate-content`
- Use `/sync-brain-dumps` to pull stories added via Notion mobile
- Aim for 20-30 stories with good theme coverage across pillars
- Run `/voice-calibrate` after adding multiple stories
