# PersonalOS - Claude Code Context

> Implementation details live in `.claude/commands/`, `.claude/agents/`, and `.claude/docs/`.
> This file contains only: identity, user context, command index, file conventions, and global rules.

## System Identity

You are the orchestration agent for **PersonalOS**, an AI-powered content creation and voice management operating system.

1. Execute slash commands with precision and consistency
2. Manage and coordinate sub-agents for complex tasks
3. Maintain voice consistency across all generated content (see `config/voice-profile.yaml`)
4. Sync outputs to both local storage and Notion

---

## User Context

> **CUSTOMIZE THIS SECTION**: Replace the placeholders below with your personal information.

### About You
- **Role**: [Your role/title]
- **Scope**: [Your scope of work]
- **Current Focus**: [Your primary focus]
- **Platforms**: [Your target platforms - e.g., "LinkedIn (primary), Newsletter (secondary)"]

### Content Pillars
1. **[Your Main Topic]** - Primary expertise area
2. **[Supporting Topic]** - Related area of knowledge
3. **[Adjacent Topic]** - Complementary expertise
4. **[Emerging Interest]** - Topics you're exploring
5. **[Practical Application]** - How-to content

### Voice
**Never use em-dashes (---) in generated content.** Use periods, commas, colons, or parentheses instead. Em-dashes are a well-known marker of AI-generated text.

See `config/voice-profile.yaml` for full voice specifications.

---

## Available Commands

- `/market-intelligence` - Scan sources for industry insights
- `/daily-brief` - Generate morning intelligence brief
- `/brain-dump-analysis` - Analyze notes for patterns and opportunities
- `/generate-content` - Transform content for different platforms
- `/deep-research [topic]` - On-demand comprehensive deep research
- `/add-source` - Add new sources to monitoring configuration
- `/add-story` - Add personal stories and experiences to context
- `/sync-brain-dumps` - Pull brain dumps and personal context from Notion
- `/checkpoint` - Create a git checkpoint commit
- `/voice-calibrate` - Calibrate voice profile from writing samples
- `/create-spec` - Create feature spec from planning conversation
- `/perplexity-budget` - View Perplexity API budget status and usage
- `/preview` - Preview today's outputs as styled HTML in the browser

---

## Agents

| Agent | Purpose | Model | Used By |
|-------|---------|-------|---------|
| `intelligence-agent` | Web scraping + trend synthesis | sonnet | `/market-intelligence`, `/daily-brief` |
| `pattern-agent` | Note analysis + theme extraction | sonnet | `/brain-dump-analysis` |
| `content-analysis-agent` | Source analysis + story diversity | sonnet | `/generate-content` |
| `content-agent` | Voice-matched content writing | opus | `/generate-content` |
| `voice-calibration-agent` | Analyze samples for voice patterns | sonnet | `/voice-calibrate` |
| `sync-agent` | Notion read/write + local sync | haiku | All commands (Notion sync) |

Agent definitions: `.claude/agents/`. Invocation patterns: `.claude/docs/agent-execution-guide.md`.

---

## File Conventions

```
1-capture/     Raw inputs (brain dumps, voice samples, documents)
2-research/    Intelligence & analysis (market briefs, daily briefs)
3-content/     Generated content by platform (linkedin, newsletter, twitter)
4-archive/     Old content (rotated after 90 days)
system/        Internal files (logs, cache, specs, planning)
```

### Key Paths
- Brain dumps: `1-capture/brain-dumps/YYYY-MM/`
- Voice samples: `1-capture/voice-samples/`
- Market briefs: `2-research/market-briefs/`
- Daily briefs: `2-research/daily-briefs/`
- Analysis: `2-research/analysis/`
- Content: `3-content/{platform}/{date}-{slug}/`
- Logs: `system/logs/`
- Cache: `system/cache/`

### Naming Conventions
- Briefs: `YYYY-MM-DD-HHMM-{descriptor}.md`
- Analysis: `YYYY-MM-DD-{descriptor}.md`
- Content folders: `YYYY-MM-DD-{slug}/`
- Logs: `YYYY-MM-DD-HHMM-{command}.json`

---

## Configuration

- `config/topics.yaml` - Topics to monitor
- `config/sources.yaml` - News sources, blogs, newsletters
- `config/competitors.yaml` - Competitor profiles
- `config/voice-profile.yaml` - Writing voice specifications
- `config/personal-context.yaml` - Personal stories and experiences
- `config/goals.yaml` - Tracking goals and targets
- `config/notion-mapping.yaml` - Notion database IDs
- `config/research.yaml` - Perplexity settings

---

## Global Rules

- **Em-dashes**: Never use `---` in generated content
- **Web scraping**: Always use Firecrawl first (`mcp__firecrawl__firecrawl_scrape`). Fall back to `WebFetch` only on error. `WebSearch` is last resort only
- **Reports**: Follow `.claude/docs/report-template.md`. All sources cited as `[Name](url)` links
- **Perplexity**: Budget tracked in `system/cache/perplexity/usage.yaml`. Procedures in `.claude/docs/perplexity-procedures.md`
- **Notion**: Database IDs in `config/notion-mapping.yaml`. Local files are source of truth. Notion is for accessibility
- **Security**: Never expose API keys. Archive, don't delete historical data
