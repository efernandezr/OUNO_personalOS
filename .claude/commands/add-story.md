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

**For Stories:**
- `id`: Short identifier (auto-generated from title)
- `short`: One-liner version for quick use
- `full`: (Optional) Extended narrative
- `themes`: Tags for matching to content topics
- `use_when`: When to reference this story

**For Books/Influences:**
- `title`: Book or resource title
- `author`: Author name
- `discovered`: When/how you discovered it
- `insight`: Key insight or lesson
- `current_application`: How you apply it now

**For Career:**
- `period`: Time period (e.g., "2015-2020", "Present")
- `phase`: Phase name
- `note`: Brief description

### 3. Save to Local Config

Append to appropriate section in `config/personal-context.yaml`:
- Stories → `stories` array
- Books → `influences` array
- Career/Experience → `career` array

Update `last_updated` timestamp.

### 4. Sync to Notion

If personal_context database exists:
1. Create new entry in "POS: Personal Context" database
2. Set `Synced` = true (already in local)
3. Map fields to Notion properties

### 5. Confirm

Display summary:

```
## Story Added

**Type**: story
**ID**: crossing-the-chasm
**Short**: "15 years ago I read Crossing the Chasm as a young entrepreneur"
**Themes**: adoption, transformation, change-management

Saved to: config/personal-context.yaml
Synced to: Notion (POS: Personal Context)
```

## Example

```
> /add-story I want to add a story about learning to fail fast from my startup days

What type of content is this?
> story

Give me the one-liner version:
> "My first startup taught me that failing fast isn't about giving up—it's about learning faster than your competitors"

What themes does this relate to? (comma-separated)
> startup, failure, learning, entrepreneurship

When should I use this story?
> When discussing iteration, experimentation, or startup mindset in enterprise contexts

## Story Added

**Type**: story
**ID**: fail-fast-startup
**Short**: "My first startup taught me that failing fast isn't about giving up—it's about learning faster than your competitors"
**Themes**: startup, failure, learning, entrepreneurship

Saved to: config/personal-context.yaml
Synced to: Notion (POS: Personal Context)
```

## Story Templates

When collecting stories, use these narrative templates to ensure compelling structure:

### Transformation Story Template
Use for: Career pivots, mindset shifts, skill development journeys

| Element | Question | Example |
|---------|----------|---------|
| **Context** | What was the situation before? | "I was a traditional marketer measuring success by gut feel" |
| **Catalyst** | What triggered the change? | "A failed campaign that data would have predicted" |
| **Journey** | What steps did you take? | "Spent 6 months learning analytics, ran 20 A/B tests" |
| **Outcome** | What changed as a result? | "Became the team's go-to for data-driven decisions" |
| **Lesson** | What universal truth emerged? | "Data doesn't replace creativity—it directs it" |

**One-liner formula**: "I went from [context] to [outcome] after [catalyst] taught me [lesson]"

### Failure/Learning Story Template
Use for: Mistakes, setbacks, humble lessons, "what not to do"

| Element | Question | Example |
|---------|----------|---------|
| **Situation** | What were you trying to achieve? | "Launching an AI tool across 90 countries" |
| **Mistake** | What went wrong? | "Assumed one-size-fits-all training would work" |
| **Impact** | What was the cost? | "40% adoption after 3 months, frustrated teams" |
| **Learning** | What did you realize? | "Local context isn't optional—it's foundational" |
| **Application** | How do you apply this now? | "Now I co-create training with regional champions" |

**One-liner formula**: "When I tried [situation], I learned [learning] the hard way—[mistake] cost us [impact]"

### Milestone Story Template
Use for: Achievements, wins, career highlights, proof points

| Element | Question | Example |
|---------|----------|---------|
| **Achievement** | What did you accomplish? | "Built dMAX platform used by 2000+ marketers" |
| **Context** | Why did it matter? | "No existing tool met enterprise AI governance needs" |
| **Challenge** | What made it hard? | "No budget, skeptical leadership, tight timeline" |
| **Approach** | How did you overcome it? | "Started small, proved value, grew organically" |
| **Broader Lesson** | What can others learn? | "Big transformations start with small, undeniable wins" |

**One-liner formula**: "Achieving [achievement] despite [challenge] taught me [broader lesson]"

