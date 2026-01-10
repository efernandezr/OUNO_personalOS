# PersonalOS

An AI-powered personal branding operating system built on Claude Code. Transform market intelligence into thought leadership content with automated workflows, voice-matched content generation, and seamless Notion integration.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

PersonalOS is a collection of Claude Code slash commands and sub-agents designed to help thought leaders:

- **Monitor** AI and marketing trends from 20+ curated sources
- **Analyze** brain dumps and notes for content opportunities
- **Generate** platform-optimized content that matches your voice
- **Track** competitive intelligence and market movements
- **Automate** daily briefings and weekly dashboards

## Quick Start

### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- Notion account with MCP integration configured
- Firecrawl API key (for web scraping)

### Installation

**Option A: Automated Setup (Recommended)**

```bash
# Clone the repository
git clone git@github.com:efernandezr/OUNO_personalOS.git
cd PersonalOS

# Run the setup script
./scripts/setup.sh
```

The setup script will:
- Copy template configs to `config/`
- Create necessary directories
- Guide you through next steps

**Option B: Manual Setup**

1. Clone or copy the PersonalOS directory
2. Copy template configs: `cp config/templates/*.template.yaml config/` (rename without `.template`)
3. Configure MCP servers in your Claude Code settings:

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    },
    "firecrawl": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "firecrawl-mcp"],
      "env": {
        "FIRECRAWL_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

3. Restart Claude Code to load the MCP servers
4. Run your first command: `/daily-brief`

## Commands

### `/market-intelligence`

Scan configured sources for AI marketing insights, trends, and developments.

```bash
# Standard scan (last 24 hours, all high/medium priority sources)
/market-intelligence

# Quick scan (top 5 sources only)
/market-intelligence --depth quick

# Deep scan (all sources including low priority)
/market-intelligence --depth deep

# Extended timeframe
/market-intelligence --timeframe week
```

**Output:** `outputs/intelligence/{date}-market-brief.md`

**Notion Sync:** Creates entries in "POS: Market Intelligence" database

---

### `/daily-brief`

Generate a personalized morning briefing combining market intelligence with priorities.

```bash
# Standard brief (10 min read)
/daily-brief

# Quick brief (5 min read)
/daily-brief --length quick

# Include pending tasks from Notion
/daily-brief --include-todos
```

**Output:** `outputs/daily/{date}-brief.md`

**Notion Sync:** Creates entry in "POS: Daily Briefs" database

---

### `/brain-dump-analysis`

Analyze accumulated notes and ideas to identify patterns and content opportunities.

```bash
# Analyze last 30 days
/brain-dump-analysis

# Analyze last week
/brain-dump-analysis --timeframe week

# Focus on content pillar alignment
/brain-dump-analysis --focus pillars

# Analyze all available notes
/brain-dump-analysis --timeframe all
```

**Input:** Reads from **both** sources automatically:
- Local files: `brain-dumps/` folder
- Notion: "POS: Brain Dumps" database

**Output:** `outputs/analysis/{date}-brain-analysis.md`

---

### `/sync-brain-dumps`

Pull brain dumps from Notion to local storage. Useful for backing up mobile captures.

```bash
# Sync unprocessed brain dumps only (default)
/sync-brain-dumps

# Sync all brain dumps
/sync-brain-dumps --all

# Sync from a specific date
/sync-brain-dumps --since 2026-01-01

# Preview without saving
/sync-brain-dumps --dry-run
```

**Input:** Notion "POS: Brain Dumps" database

**Output:** Files saved to `brain-dumps/YYYY-MM/`

**Note:** This is optional - `/brain-dump-analysis` reads from Notion directly. Use this for local backup.

---

### `/content-repurpose`

Transform existing content into platform-optimized formats while preserving authentic voice.

```bash
# Repurpose from local file
/content-repurpose outputs/intelligence/2026-01-06-market-brief.md

# Repurpose from Notion page
/content-repurpose https://notion.so/your-page-url

# Target specific platforms
/content-repurpose source.md --platforms linkedin,twitter

# Generate more variations
/content-repurpose source.md --variations 3

# Set specific tone
/content-repurpose source.md --tone provocative
```

**Output:** `outputs/content/{date}-{slug}/`
- `linkedin-v1.md`, `linkedin-v2.md`
- `twitter-thread.md`
- `newsletter-snippet.md`
- `summary.md`

**Notion Sync:** Creates draft entries in "POS: Content Calendar"

---

### `/add-source`

Add new sources to your monitoring configuration.

```bash
# Add a news source
/add-source

# Add a competitor
/add-source --type competitor
```

**Updates:** `config/sources.yaml` or `config/competitors.yaml`

---

### `/voice-calibrate`

Analyze your writing samples to calibrate the voice profile for authentic content generation.

```bash
# Run calibration with all available samples
/voice-calibrate

# Require minimum 10 samples for higher confidence
/voice-calibrate --min-samples 10

# Calibrate from LinkedIn posts only
/voice-calibrate --platform linkedin

# Auto-approve recommendations (skip review)
/voice-calibrate --auto-approve

# Focus on specific voice aspects
/voice-calibrate --focus hooks,vocabulary
```

**Input:** Samples from `inputs/samples/linkedin-posts/` and `inputs/samples/newsletter-samples/`

**Output:**
- Calibration report: `outputs/analysis/{date}-voice-calibration.md`
- Updated: `config/voice-profile.yaml` (with your approval)

**Confidence Levels:**
| Samples | Confidence | Analysis Depth |
|---------|------------|----------------|
| 1-4 | Low | Basic patterns only |
| 5-10 | Medium | Vocabulary + structure |
| 10+ | High | Full voice fingerprint |

---

### `/add-story`

Add personal stories and experiences to your context for authentic content generation.

```bash
# Interactive story capture
/add-story

# Add with description
/add-story I want to add a story about failing fast from my startup days

# Specify type directly
/add-story --type transformation

# Capture extended narrative
/add-story --full
```

**Story Templates:** The command offers structured templates for:
- **Transformation stories**: Career pivots, mindset shifts, skill development
- **Failure/Learning stories**: Mistakes, setbacks, hard lessons
- **Milestone stories**: Achievements, wins, proof points

**Updates:** `config/personal-context.yaml`

**Notion Sync:** Creates entry in "POS: Personal Context" database

---

### `/create-spec`

Create a feature specification from a planning conversation.

```bash
# After a planning conversation
/create-spec my-new-feature

# Creates specs/my-new-feature/ with:
# - requirements.md
# - implementation-plan.md
# - action-required.md
```

**Output:** `specs/{feature-name}/`

**Note:** Specs are gitignored (personal to each user's improvements).

## Directory Structure

```
PersonalOS/
├── CLAUDE.md                 # Main context file for Claude
├── README.md                 # This file
│
├── config/                   # Configuration files
│   ├── topics.yaml          # Topics to monitor
│   ├── sources.yaml         # News sources and blogs
│   ├── competitors.yaml     # Competitor profiles
│   ├── voice-profile.yaml   # Your writing voice
│   ├── personal-context.yaml # Personal stories & experiences
│   ├── personal-context-guide.md # Story collection guide
│   ├── goals.yaml           # Tracking goals
│   └── notion-mapping.yaml  # Notion database IDs
│
├── .claude/commands/         # Slash command definitions
│   ├── market-intelligence.md
│   ├── daily-brief.md
│   ├── brain-dump-analysis.md
│   ├── content-repurpose.md
│   ├── add-source.md
│   ├── add-story.md
│   ├── voice-calibrate.md
│   ├── sync-status.md
│   ├── sync-brain-dumps.md
│   └── checkpoint.md
│
├── .claude/agents/          # Operative agent definitions
│   ├── intelligence-agent.md
│   ├── pattern-agent.md
│   ├── content-agent.md
│   ├── voice-calibration-agent.md
│   ├── sync-agent.md
│   └── sync-brain-dumps-agent.md
│
├── .claude/utils/           # Utility files
│   └── schemas.json        # JSON validation schemas
│
├── brain-dumps/             # Your notes and ideas
│   └── YYYY-MM/            # Organized by month
│
├── inputs/                  # Input materials
│   ├── samples/            # Voice calibration samples
│   │   ├── linkedin-posts/ # LinkedIn post samples (.md files)
│   │   ├── newsletter-samples/ # Newsletter samples (.md files)
│   │   └── .metadata.yaml  # Sample tracking metadata
│   └── pdfs/               # PDFs for analysis
│
├── outputs/                 # Generated content
│   ├── intelligence/       # Market intelligence briefs
│   ├── competitive/        # Competitor analysis
│   ├── content/            # Repurposed content
│   ├── analysis/           # Brain dump analysis
│   ├── dashboards/         # Weekly dashboards
│   └── daily/              # Daily briefs
│
├── archive/                 # Archived outputs (90+ days)
├── scripts/cron/           # Automation scripts
├── logs/                   # Execution logs
│
└── specs/                   # Feature specifications (gitignored)
    └── {feature-name}/     # One folder per feature
        ├── requirements.md
        ├── implementation-plan.md
        └── action-required.md
```

## Configuration

### `config/topics.yaml`

Define what topics to monitor:

```yaml
primary_topics:
  - name: "AI for Marketing"
    keywords: ["AI marketing", "marketing automation"]

secondary_topics:
  - name: "Martech"
    keywords: ["marketing technology"]

emerging_topics:
  - name: "AI Agents"
    keywords: ["agentic AI", "autonomous agents"]
```

### `config/sources.yaml`

Configure sources for market intelligence:

```yaml
sources:
  - name: "Anthropic Blog"
    url: "https://www.anthropic.com/news"
    type: "blog"
    priority: "high"

  - name: "Marketing AI Institute"
    url: "https://www.marketingaiinstitute.com/blog"
    type: "blog"
    priority: "high"
```

### `config/voice-profile.yaml`

Define your writing voice for content generation:

```yaml
tone:
  primary: "professional"
  secondary: "approachable"

vocabulary:
  preferred:
    - "transformation"
    - "practical"
  avoid:
    - "game-changer"
    - "synergy"

patterns:
  hooks: "Start with contrarian take or surprising data"
  closings: "End with forward-looking question"
```

## Notion Integration

PersonalOS syncs with 6 Notion databases:

| Database | Purpose |
|----------|---------|
| POS: Market Intelligence | Curated insights from source scanning |
| POS: Content Calendar | Draft content for publishing |
| POS: Brain Dumps | Idea capture and notes |
| POS: Competitive Analysis | Competitor tracking |
| POS: Weekly Reviews | Dashboard history |
| POS: Daily Briefs | Morning brief archive |

Database IDs are stored in `config/notion-mapping.yaml`.

## Operative Agents

PersonalOS uses **Task tool delegation** to specialized agents for complex tasks:

| Agent | Purpose | Model |
|-------|---------|-------|
| `intelligence-agent` | Web scraping, trend synthesis, source scanning | Sonnet |
| `pattern-agent` | Theme extraction, note analysis, content opportunities | Sonnet |
| `content-agent` | Voice-matched content generation for all platforms | Sonnet |
| `voice-calibration-agent` | Analyze samples, extract voice patterns | Sonnet |
| `sync-agent` | Notion read/write operations | Haiku |
| `sync-brain-dumps-agent` | Pull brain dumps from Notion | Haiku |

Agent definitions are in `.claude/agents/` and can be customized to improve output quality.

## Workflows

### Morning Routine

```bash
# 1. Get your daily briefing
/daily-brief

# 2. Review and mark insights worth exploring
# (In Notion, update status to "Flagged")
```

### Content Creation Flow

```bash
# 1. Capture ideas throughout the day
# (Add notes to Notion on mobile, or brain-dumps/ folder on desktop)

# 2. Optional: Sync Notion brain dumps to local storage
/sync-brain-dumps

# 3. Analyze for patterns weekly
/brain-dump-analysis --timeframe week

# 4. Pick a topic and generate content
/content-repurpose outputs/analysis/2026-01-06-brain-analysis.md --platforms linkedin
```

### Weekly Intelligence Review

```bash
# Deep scan of all sources
/market-intelligence --depth deep --timeframe week
```

## Brain Dump Format

For best results, structure your brain dumps like this:

```markdown
# Brain Dump - 2026-01-06

## Ideas
- Idea about AI agents in marketing
- Thought on content automation

## Questions
- What if we could automate X?
- How can marketers leverage Y?

## Observations
- Noticed trend in enterprise AI adoption
- Interesting pattern in competitor content

## Tags
#ai #marketing #content-idea
```

## Performance Targets

| Command | Target Time |
|---------|-------------|
| `/market-intelligence --depth quick` | < 1 minute |
| `/market-intelligence` (standard) | < 3 minutes |
| `/market-intelligence --depth deep` | < 5 minutes |
| `/daily-brief` | < 2 minutes |
| `/brain-dump-analysis` | < 3 minutes |
| `/content-repurpose` | < 2 minutes |
| `/sync-brain-dumps` | < 1 minute |

## Troubleshooting

### Firecrawl not working

1. Verify API key in Claude Code settings
2. Restart Claude Code to reload MCP servers
3. Test with: `/market-intelligence --depth quick`

### Notion sync failing

1. Verify Notion MCP is connected
2. Check database IDs in `config/notion-mapping.yaml`
3. Ensure databases have correct properties

### Content not matching voice

1. Add more samples to `inputs/samples/linkedin-posts/` and `inputs/samples/newsletter-samples/`
2. Run `/voice-calibrate` to analyze and calibrate
3. Review the calibration report in `outputs/analysis/`
4. If needed, manually adjust `config/voice-profile.yaml`

## Voice Calibration Setup

Voice calibration ensures generated content matches your authentic writing style. Here's how to set it up:

### Step 1: Add Writing Samples

Add your best-performing content to the samples folders:

**LinkedIn Posts:**
```bash
# Create sample files in inputs/samples/linkedin-posts/
# Use this format:

inputs/samples/linkedin-posts/post-001.md
```

```markdown
---
date: 2025-12-15
engagement: high
topics: [AI, marketing, transformation]
---

Your LinkedIn post content here...
```

**Newsletter Samples:**
```bash
inputs/samples/newsletter-samples/issue-001.md
```

```markdown
---
date: 2025-12-01
type: newsletter
topics: [AI agents, enterprise]
---

Your newsletter content here...
```

### Step 2: Run Calibration

```bash
# Once you have 5+ samples
/voice-calibrate
```

### Step 3: Review and Approve

The calibration will:
1. Analyze sentence patterns, vocabulary, and structure
2. Show you recommended updates to `voice-profile.yaml`
3. Ask for approval before making changes

### Tips for Better Calibration

- **More samples = better results**: 10+ samples recommended
- **Include variety**: Different tones, topics, lengths
- **Use high-performers**: Posts with good engagement are best
- **Update regularly**: Re-run after major content pivots

## Roadmap

### Coming Soon
- `/competitive-analysis` - Deep competitor monitoring
- `/weekly-dashboard` - Automated weekly metrics review
- `/meeting-prep` - Prepare for meetings with context

> **Detailed tracking**: See `planning/ROADMAP.md` for full feature roadmap, ideas backlog, and progress tracking (gitignored, local only).

## Project Structure

PersonalOS separates **framework** (tracked in git) from **personal data** (stays local):

```
PersonalOS/
├── Framework (tracked)
│   ├── CLAUDE.md, README.md       # Documentation
│   ├── .claude/commands/          # Slash commands
│   ├── sub-agents/                # Agent definitions
│   ├── scripts/                   # Automation scripts
│   └── config/templates/          # Config templates
│
└── Personal Data (gitignored)
    ├── config/*.yaml              # Your actual configs
    ├── outputs/                   # Generated content
    ├── brain-dumps/               # Your notes
    └── logs/                      # Execution logs
```

When you clone, run `./scripts/setup.sh` to create your personal config files from templates.

## Improving PersonalOS

Want to add features or improvements to PersonalOS? Use the spec workflow:

### 1. Plan the Feature

Enter planning mode and design your approach with Claude.

### 2. Create a Spec

```bash
/create-spec my-feature-name
```

This generates three files in `specs/my-feature-name/`:
- **requirements.md** - What and why, acceptance criteria
- **implementation-plan.md** - Phased tasks with checkboxes
- **action-required.md** - Manual steps (API keys, accounts, etc.)

### 3. Implement

Follow the task checklist in `implementation-plan.md`. Each task is designed to be implementable in a single session.

### 4. Share (Optional)

If your improvement is framework-level (commands, agents, docs), submit a PR!

## Contributing

Contributions are welcome! Here's how to help:

### Reporting Issues
- Use GitHub Issues for bugs and feature requests
- Include steps to reproduce for bugs
- Describe your use case for features

### Pull Requests
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test with your local configs
5. Submit a PR with clear description

### Development Guidelines
- Keep commands focused and single-purpose
- Document new commands in README
- Add templates for any new config files
- Test with both fresh setup and existing configs

### Areas for Contribution
- New slash commands
- Sub-agent improvements
- Documentation improvements
- Bug fixes
- Performance optimizations

## License

MIT License - See [LICENSE](LICENSE) for details.

This means you can:
- Use PersonalOS commercially or personally
- Modify and distribute
- Use privately

Just include the license notice in copies.