## Interactive Flow

The command is interactive by default:

1. Ask for type (if not clear from input)
2. **Offer template** based on type:
   - If story: Ask "Is this a transformation, failure/learning, or milestone story?"
   - Show relevant template questions
3. Ask for short version (use one-liner formula)
4. Ask for themes
5. Ask for use_when
6. **Run quality checklist** (see below)
7. Optionally ask for full version
8. Save and confirm

### Template Selection Guidance

Help user choose the right template:

| If the story is about... | Suggest |
|--------------------------|---------|
| Personal growth, career change, skill acquisition | Transformation |
| Mistakes, setbacks, hard lessons | Failure/Learning |
| Wins, achievements, proof of capability | Milestone |
| Influential book, mentor, experience | Influence (no template) |

## Quality Checklist

Before saving, verify the story meets these criteria:

### Required Quality Checks
- [ ] **Clear takeaway**: Does it have a specific, actionable lesson?
- [ ] **Illustrates a principle**: Can it support a broader point in content?
- [ ] **Personal and unique**: Is it YOUR story, not a generic anecdote?
- [ ] **Pillar alignment**: Does it map to at least one content pillar?

### Content Pillar Mapping

Map story themes to pillars:

| Pillar | Relevant Themes |
|--------|-----------------|
| AI for Marketing | enterprise, transformation, ROI, adoption, change-management |
| Claude Code for Marketing | automation, workflows, productivity, tools, coding |
| AI Agents for Marketing | agents, orchestration, multi-agent, delegation |
| Building Agents | technical, development, architecture, implementation |
| Digital Marketing Maturity | maturity, assessment, capability, growth, measurement |

### Quality Warnings

If story fails checks, provide feedback:

```
⚠️ Quality Check Warning

Your story may need refinement:
- [ ] Missing clear takeaway → Add: "The lesson here is..."
- [ ] Too generic → Add specific details, numbers, timeframes
- [ ] No pillar match → Consider how it relates to your content themes

Would you like to:
1. Refine the story now
2. Save anyway (may be less useful for content)
3. Cancel and try again
```

## Extended Collection (Full Narrative)

When `--full` flag is used or user opts for full version, collect extended narrative:

### For Transformation Stories
```markdown
## The Before
[Describe the situation, pain points, limitations]

## The Catalyst
[What happened that sparked the change]

## The Journey
[Steps taken, obstacles overcome, timeline]

## The After
[Results, new capabilities, changed perspective]

## The Lesson
[Universal truth that others can apply]
```

### For Failure/Learning Stories
```markdown
## The Goal
[What you were trying to achieve]

## The Mistake
[What you did wrong, in honest detail]

## The Fallout
[Consequences - be specific about impact]

## The Realization
[What clicked, when it clicked]

## The Application
[How you've applied this learning since]
```

### For Milestone Stories
```markdown
## The Achievement
[What you accomplished - with metrics if possible]

## The Context
[Why this mattered, what gap it filled]

## The Obstacles
[What made it difficult]

## The Approach
[How you overcame the challenges]

## The Takeaway
[What others can learn from this]
```

## Parameters

### Optional Flags
- `--type`: Skip type question (story, book, experience, career)
- `--template`: Skip template question (transformation, failure, milestone)
- `--full`: Collect extended narrative
- `--skip-quality`: Skip quality checklist (not recommended)

## Notes

- Stories are automatically available to `/generate-content`
- Use `/sync-brain-dumps` to pull stories added via Notion mobile
- Review `config/personal-context.yaml` to see all stored context
- **Aim for 20-30 stories** with good theme coverage across pillars
- Run `/voice-calibrate` after adding multiple stories to update voice patterns

## Story Collection Goals

### Target Distribution
| Type | Target Count | Purpose |
|------|--------------|---------|
| Transformation | 5-8 | Show growth, establish credibility |
| Failure/Learning | 5-8 | Build trust through vulnerability |
| Milestone | 5-8 | Prove capability, inspire |
| Influences | 5-10 | Show depth, reveal thinking |

### Collection Schedule
- **Weekly (5-10 min)**: Capture any story that came up in conversations
- **Monthly (30 min)**: Review and add stories from recent wins/challenges
- **Quarterly (1 hour)**: Audit collection for gaps, refine weak stories
